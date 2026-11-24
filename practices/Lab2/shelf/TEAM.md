# Team

Solo implementation, as no partner was available for this submission. The pair-only workflow requirements are therefore recorded as not satisfied, not simulated.

## Owners

| Area | Owner | Reviewer |
|---|---|---|
| `features/catalogue` | Daulet Serikbayev | self-review |
| `features/shelf` | Daulet Serikbayev | self-review |
| `core/api` and `core/storage` | Daulet Serikbayev | self-review |
| tests | Daulet Serikbayev | self-review |
| release | Daulet Serikbayev | self-review |

## Workflow

Changes are made on `feature/<name>` branches and merged into `main` after a local review. No second GitHub account was available to create the required external pull-request review.

## Contributions

```text
Daulet Serikbayev
```

This is a solo repository; the 35 % pair rule cannot be evaluated.

## Decisions

- Use Open Library's search endpoint for the catalogue and a hosted REST collection for shelf entries - Daulet.
- Keep one API client per host: Open Library and `api.restful-api.dev` - Daulet.
- Cache only the catalogue in Documents; the shelf is the user's server data - Daulet.
- Use a fake catalogue and a fake shelf repository for the offline defence build - Daulet.
- Keep the catalogue search on the server, not in a local full-list filter - Daulet.
- Put the default shelf filter in `shared_preferences` and apply it as a model-independent screen filter - Daulet.
- Use `select` only for the shelf-count badge, so the badge does not rebuild for other fields - Daulet.
- Use `PopScope` on a dirty shelf form; Save bypasses the discard question - Daulet.
