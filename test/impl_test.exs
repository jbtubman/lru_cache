defmodule LRUCache.ImplTest do
  use ExUnit.Case, async: true
  doctest LRUCache.Impl

  require Logger

  alias LRUCache.{Entry, Impl}

  defp make_entries() do
    [
      Entry.create(:foo, :bar),
      Entry.create(:bing, :bang),
      Entry.create(:boop, 42)
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

  describe "get tests" do
    test "get fails" do
      cache = make_entries() |> make_cache(5)

      assert {:error, {:not_found, ^cache}} = Impl.get(cache, :pow)
    end

    test "get succeeds - first entry" do
      cache = make_entries() |> make_cache(5)
      %Entry{key: first_key, value: first_value} = hd(cache.entries)

      assert {:ok, {^first_value, updated_cache}} = Impl.get(cache, first_key)
      first_entry = hd(updated_cache.entries)
      assert %Entry{key: ^first_key, value: ^first_value} = first_entry
    end

    test "get succeeds - second entry" do
      cache = make_entries() |> make_cache(5)
      # Logger.error("initial cache: #{inspect(cache, pretty: true)}")
      %Entry{key: second_key, value: second_value} = Enum.fetch!(cache.entries, 1)

      assert {:ok, {^second_value, updated_cache}} = Impl.get(cache, second_key)
      # Logger.error("updated cache: #{inspect(updated_cache, pretty: true)}")
      first_entry = hd(updated_cache.entries)
      assert %Entry{key: ^second_key, value: ^second_value} = first_entry
    end
  end
end
