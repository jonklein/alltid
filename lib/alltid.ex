defmodule Alltid do
  @moduledoc """
  Alltid offers a simplified approach to editing deeply nested immutable data structures in Elixir.

  Inspired by [Immer.js](https://immerjs.github.io/immer/) in JavaScript, Alltid allows a
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
  """

  @doc """
  Produces an update to `value` using the provided `fun` function.  Within the scope of
  `fun`, statements are rewritten in a

  Returns a copy of `value` with the edits from `fun` applied.
  """
  defmacro produce(value, fun) do
    quote do
      unquote(rewrite_fn(fun)).(unquote(value))
    end
  end

  defp keypath({var, _, nil}) do
    [var]
  end

  defp keypath({{:., _, [Access, :get]}, _, [lhs, rhs]}) do
    keypath(lhs) ++ [key(rhs)]
  end

  defp keypath(_) do
    [nil]
  end

  defp key(i) when is_integer(i) do
    quote do
      Access.at!(unquote(i))
    end
  end

  defp key(i), do: i

  defp rewrite([h | t], acc) do
    [rewrite(h, acc) | rewrite(t, acc)]
  end

  defp rewrite(expr = {:<-, _, [lhs, rhs]}, acc) do
    case keypath(lhs) do
      [^acc] ->
        # `acc <- value`
        {:=, [], [Macro.var(acc, nil), rewrite(rhs, acc)]}

      [^acc | path] ->
        # `acc[...keypath...] <- value`

        {:=, [],
         [
           Macro.var(acc, nil),
           quote do
             put_in(unquote(Macro.var(acc, nil)), unquote(path), unquote(rewrite(rhs, acc)))
           end
         ]}

      _ ->
        # an `x <- y` expression that doesn't include our acc var
        expr
    end
  end

  defp rewrite(expr = {op, ln, operands}, acc) do
    # Re-write an operation by rewriting the operands

    case keypath(expr) do
      [^acc] ->
        expr

      [^acc | path] ->
        quote do
          get_in(unquote(Macro.var(acc, nil)), unquote(path))
        end

      _ ->
        {op, ln, rewrite(operands, acc)}
    end
  end

  defp rewrite(i, _) do
    i
  end

  defp rewrite_fn({:fn, l1, [{:->, l2, [[{acc, l3, nil}], expr]}]}) do
    # Deconstruct the anonymous function definition: `fn acc -> [expr] end`, where `expr` is an
    # expression or block of expressions.
    #
    # Rewrite the function as follows:
    # - all "path" accesses to `acc` are re-written as get_in(acc, path), with list-index handling
    # - expressions matching "param[keypath] <- expr" are re-written to "acc = put_in(acc, path, expr)"
    # - `acc` is returned at the end

    code =
      case expr do
        {:__block__, _, expressions} -> expressions
        expression -> [expression]
      end

    {:fn, l1,
     [
       {:->, l2,
        [[{acc, l3, nil}], {:__block__, [], rewrite(code ++ [Macro.var(acc, nil)], acc)}]}
     ]}
  end
end
