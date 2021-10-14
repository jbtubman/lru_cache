defmodule LRUCache.Entry do
  @moduledoc """
  Cache entry.
  """

  alias __MODULE__
  alias LRUCache

  @type key() :: LRUCache.key()

  @type value() :: LRUCache.value()

  @enforce_keys [:key, :value]
  defstruct key: "", value: nil

  @type t() :: %__MODULE__{
    key: key(),
    value: value()
  }

  @spec create(key(), value()) :: t()
  def create(key, value) do
    struct(Entry, %{key: key, value: value})
  end

  @spec update_value(t(), value()) :: t()
  def update_value(%Entry{} = entry, value) do
    create(entry.key, value)
  end

end
