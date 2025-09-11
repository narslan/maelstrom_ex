defmodule Gcounter.MixProject do
  use Mix.Project

  def project do
    [
      app: :gcounter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Gcounter],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Gcounter.Application, []}
    ]
  end

  defp deps do
    []
  end
end
