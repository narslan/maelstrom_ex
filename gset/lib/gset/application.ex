defmodule Gset.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Node.Store,
      Gset.Store,
      Replicate
    ]

    opts = [strategy: :one_for_one, name: Gset.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
