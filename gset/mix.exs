defmodule Gset.MixProject do
  use Mix.Project

  def project do
    [
      app: :gset,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Gset.Main],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Gset.Application, []}
    ]
  end

  defp deps do
    []
  end
end
