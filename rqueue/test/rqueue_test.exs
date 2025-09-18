defmodule RqueueTest do
  use ExUnit.Case
  doctest Rqueue

  test "greets the world" do
    assert Rqueue.hello() == :world
  end
end
