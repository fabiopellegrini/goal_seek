defmodule GoalSeek.MixProject do
  @moduledoc false
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :goal_seek,
      name: "GoalSeek",
      version: @version,
      description: "Goal Seek implementation for Elixir",
      source_url: "https://github.com/fabiopellegrini/goal_seek",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test
      ],
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "GoalSeek",
      extras: ["README.md"],
      formatters: ["html"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Fabio Pellegrini"],
      links: %{
        "GitHub" => "https://github.com/fabiopellegrini/goal_seek"
      }
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.16.1", only: :test},
      {:noether, "~> 0.2.2"}
    ]
  end
end
