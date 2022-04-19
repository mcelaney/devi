defmodule Devi.MixProject do
  use Mix.Project

  def project do
    [
      app: :devi,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Devi",
      description: "An accounting management logic library",
      source_url: "https://github.com/mcelaney/devi",
      homepage_url: "https://github.com/mcelaney/devi",
      docs: [
        # The main page in the docs
        main: "Devi",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:faker, "~> 0.17", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
