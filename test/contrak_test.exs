defmodule ContrakTest do
  use ExUnit.Case
  doctest Contrak

  test "greets the world" do
    assert Contrak.hello() == :world
  end
end
