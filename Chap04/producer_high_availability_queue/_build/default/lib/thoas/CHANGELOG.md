# Changelog

## v1.0.0 - 2023-01-23

- `float_to_binary(Float, [short])` is now used for encoding floats. This
  improves performance and memory usage, but means this library now requires OTP
  25.0 or later.

## v0.4.1 - 2023-01-23

- Corrected the `json_term` type to include `null`, `true`, and `false`.

## v0.4.0 - 2022-08-26

- Adds support for integer keys.

## v0.3.0 - 2022-07-27

- Proplists may now be encoded with `thoas:encode/2`.

## v0.2.0 - 2021-12-29

- The atom `null` is now used to represent `null`, not `nil` as was previously
  used.

## v0.1.0 - 2021-12-28

- Initial version
