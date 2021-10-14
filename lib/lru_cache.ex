defmodule LRUCache do
  @moduledoc """
  Top-level API for the Least-Recently-Used Cache.

  These functions invoke `GenServer` calls to `LRUCache.Server`.

  The mechanics of the cache are found in `LRUCache.Impl`.

  The state of the cache is maintained in the GenServer and is not
  visible to the client, or required in the function arguments in
  this module.
  """

  @server LRUCache.Server

  @typedoc """
  A type that can be used as a key. Currently anything.
  """
  @type key() :: any()

  @typedoc """
  A type that can be used as a value. Currently anything.
  """
  @type value() :: any()

  @typedoc """
  `:insert` or `:update`
  """
  @type put_result() :: :insert | :update

  @doc """
  Required so that `#{__MODULE__}` can be called as a child of the `Application`.
  """
  @spec child_spec(any) :: %{
          id: LRUCache,
          restart: :permanent,
          shutdown: 500,
          start: {LRUCache, :start_link, [...]},
          type: :worker
        }
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Starts a `#{__MODULE__}` process linked to the application.
  """
  @spec start_link(pos_integer) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(capacity) when is_integer(capacity) and capacity > 0 do
    GenServer.start_link(@server, capacity, name: @server)
  end

  @doc """
  Gets the value associated with _key_ from the cache.
  Returns `{:ok, value}` if it is in the cache or `{:error, :not_found}` otherwise.
  """
  @spec get(key()) :: {:ok, value()} | {:error, :not_found}
  def get(key) do
    GenServer.call(@server, {:get, key})
  end

  @doc """
  Puts the key/value pair into the cache.
  If the key was not previously present in the cache, returns `{:ok, :insert}`.
  Otherwise, returns `{:ok, :update}`.
  """
  @spec put(key(), value()) :: {:ok, put_result()}
  def put(key, value) do
    GenServer.call(@server, {:put, key, value})
  end
end
