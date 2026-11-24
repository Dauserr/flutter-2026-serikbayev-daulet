# Lab 2 - Shelf notes

## Team

No partner was available for this submission, so the pair workflow (R1-R3) cannot be satisfied. `TEAM.md` records the solo ownership and the missing PR review rather than pretending a second person exists.

## Domain

- Catalogue: Open Library search API (`openlibrary.org/search.json`), nested authors parsed by `BookAuthor.fromJson`.
- Collection: shelf entries on `api.restful-api.dev/objects`, with real GET / POST / PUT / DELETE calls.
- Shelf fields: book key, title, authors, status, rating, pages read, notes, target date, finished.

## Architecture

`main.dart` is the composition root. It creates two `ApiClient`s (catalogue and collection) with one `SecureStore`, then `HttpBookRepository` / `HttpShelfRepository` or their fakes. `CatalogueModel` and `ShelfModel` own loading/error/items; screens only see models.

## Build and release

- Version `1.0.1+2`; applicationId `kz.serikbayev.shelf`.
- Release APK built with split ABI, obfuscation and `build/symbols`; arm64 APK and symbols archived in `releases/1.0.1+2/`.
- Signing: same upload key as the earlier app, certificate CN `Daulet Serikbayev`, OU `Mobile`, O `KBTU`.
- Two GitHub Releases for Lab 2 and external PR reviews are not completed in this solo environment.

## Decisions

- Search goes to the Open Library query endpoint, not a local filter over a fixed list.
- The shelf is remote CRUD on `api.restful-api.dev`; the list refreshes from the server after every mutation.
- The catalogue cache is in application Documents; the shelf is not cached because it is the user's mutable server data.
- `select` is used only for the shelf badge; the badge depends on the count, not every shelf field.
- `PopScope` protects a dirty form; Save is an explicit exit and does not ask.
- `USE_FAKES=true` switches both repositories, leaving no network dependency at the defence.

## Checks

- 17 tests, offline, under 10 seconds.
- `flutter analyze`: 0 issues; `dart format .`: no diff; layer check: no output.
- Screenshots: `docs/catalogue.png`, `docs/offline.png`.
