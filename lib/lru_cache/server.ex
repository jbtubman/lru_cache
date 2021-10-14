defmodule LRUCache.Server do
  @moduledoc """
  This is a `GenServer` that is the intermediary between the client API `LRUCache`
  and the cache implementation `LRUCache.Impl`.
  """
  use GenServer
  alias LRUCache.Impl

  @type cache() :: Impl.cache()

  @spec init(pos_integer()) :: {:ok, cache()}
  def init(capacity) do
    cache = Impl.create(capacity)
    {:ok, cache}
  end

  def handle_call({:get, key}, _from, cache) do
    case Impl.get(cache, key) do
      {:ok, {value, updated_cache}} ->
        {:reply, {:ok, value}, updated_cache}

      {:error, {:not_found, cache}} ->
        {:reply, {:error, :not_found}, cache}
    end
  end

  def handle_call({:put, key, value}, _from, cache) do
    {:ok, {put_result, updated_cache}} = Impl.put(cache, key, value)
    {:reply, {:ok, put_result}, updated_cache}
  end
end
