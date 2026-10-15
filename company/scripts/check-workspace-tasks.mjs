#!/usr/bin/env node

import { existsSync, lstatSync, readFileSync, readdirSync } from "node:fs";
import { dirname, join, relative, sep } from "node:path";

const TODO_TASKS_FILENAME = "TODO.tasks.json";
const DONE_TASKS_FILENAME = "DONE.tasks.json";
const OPEN_ISSUES_FILENAME = "ISSUES.open.json";

const TODO_TASKS_SCHEMA_VERSION = "companiesascode.todo_tasks.v1";
const DONE_TASKS_SCHEMA_VERSION = "companiesascode.done_tasks.v1";
const OPEN_ISSUES_SCHEMA_VERSION = "companiesascode.open_issues.v1";

const ignoredDirectories = new Set([".git", "node_modules", "MyCompanies"]);
const taskFilenames = new Set([TODO_TASKS_FILENAME, DONE_TASKS_FILENAME]);
const todoStatuses = new Set(["open", "in_progress", "blocked", "review"]);
const doneStatuses = new Set(["done", "archived"]);
const allowedStatuses = new Set([...todoStatuses, ...doneStatuses]);
const allowedPriorities = new Set(["high", "medium", "low"]);
const allowedIssueStatuses = new Set(["open", "investigating", "decision_needed", "blocked"]);
const allowedIssueSeverities = new Set(["high", "medium", "low"]);

const root = process.cwd();
const allFiles = walk(root);
const taskFiles = allFiles
  .filter((file) => taskFilenames.has(file.split(sep).at(-1)))
  .sort((a, b) => relative(root, a).localeCompare(relative(root, b)));
const issueFiles = allFiles
  .filter((file) => file.split(sep).at(-1) === OPEN_ISSUES_FILENAME)
  .sort((a, b) => relative(root, a).localeCompare(relative(root, b)));

const taskFailures = validateTaskFiles(loadTaskFiles(taskFiles));
const issueFailures = validateIssueFiles(loadIssueFiles(issueFiles));
const legacyFailures = assertLegacyTodoPointers(taskFiles);
const failures = [...taskFailures, ...issueFailures, ...legacyFailures];

