# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Datastore do
  @moduledoc """
  In order to provide faster analysis, by caching repo reports LowEndInsight
  needs someplace to store the reports.  The current implementation is using
  Redis as the backend store and the redix Elixir library.
  """

  require Logger

  @doc """
  cache_key/1: converts a git repo URL into a structured cache key with format
  {ecosystem}:{package}:{version}. For example:
    https://github.com/org/repo -> github:org/repo:latest
    https://gitlab.com/org/repo -> gitlab:org/repo:latest
  """
  def cache_key(url) do
    uri = URI.parse(url)
    ecosystem = uri.host
      |> to_string()
      |> String.replace_suffix(".com", "")
      |> String.replace_suffix(".org", "")
      |> String.replace_suffix(".io", "")

    package = (uri.path || "/")
      |> String.trim_leading("/")
      |> String.trim_trailing("/")
      |> String.trim_trailing(".git")

    "#{ecosystem}:#{package}:latest"
  end

  @doc """
  cache_ttl_seconds/0: returns the cache TTL in seconds, derived from config.
  Uses LEI_CACHE_TTL_SECONDS if set, otherwise converts cache_ttl (days) to seconds.
  """
  def cache_ttl_seconds do
    Application.get_env(:lowendinsight_get, :cache_ttl_seconds,
      Application.get_env(:lowendinsight_get, :cache_ttl, 30) * 86400
    )
  end

  @doc """
  write_event/1: takes in a report and writes it as an event, incrementing the event
  counter.  Will return {:ok, id} - id being the current event counter on success, or
  {:error, reason} if there is an error writing to Redis.
  """
  def write_event(report) do
    case Redix.command(:redix, ["INCR", "event:id"]) do
      {:ok, id} ->
        Redix.command(:redix, ["SET", "event-#{id}", Poison.encode!(report)])
        Logger.debug("wrote event to redis -> #{Poison.encode!(report)}")
        {:ok, id}
    end
  end

  def write_job(uuid, report) do
    case Redix.command(:redix, ["SET", uuid, Poison.encode!(report)]) do
      {:ok, res} ->
        {:ok, res}
    end
  end

  def get_job(uuid) do
    ## NOTE: redix will return :ok even if key is not found, with
    ## the returned value as 'nil'
    case Redix.command(:redix, ["GET", uuid]) do
      {:ok, res} ->
        Logger.debug("get job #{uuid} -> #{res}")

        case res do
          nil -> {:error, "job not found"}
          _ -> {:ok, res}
        end
    end
  end

  @doc """
  write_to_cache/2: takes in a url as the key, and the analysis report as value.
  Stores under the structured cache key {ecosystem}:{package}:{version} with a
  Redis TTL. Returns {:ok, res} on success, or {:error, res} on write error.
  """
  def write_to_cache(url, report) do
    key = cache_key(url)
    ttl = cache_ttl_seconds()
    json = Poison.encode!(report)

    case Redix.command(:redix, ["SETEX", key, ttl, json]) do
      {:ok, res} ->
        Logger.debug("wrote report #{key} (url: #{url}, ttl: #{ttl}s)")
        {:ok, res}
    end
  end

  @doc """
  get_from_cache/2: takes in a url and age in days, queries the datastore
  using the structured cache key. Returns {:ok, report, :hit} on cache hit,
  {:error, message, :miss} on cache miss. Redis TTL handles expiry, but
  age-based validation is kept as a secondary check.
  """
  def get_from_cache(url, age) do
    key = cache_key(url)
    ## NOTE: redix will return :ok even if key is not found, with
    ## the returned value as 'nil'
    case Redix.command(:redix, ["GET", key]) do
      {:ok, res} ->
        Logger.debug("get report #{key} (url: #{url})")

        case res do
          nil ->
            {:error, "report not found", :miss}

          _ ->
            r = Poison.decode!(res)

            case too_old?(r, age) do
              true -> {:error, "current report not found", :stale}
              false -> {:ok, res, :hit}
            end
        end
    end
  end

  @doc """
  in_cache?/1: takes in a url and returns true in cache, false if not.
  Uses the structured cache key format.
  """
  def in_cache?(url) do
    key = cache_key(url)
    case Redix.command(:redix, ["EXISTS", key]) do
      {:ok, 1} -> true
      {:ok, 0} -> false
    end
  end

  @doc """
  too_old?/2: takes in a repo report and age in days and returns 'true' if the diff
  between the current datetime and the report end_time is greater than the
  provided age - or return 'false'
  """
  def too_old?(repo, age) do
    days =
      TimeHelper.get_commit_delta(repo["header"]["end_time"])
      |> TimeHelper.sec_to_days()

    days > age
  end
end
