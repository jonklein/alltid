defmodule Alltid.MixProject do
  use Mix.Project

  def project do
    [
      app: :alltid,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        extras: ["readme.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Jon Klein"],
      description: "Alltid offers a simplified approach to editing deeply nested immutable data structures in Elixir.",
      links: %{"GitHub" => "https://github.com/jonklein/alltid"},
      source_url: "https://github.com/jonklein/alltid"
    ]
  end
end
