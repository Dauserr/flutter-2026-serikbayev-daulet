# Practice 9 - Notes

## Level 1 - Lift it up

Adding the total to the badge touched two constructors:

- `BooksScreen` in `lib/books_screen.dart`
- `CartBadge` in `lib/cart_badge.dart`

`Shell` only passed the value down; its constructor stayed the same.

One tap on **Add** printed 7 lines: `BooksScreen build` plus one line for each of the six rows. `setState` in `Shell` rebuilt the screen and every row.

## Level 3 - The loud and the silent failure

`context.watch<Cart>()` inside `onPressed`:

```text
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);

It is unsupported because may pointlessly rebuild the widget associated to the
event handler, when the widget tree doesn't care about the value.
```

`context.read<Cart>().count` inside `build`:

```text
(no output)
```

It compiles and runs, but the badge never subscribes, so it stays frozen at `0` after books are added.

## Level 4 - Rebuild counts

Three taps on **+** in the cart, then one book removed:

| Badge verb | 3 taps on + | Remove one book |
| --- | ---: | ---: |
| `context.watch<Cart>().count` | 3 badge builds | 1 badge build |
| `context.select<Cart, int>((cart) => cart.count)` | 0 badge builds | 1 badge build |

A quantity change does not change `count`, so the badge has no reason to rebuild. Removing a book changes `count`, so it rebuilds once.

## Where does it live?

- **Cart** - provided: one `Cart` above `MaterialApp`, because two routes mutate and read the same data.
- **Search text** - ephemeral: a `TextEditingController` and a query string inside `BooksScreen`, because only that screen filters its own list.
- **Total expanded or collapsed** - ephemeral: UI state inside `CartScreen`; no other widget needs to know how the total is displayed.
- **Theme mode** - lifted: a `ThemeMode` in a widget above `MaterialApp`, because the whole app changes appearance; it becomes provided if a settings route also has to toggle it.
