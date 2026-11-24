# Practice 15 - Notes

## Ninety seconds on the profile

Started a timer and opened the public profile in a private window.

At 90 seconds I saw: the avatar, `Dauserr`, the public course repository and its Releases, but no display name, no bio, no location, and no pinned repositories. The repo description was empty; it now reads “Flutter course work: users REST client, offline cache, signed release” with topics `flutter`, `dart`, `provider`.

What I did not see: a one-line identity (“Flutter developer · KBTU · 2026”), a second pinned project, and a visible project story above the fold. The profile edit needs a GitHub token with the `user` scope, and pinning is a profile UI action; both are marked as follow-ups, not silently skipped.

## Classmate profile

No classmate profile was available in this environment. The three questions I would ask first are:

1. What did you build yourself in the project, and what came from a tutorial?
2. How does your app behave offline, and what test proves it?
3. What would you change in the project if you had one more week?

These are the questions a reviewer can ask from the public page alone.

## CV

`docs/cv.pdf` is one page. It contains the project paragraph with the release link, the source link, education, and skills split into “Keep” and “Also / learning”. LinkedIn was not provided, so the CV currently uses email and GitHub only; add the LinkedIn URL before sending.

Two reviewer questions to send with the CV:

- “What part of this project would you trust in production tomorrow?”
- “Show me the test that would fail if the offline cache broke.”

## Recording notes

I read five answers aloud and listened once. Two things to change:

- Stop starting with “so” and give the definition first.
- For Future vs Stream, say “one value vs many values” before mentioning the app example.

## Warm-up timings

- Warm-up 1, counter with provider: finished inside the 20-minute slot; the first attempt showed the `Navigator` context mistake and the test caught it.
- Warm-up 2, four-state list: first attempt finished at 20:00 with the error state still missing; the second attempt finished in 12:30. Difference: 7.5 minutes.
- Warm-up 3, form validators: finished in 17:00; the validators were extracted so the test does not need a widget.

Warm-up folders are in `warmups/`; warm-up 2 has both attempts.

## Stories

The three stories are in `INTERVIEW.md`. The bug story was read aloud and timed at 1:12; it has the five beats and ends with the habit of cancelling every subscription. The design decision names the alternative (lifting the cart through constructors), and the “one thing differently” is to write the fake repository before the HTTP path.

## Files

- `INTERVIEW.md` - twenty answers and three stories
- `docs/cv.pdf` - one-page CV
- `warmups/warmup_1_counter` - provider counter
- `warmups/warmup_2_list` - first four-state attempt
- `warmups/warmup_2_list_retry` - second attempt
- `warmups/warmup_3_form` - validators and form
