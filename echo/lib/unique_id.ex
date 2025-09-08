defmodule UniqueId do
  @moduledoc """
  Unique ID workload for Maelstrom.
  """

  def main(_args) do
    IO.stream(:stdio, :line)
    |> Stream.each(fn line ->
      msg = JSON.decode!(line)
      IO.inspect(msg, label: "UniqueIdCli received")
    end)
    |> Stream.run()
  end
end
