defmodule AlltidTest do
  use ExUnit.Case
  doctest Alltid

  defmodule Struct do
    defstruct [:field]
  end

  test "it assigns a plain value" do
    assert 4 =
             Alltid.produce(2, fn j ->
               j <- j * 2
             end)
  end

  test "it sets a value in a map" do
    assert %{key1: 1, key2: 2, key3: 3} =
             Alltid.produce(%{}, fn j ->
               j[:key1] <- 1
               j[:key2] <- 2
               j[:key3] <- 3
             end)
  end

  test "it sets values in a struct" do
    assert [%Struct{field: 1}] ==
             Alltid.produce([%Struct{field: 1}], fn j ->
               j[0][:field] <- 1
             end)
  end

  test "it sets derived values " do
    assert %{key1: 1, key2: 0, key3: 3} =
             Alltid.produce(%{}, fn j ->
               j[:key1] <- 1
               j[:key2] <- j[:key1] - 1
               j[:key3] <- 3
             end)
  end

  test "it sets a value in a list" do
    assert [3, 2, 1] =
             Alltid.produce([1, 2, 3], fn j ->
               j[0] <- 3
               j[2] <- 1
             end)
  end

  test "it sets nested values" do
    assert %{x: [3, 2, 1]} =
             Alltid.produce(%{x: [1, 2, 3]}, fn j ->
               j[:x][0] <- 3
               j[:x][2] <- 1
             end)
  end

  test "it sets deeply nested values" do
    assert %{x: [1, 2, [[k: 10]]]} =
             Alltid.produce(%{x: [1, 2, 3]}, fn j ->
               j[:x][2] <- [1]
               j[:x][2][0] <- [k: 10]
             end)
  end

  test "it sets deeply nested values with index access in rhs" do
    assert %{x: [1, 2, 4]} =
             Alltid.produce(%{x: [1, 2, 3]}, fn j ->
               j[:x][2] <- j[:x][2] + 1
             end)
  end

  test "it sets more nested values" do
    Alltid.produce(%{posts: [%{id: 1, name: ""}, %{id: 2, name: ""}]}, fn draft ->
      draft[:posts][0][:name] <- "Alltid"
      draft[:posts][1][:name] <- "Elixir"
    end)
  end

  test "it raises for out of bounds errors" do
    catch_error do
      Alltid.produce(%{x: [1, 2, 3]}, fn j ->
        j[:x][2] <- [1]
        j[:x][2][1] <- [k: 10]
      end)
    end
  end
end
