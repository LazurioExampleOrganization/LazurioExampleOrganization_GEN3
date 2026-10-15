# Blog: rules for agents

An agent may proactively write drafts into `blog/posts/` when it finds an aha
moment or a shareable pattern.

## Rules

- No secrets.
- No client data.
- No personal overlays.
- Public only after owner review.
- If a post changes a rule, the blog is not enough.

## Frontmatter

A post must have JSON frontmatter with the same fields as the template in
`blog/templates/aha-moment.md`.

If the post is meant as a source for social networks or marketing, fill in
`channels` and keep `safe_to_share: false` until the owner approves it.
