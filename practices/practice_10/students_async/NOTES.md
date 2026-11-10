# Practice 10 - Notes

## Level 1 - predicted and actual order

Predicted:

```text
A
C
first frame
B
6 students
```

Actual:

```text
A
C
fetchStudents #1
first frame
B
6 students
```

The request starts before the first frame, but nothing waits for it. `B` was scheduled first, so it arrives before the students callback.

## Level 2 - the dispose error

With both `if (!mounted) return;` lines removed, leaving the screen during the two-second request produced:

```text
setState() called after dispose(): _StudentsScreenState#7efe0(lifecycle state: defunct, not mounted)
```

## Level 4 - countdown observations

- With `_sub.cancel()` in `dispose`: leaving version B at tick 7 stops the console at `tick 7`; no ticks 6 to 0, no error.
- Without `_sub.cancel()`: leaving at tick 7 prints `setState() called after dispose(): _ListenCountdownState#... (lifecycle state: defunct, not mounted)` and the console keeps printing `tick 6`, `tick 5`, ... down to `tick 0`.
- Version A with `StreamBuilder`: leaving at tick 7 stops the console at `tick 7` with no cancel in our code; `StreamBuilder` cancels the subscription itself.

## Level 5 - the save error

The un-awaited version popped the screen immediately, so the user saw a success. The console showed:

```text
Unhandled Exception: Bad state: server rejected 6
```

The final version awaits `save`, catches `StateError`, checks `context.mounted`, and pops only after a successful save. A second tap while the request is in flight does nothing because the button is disabled and `_saving` is set.
