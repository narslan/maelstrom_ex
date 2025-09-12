defmodule GcounterTest do
  use ExUnit.Case
  doctest Gcounter

  test "greets the world" do
    assert Gcounter.hello() == :world
  end
end
