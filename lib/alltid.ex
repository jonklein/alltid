defmodule Alltid do
  @moduledoc """
  Alltid is a simple package enables simplified editing of deeply nested structures in Elixir.

  Inspired by [Immer.js](https://immerjs.github.io/immer/) in JavaScript, Alltid allows a
  declarative syntax for manipulating deeply nested immutible data structures.

  ```
  require Alltid

  data = %{positions: [%{x: 1, y: 0, z: 0}]}

  next = Alltid.produce(data, fn draft ->
    draft[:posts][0][:name] <- "Alltid"
    draft[:posts][1][:name] <- "Elixir"
  end)
  ```

  ```
  data = %{posts: [%{id: 1, name: ""}, %{id: 2, name: ""}]}

  data
  |> put_in([:posts, Access.at(0), :name], get_in([:posts, Access.at(0), :name]) * 2)
  |> put_in([:posts, Access.at(1), :name], "Elixir")
  ```
  """

  @spec produce(any, {:fn, any, [{:->, any, [...]}, ...]}) ::
          {{:., [{any, any}, ...], [{any, any, any}, ...]},
           [{:closing, [...]} | {:column, 40}, ...], [...]}
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

  @spec keypath(any) :: [...]
  defp keypath({var, _, nil}) do
    [var]
  end

  defp keypath({{:., _, [Access, :get]}, _, [lhs, key]}) do
    keypath(lhs) ++ [key(key)]
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
    expr =
      case keypath(lhs) do
        [^acc] ->
          rhs

        [^acc | path] ->
          quote do
            put_in(unquote(Macro.var(acc, nil)), unquote(path), unquote(rewrite(rhs, acc)))
          end

        _ ->
          expr
      end

    {:=, [], [Macro.var(acc, nil), expr]}
  end

  defp rewrite(expr = {op, ln, operands}, acc) do
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
    # Rewrite the builder function
    # - any statement matching "param[keypath] <- expr" is re-written to "param = put_in(param, keypath, expr)"
    # - return `param` at the end

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
