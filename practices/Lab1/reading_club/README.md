# Reading Club

## Domain

Reading Club is a campus app where students browse books, borrow available
copies, and view discussion meeting details.

Each book has a genre, meeting date, meeting place or online link, a copy
limit, a list of borrowers, an optional description, and a favourite flag.
The app has Books, Favourites, and Profile tabs.

All data is stored in memory and resets when the application restarts.

## Decisions

The book list and profile live in the shell's State so all three tabs use
the same data.

The tabs receive data through constructor parameters and send changes back
through callbacks.

The detail screen receives callbacks so borrowing, returning, editing,
and deleting also update the shell's list.

The form returns a Book through Navigator.pop instead of changing the
shared list directly, so cancelling leaves the original data unchanged.

LayoutBuilder selects a list or grid using the available content width
rather than the whole screen size.

PopScope compares the current form values with their initial snapshot
and asks for confirmation only when there are unsaved changes.

The Book model stores an unmodifiable copy of its borrowers list to
prevent changes from outside the model.

With week 9's tools, I would move the in-memory data into a repository
and add persistence so books and the profile survive an app restart.