defmodule DeviTest do
  use ExUnit.Case
  doctest Devi

  test "greets the world" do
    assert Devi.hello() == :world
  end
end
