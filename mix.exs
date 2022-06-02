defmodule Contrak.MixProject do
  use Mix.Project

  def project do
    [
      app: :contrak,
      version: "0.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: docs(),
      name: "Contrak",
      description: description(),
      source_url: "https://github.com/bluzky/contrak",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      maintainers: ["Dung Nguyen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bluzky/contrak"}
    ]
  end

  defp description() do
    """
    Schema and contract validation library for Elixir
    """
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:valdi, "~> 0.3.0"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end
end
