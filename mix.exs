# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.MixProject do
  use Mix.Project

  def project do
    [
      app: :lowendinsight_get,
      version: "0.8.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :sasl, :runtime_tools],
      mod: {LowendinsightGet.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.14"},
      {:joken, "~> 2.5.0"},
      {:elixir_uuid, "~> 1.2"},
      {:cowboy, "~> 2.9", overide: true},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.6", except: :prod, runtime: false},
      {:redix, ">= 0.0.0"},
      {:quantum, "~> 3.5"},
      {:timex, "~> 3.7"},
      {:oban, "~> 2.17"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, "~> 0.18"},
      ## {:lowendinsight, path: "../lowendinsight"},
      ## {:lowendinsight, git: "git@bitbucket.org:gtri/lowendinsight", branch: "develop"}
      {:lowendinsight, "0.8.1"},
      {:httpoison_retry, "~> 1.1.0"},
      {:distillery, "~> 2.1"},
      {:excoveralls, "~> 0.14.0", only: :test}
    ]
  end
end
