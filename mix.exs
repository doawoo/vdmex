defmodule Vdmex.MixProject do
  use Mix.Project

  def project do
    [
      app: :vdmex,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vdmex, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:oscx, "~> 0.1.1"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.14"},
    ]
  end
end
