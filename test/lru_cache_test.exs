defmodule LRUCacheTest do
  use ExUnit.Case
  doctest LRUCache

  test "greets the world" do
    assert LRUCache.hello() == :world
  end
end
