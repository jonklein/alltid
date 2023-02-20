# Alltid

`Alltid` is a better way to work with nested immutable structures in Elixir.
Inspired by `Immer.js` in JavaScript, alltid enables the syntax of setting 
mutable data by keypath.

```
Alltid.produce(%{}, fn j ->
  j[:key1] <- 1
  j[:key2] <- j[:key1] + 1
  j[:key3] <- 3
end)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `alltid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:alltid, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/alltid>.

