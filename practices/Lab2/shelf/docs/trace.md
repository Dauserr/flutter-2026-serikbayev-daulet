# Planted trace - a broken book field

The catalogue contract says `edition_count` is a number. I changed it to `"one"` in a test payload and captured the failure without letting the screen crash:

```text
type 'String' is not a subtype of type 'num?' in type cast
#0      new Book.fromJson (package:shelf/features/catalogue/book.dart:63:44)
#1      main.<anonymous closure> (file:///.../test/tmp_trace_test.dart:8:12)
#2      Declarer.test.<anonymous closure> ...
<asynchronous suspension>
```

- **Message:** `type 'String' is not a subtype of type 'num?' in type cast`
- **First own frame:** `Book.fromJson` at `book.dart:63:44`
- **Path:** `Book.fromJson` → test harness; in production `HttpBookRepository.search` catches the `TypeError` and throws `BadResponseException('books: ...')`.
- **Data:** a book payload whose `edition_count` was the string `"one"`.

The test `throws when edition_count is a string` in `test/features/catalogue/book_test.dart` is the permanent reproduction.
