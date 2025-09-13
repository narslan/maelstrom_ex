defmodule SingleNodeTest do
  use ExUnit.Case
  doctest SingleNode

  test "greets the world" do
    assert SingleNode.hello() == :world
  end
end
