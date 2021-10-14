defmodule LRUCache.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @prefix "/api"

  require Logger

  doctest LRUCache.Router

  alias LRUCache.Router

  alias LRUCache.{Entry, Impl}

  alias UUID

  defp make_entries() do
    [
      Entry.create("foo", "bar"),
      Entry.create(50, "fifty"),
      Entry.create("forty-two", 42)
    ]
  end

  defp make_cache(entries, capacity) do
    count = Enum.count(entries)
    capacity = max(count, capacity)
    struct(Impl, %{capacity: capacity, count: count, entries: entries})
  end

  defp cache_keys(cache) do
    Enum.map(cache.entries, & &1.key)
  end

  setup_all do
    %{opts: Router.init([])}
  end

  setup context do
    entries = make_entries()

    for entry <- entries do
      key =
        if is_binary(entry.key) or is_number(entry.key) do
          entry.key
        else
          Poison.encode!(entry.key)
        end

      value =
        if is_binary(entry.value) or is_number(entry.value) do
          entry.value
        else
          Poison.encode!(entry.value)
        end
      LRUCache.put(key, value)
    end

    Map.merge(
      context,
      %{
        entries: entries
      }
    )
  end

  describe "get" do
    test "get something not there", ctx do
      key = UUID.uuid1()

      conn =
        conn(:get, "#{@prefix}/#{key}")
        |> Router.call(ctx.opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "Not Found"
    end

    test "get something that is there", ctx do
      entry = List.last(ctx.entries)
      key = entry.key
      expected_value = entry.value

      conn =
        conn(:get, "#{@prefix}/" <> key)
        |> Router.call(ctx.opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert Poison.decode!(conn.resp_body) == expected_value
    end
  end

  describe "put" do
    test "put something not there", ctx do
      key = UUID.uuid1()
      value = UUID.uuid1()

      params = %{key: key, value: value}

      conn =
        conn(:post, "#{@prefix}", params)
        |> Router.call(ctx.opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert Poison.decode!(conn.resp_body) == "insert"
    end

    test "put update something already there", ctx do
      key = hd(ctx.entries).key
      value = UUID.uuid1()

      params = %{key: key, value: value}

      conn =
        conn(:post, "#{@prefix}", params)
        |> Router.call(ctx.opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert Poison.decode!(conn.resp_body) == "update"
    end
  end
end
