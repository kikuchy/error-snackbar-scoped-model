# Showing error on SnackBar using ScopedModel architecture

Example of showing error messages on SnackBar using ScopedModel architecture.

## tr;dr

1. Encapsulate "loading states" in Model class.
2. Use `State#context` and get `ScaffoldState`.

## Details

See [`lib/main.dart`](lib/main.dart).

![image](art/sample.gif)