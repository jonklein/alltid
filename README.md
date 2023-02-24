# Alltid

Alltid offers a simplified approach to editing deeply nested immutable data structures in Elixir.

Inspired by [Immer.js](https://immerjs.github.io/immer/) in JavaScript, Alltid allows a natural
declarative syntax for manipulating deeply nested immutible data structures.

```
require Alltid

data = %{accounts: [%{id: 1, balance: 200}, %{id: 2, balance: 150}]}

next = Alltid.produce(data, fn draft ->
  draft[:accounts][0][:balance] <- draft[:accounts][0][:balance] + 50
  draft[:accounts][1][:balance] <- draft[:accounts][1][:balance] - 50
end)
```

This example is simply syntactic sugar for the following:

```
data = %{accounts: [%{id: 1, balance: 200}, %{id: 2, balance: 150}]}

data
|> put_in([:accounts, Access.at(0), :balance], get_in([:accounts, Access.at(0), :balance]) + 50)
|> put_in([:accounts, Access.at(1), :balance], get_in([:accounts, Access.at(1), :balance]) - 50)
```

Though Alltid's `produce` pattern may appear to violate the spirit of functional programming, it
simply uses Elixir's macro system and variable bindings to enable a more natural and familiar
syntax, entirely isolated to the function passed in to `Alltid.produce`.  The code is still
entirely functional.

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

