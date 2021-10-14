defmodule LRUCache.Impl do
  @moduledoc """
  Implementation of the least-recently-used cache.

  The implementation is a naive list-based one.
  Operations are O(n).

  The API has been designed with usability with `GenServer` in mind.
  """
  alias LRUCache
  alias LRUCache.Entry
  alias __MODULE__

  @type key() :: LRUCache.key()
  @type value() :: LRUCache.value()

  # Arbitary UUID to indicate that a value was not found.
  @not_found "D2DD458D-EE23-43BE-88AF-0791645B1999"

  @enforce_keys [:capacity, :count, :entries]
  defstruct capacity: 5, count: 0, entries: []

  @typedoc """
  A cache with a capacity, a list of entries (ordered from most-recently-used to least),
  and a count of the elements in that list.
  """
  @type t() :: %__MODULE__{
    capacity: pos_integer(),
    count: non_neg_integer(),
    entries: [Entry.t()]
  }

  @typedoc """
  A more intuitive way of referring to this type.
  """
  @type cache() :: t()

  @typedoc """
  `:insert` or `:update`
  """
  @type put_result() :: LRUCache.put_result()

  @doc """
  Returns a `#{__MODULE__}` with the given maximum capacity and no entries.
  """
  @spec create(pos_integer) :: cache()
  def create(capacity) when is_integer(capacity) and capacity > 0 do
    struct(Impl, %{capacity: capacity, count: 0, entries: []})
  end


  @doc """
  Searches the cache for an entry with the given key.

  ### Cases to Consider:

  - The item with the key is not there.
    - Return `{:error, {:not_found, cache}}` with _cache_ unchanged.
  - The item with the key is there.
    - Remove the entry from the cache list.
    - Update the access time of the entry.
    - Push the new entry to the front of the cache list.
    - Return `{:ok, {value, updated_cache}}`

  """
  @spec get(cache(), key()) :: {:ok, {value(), cache()}} | {:error, {:not_found, cache()}}
  def get(cache, key) do
    entry = Enum.find(cache.entries, @not_found, fn %Entry{key: k} -> k == key end)

    case entry do
      @not_found ->
        {:error, {:not_found, cache}}

      %Entry{key: ^key, value: value} = entry ->

        updated_entries =
          cache.entries
          |> List.delete(entry)
          |> List.insert_at(0, entry)

        updated_cache = Map.update(cache, :entries, updated_entries, fn _ -> updated_entries end)

        {:ok, {value, updated_cache}}
    end
  end

  @doc """
  Puts or updates a key/value pair in the cache.

  ### Cases to Consider:

  - If the key is already in the cache, remove its entry,
    create a new one with the new value,
    and put it at the front of the entries list.
  - If the key is not in the cache:
    - If the count == capacity, remove the last entry from the list; otherwise leave the list alone.
    - Update the entry with the new value.
    - Put the new entry to the front of the list and adjust the counters accordingly.
  """
  @spec put(cache(), key(), value()) :: {:ok, {put_result(), cache()}}
  def put(cache, key, value) do
    case get(cache, key) do
      {:ok, {_old_value, %Impl{} = updated_cache}} ->
        do_update(updated_cache, value)

      {:error, {:not_found, old_cache}} ->
        do_insert(old_cache, key, value)
    end
  end

  defp do_update(updated_cache, value) do
    entry =
      updated_cache.entries
      |> hd()
      |> Entry.update_value(value)

    new_cache =
      Map.update(updated_cache, :entries, [entry], fn [_ | entries] -> [entry | entries] end)

    {:ok, {:update, new_cache}}
  end

  defp do_insert(old_cache, key, value) do
    cache_full? = old_cache.capacity == old_cache.count

    entries =
      if cache_full? do
        if Enum.empty?(old_cache.entries) do
          []
        else
          List.pop_at(old_cache.entries, -1) |> elem(1)
        end
      else
        old_cache.entries
      end

    entry = Entry.create(key, value)

    new_cache =
      old_cache
      |> Map.update(:entries, [entry], fn _ -> [entry | entries] end)
      |> Map.update(:count, 1, fn count -> count + 1 end)

    {:ok, {:insert, new_cache}}
  end
end