if (failures.length > 0) {
  console.error("Workspace task kontrola selhala:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

const taskCount = loadTaskFiles(taskFiles).reduce((count, file) => count + file.data.tasks.length, 0);
const issueCount = loadIssueFiles(issueFiles).reduce((count, file) => count + file.data.issues.length, 0);

console.log(
  `Workspace task soubory v pořádku: ${taskFiles.length} task soubor(ů), ${taskCount} task(ů), ${issueFiles.length} issue soubor(ů), ${issueCount} issue(s)`,
);

function loadTaskFiles(files) {
  return files.map((file) => {
    const name = file.split(sep).at(-1);
    return {
      kind: name === DONE_TASKS_FILENAME ? "done" : "todo",
      file,
      relativePath: relative(root, file) || name,
      data: JSON.parse(readFileSync(file, "utf8")),
    };
  });
}

function loadIssueFiles(files) {
  return files.map((file) => ({
    file,
    relativePath: relative(root, file) || OPEN_ISSUES_FILENAME,
    data: JSON.parse(readFileSync(file, "utf8")),
  }));
}

function validateTaskFiles(files) {
  const failures = [];
  const scopeByKind = new Set();
  const taskIds = new Set();

  for (const taskFile of files) {
    const { data, kind, relativePath } = taskFile;
    const expectedSchemaVersion = kind === "done" ? DONE_TASKS_SCHEMA_VERSION : TODO_TASKS_SCHEMA_VERSION;
    if (data.schema_version !== expectedSchemaVersion) {
      failures.push(`${relativePath}: neplatný schema_version, očekává se ${expectedSchemaVersion}`);
    }

    validateScope(data.scope, relativePath, failures);

    if (data.scope?.id) {
      const scopeKindKey = `${kind}:${data.scope.id}`;
      if (scopeByKind.has(scopeKindKey)) {
        failures.push(`${relativePath}: duplicitní ${kind} scope.id ${data.scope.id}`);
      }
      scopeByKind.add(scopeKindKey);
    }

    if (!Array.isArray(data.tasks)) {
      failures.push(`${relativePath}: tasks musí být pole`);
      continue;
    }

    for (const task of data.tasks) {
      validateTask(task, kind, relativePath, failures);
      if (taskIds.has(task.id)) {
        failures.push(`${relativePath}: duplicitní task id ${task.id}`);
      }
      taskIds.add(task.id);
    }
  }

  return failures;
}

function validateIssueFiles(files) {
  const failures = [];
  const issueIds = new Set();

  for (const issueFile of files) {
    const { data, relativePath } = issueFile;
    if (data.schema_version !== OPEN_ISSUES_SCHEMA_VERSION) {
      failures.push(`${relativePath}: neplatný schema_version, očekává se ${OPEN_ISSUES_SCHEMA_VERSION}`);
    }
    validateScope(data.scope, relativePath, failures);
    if (!Array.isArray(data.issues)) {
      failures.push(`${relativePath}: issues musí být pole`);
      continue;
    }
    for (const issue of data.issues) validateIssue(issue, relativePath, failures, issueIds);
  }

  return failures;
}

function validateScope(scope, relativePath, failures) {
  if (!scope || typeof scope !== "object") {
    failures.push(`${relativePath}: chybí scope`);
    return;
  }
  for (const key of ["id", "name", "path", "owner"]) {
    if (typeof scope[key] !== "string" || scope[key].trim() === "") {
      failures.push(`${relativePath}: scope.${key} musí být neprázdný string`);
    }
  }
}

function validateTask(task, kind, relativePath, failures) {
  for (const key of [
    "id",
    "title",
    "status",
    "priority",
    "assignee",
    "created_at",
    "updated_at",
    "priority_decider",
    "priority_reason",
    "summary",
  ]) {
    if (typeof task[key] !== "string" || task[key].trim() === "") {
      failures.push(`${relativePath}: task ${task.id ?? "<bez-id>"} nemá ${key}`);
    }
  }

  if (typeof task.id === "string" && !/^task-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$/.test(task.id)) {
    failures.push(`${relativePath}: task id musí mít tvar task-YYYY-MM-DD-NNN (${task.id})`);
  }
  if (typeof task.assignee === "string" && !/^agent([:-][a-z0-9-]+)?$/.test(task.assignee)) {
    failures.push(`${relativePath}: ${task.id} assignee musí být agent nebo konkrétní agentní identifikátor`);
  }
  if (kind === "todo" && !todoStatuses.has(task.status)) {
    failures.push(`${relativePath}: ${task.id} má status ${task.status}, živý soubor smí obsahovat jen open/in_progress/blocked/review`);
  }
  if (kind === "done" && !doneStatuses.has(task.status)) {
    failures.push(`${relativePath}: ${task.id} má status ${task.status}, DONE soubor smí obsahovat jen done/archived`);
  }
  if (!allowedStatuses.has(task.status)) failures.push(`${relativePath}: neplatný status ${task.status}`);
  if (!allowedPriorities.has(task.priority)) failures.push(`${relativePath}: neplatná priority ${task.priority}`);
  if (!Number.isInteger(task.priority_rank) || task.priority_rank < 1) {
    failures.push(`${relativePath}: ${task.id} priority_rank musí být kladné celé číslo`);
  }

  for (const key of ["created_at", "updated_at"]) validateDate(task[key], `${relativePath}: ${task.id} má neplatné ${key}`, failures);
  for (const key of ["tags", "risk_notes", "acceptance_criteria", "links"]) {
    if (!Array.isArray(task[key])) failures.push(`${relativePath}: ${task.id} ${key} musí být pole`);
  }
  validateClickUpReference(task.clickup, `${relativePath}: ${task.id}`, failures);
  validatePlanningReference(task.planning, `${relativePath}: ${task.id}`, failures);

  if (kind === "done") {
    for (const key of ["completed_at", "completed_by", "outcome"]) {
      if (typeof task[key] !== "string" || task[key].trim() === "") {
        failures.push(`${relativePath}: done task ${task.id ?? "<bez-id>"} nemá ${key}`);
      }
    }
    validateDate(task.completed_at, `${relativePath}: ${task.id} má neplatné completed_at`, failures);
    if (!Array.isArray(task.evidence) || task.evidence.length === 0) {
      failures.push(`${relativePath}: ${task.id} evidence musí být neprázdné pole`);
    }
  }
}

function validateIssue(issue, relativePath, failures, issueIds) {
  for (const key of ["id", "title", "status", "severity", "owner", "created_at", "updated_at", "question", "impact"]) {
    if (typeof issue[key] !== "string" || issue[key].trim() === "") {
      failures.push(`${relativePath}: issue ${issue.id ?? "<bez-id>"} nemá ${key}`);
    }
  }
  if (typeof issue.id === "string" && !/^issue-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$/.test(issue.id)) {
    failures.push(`${relativePath}: issue id musí mít tvar issue-YYYY-MM-DD-NNN (${issue.id})`);
  }
  if (issueIds.has(issue.id)) failures.push(`${relativePath}: duplicitní issue id ${issue.id}`);
  issueIds.add(issue.id);
  if (!allowedIssueStatuses.has(issue.status)) failures.push(`${relativePath}: ${issue.id} má neplatný status ${issue.status}`);
  if (!allowedIssueSeverities.has(issue.severity)) failures.push(`${relativePath}: ${issue.id} má neplatnou severity ${issue.severity}`);
  if (typeof issue.owner === "string" && /^agent([:-]|$)/.test(issue.owner)) {
    failures.push(`${relativePath}: ${issue.id} owner musí být kolega nebo decision owner, ne agent`);
  }
  for (const key of ["created_at", "updated_at"]) validateDate(issue[key], `${relativePath}: ${issue.id} má neplatné ${key}`, failures);
  for (const key of ["tags", "options", "decision_needed_for", "links"]) {
    if (!Array.isArray(issue[key])) failures.push(`${relativePath}: ${issue.id} ${key} musí být pole`);
  }
  if (Array.isArray(issue.options) && issue.options.length === 0) {
    failures.push(`${relativePath}: ${issue.id} musí mít aspoň jednu option`);
  }
}

function validateClickUpReference(clickup, prefix, failures) {
  if (clickup === undefined) return;
  if (!clickup || typeof clickup !== "object" || Array.isArray(clickup)) {
    failures.push(`${prefix} clickup musí být objekt`);
    return;
  }
  const hasTaskId = typeof clickup.task_id === "string" && clickup.task_id.trim() !== "";
  const hasUrl = typeof clickup.url === "string" && clickup.url.trim() !== "";
  if (!hasTaskId && !hasUrl) {
    failures.push(`${prefix} clickup musí obsahovat task_id nebo url`);
  }
  for (const key of ["task_id", "url", "list_id", "role"]) {
    if (clickup[key] !== undefined && typeof clickup[key] !== "string") {
      failures.push(`${prefix} clickup.${key} musí být string`);
    }
  }
  if (hasUrl && !clickup.url.startsWith("https://app.clickup.com/")) {
    failures.push(`${prefix} clickup.url musí mířit na https://app.clickup.com/`);
  }
}

function validatePlanningReference(planning, prefix, failures) {
  if (planning === undefined) return;
  if (!planning || typeof planning !== "object" || Array.isArray(planning)) {
    failures.push(`${prefix} planning musí být objekt`);
    return;
  }
  const hasPlanId = typeof planning.plan_id === "string" && planning.plan_id.trim() !== "";
  const hasPath = typeof planning.path === "string" && planning.path.trim() !== "";
  const hasUrl = typeof planning.url === "string" && planning.url.trim() !== "";
  if (!hasPlanId && !hasPath && !hasUrl) {
    failures.push(`${prefix} planning musí obsahovat plan_id, path nebo url`);
  }
  for (const key of ["plan_id", "path", "url", "role", "source"]) {
    if (planning[key] !== undefined && typeof planning[key] !== "string") {
      failures.push(`${prefix} planning.${key} musí být string`);
    }
  }
  if (hasPath && (planning.path.startsWith("/") || planning.path.includes(".."))) {
    failures.push(`${prefix} planning.path musí být relativní cesta uvnitř workspace`);
  }
}

function assertLegacyTodoPointers(files) {
  const failures = [];
  const scopeDirs = new Set(files.filter((file) => file.endsWith(TODO_TASKS_FILENAME)).map((file) => dirname(file)));
  for (const dir of scopeDirs) {
    const todoPath = join(dir, "TODO.md");
    if (!existsSync(todoPath)) continue;
    const text = readFileSync(todoPath, "utf8");
    const path = relative(root, todoPath) || "TODO.md";
    if (!text.includes(TODO_TASKS_FILENAME)) {
      failures.push(`${path}: legacy TODO soubor musí odkazovat na ${TODO_TASKS_FILENAME}`);
    }
    if (/^\s*-\s+\[[ xX]\]/m.test(text)) {
      failures.push(`${path}: Markdown TODO nesmí obsahovat živý checkbox task stav, pokud scope používá ${TODO_TASKS_FILENAME}`);
    }
  }
  return failures;
}

function validateDate(value, message, failures) {
  if (typeof value === "string" && /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/.test(value)) return;
  failures.push(message);
}

function walk(dir, files = []) {
  if (dir !== root && isNestedGitWorktree(dir)) return files;

  for (const entry of readdirSync(dir)) {
    if (ignoredDirectories.has(entry)) continue;
    const path = join(dir, entry);
    let stat;
    try {
      stat = lstatSync(path);
    } catch (error) {
      if (["ENOENT", "ELOOP"].includes(error?.code)) continue;
      throw error;
    }
    if (stat.isSymbolicLink()) continue;
    if (stat.isDirectory()) {
      walk(path, files);
    } else {
      files.push(path);
    }
  }
  return files;
}

function isNestedGitWorktree(dir) {
  return existsSync(join(dir, ".git"));
}
