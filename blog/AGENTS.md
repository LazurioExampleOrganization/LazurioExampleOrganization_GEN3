# Blog - pravidla pro agenty

Agent může proaktivně psát drafty do `blog/posts/`, když najde aha moment
nebo sdílitelný pattern.

## Pravidla

- Bez secrets.
- Bez klientských dat.
- Bez osobních overlayů.
- Public jen po owner review.
- Pokud článek mění pravidlo, blog nestačí.

## Frontmatter

Post musí mít JSON frontmatter se stejnými poli jako template v
`blog/templates/aha-moment.md`.

Pokud má být článek zdrojem pro sociální sítě nebo marketing, vyplň
`channels` a nech `safe_to_share: false`, dokud ho neschválí owner.
