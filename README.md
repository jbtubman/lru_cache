# LRUCache

This is my answer to the Validere Coding Assignment.

## Implementation

The cache is implemented simply, using an Elixir list, with the most recently used entries
at the beginning of the list. Operations are O(_n_).

The code that implements the cache is found in [`LRUCache.Impl`](./lib/lru_cache/impl.ex).

The cache state is maintained by a [`GenServer`](https://hexdocs.pm/elixir/GenServer.html#content)
defined in [`LRUCache.Server`](./lib/lru_cache/server.ex).

The client API is defined in [`LRUCache`](./lib/lru_cache.ex). The user of this API does not need
to know anything about how the cache is implemented.

## Installation

The code is [available on GitHub](https://github.com/jbtubman/lru_cache.git).
The package can be installed by adding `lru_cache` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lru_cache, git: "https://github.com/jbtubman/lru_cache.git"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc):

```bash
mix docs
```

Once generated, the documentation can be found [here](./doc/index.html).

## Operation

From inside the `lru_cache` directory, execute the command

```bash
iex -S mix
```

This will start the GenServer and the web server, which listens on port 2044.

Cache commands can be entered at the `iex>` prompt.

```elixir
iex> LRUCache.put("smile", 88)
{:ok, :insert}
iex> LRUCache.put("smile", 99)
{:ok, :update}
iex> LRUCache.get("smile")
{:ok, 99}
```

The cache can also be accessed via a RESTful API. For example, if the environment variables are set
as shown below, the API can be invoked using the `curl` utility.

```bash
$ export k=$(uuidgen)
$ export params="{\"key\": \"${k}\", \"value\": 50}"
$ curl -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' --data-raw ${params} http://localhost:2044/api
"insert"
$ curl -X GET -H 'Content-Type: application/json' -H 'Accept: application/json' http://localhost:2044/api/${k}
50
```

## Alternatives

The return values for `LRUCache.put/2` might have been richer than they are.

Things like the web server's port number could have been taken from a configuration file.

Only strings and integers work as keys via the RESTful API.

The code has not been tested for concurrent access from clients on different nodes.
It was implemented as a GenServer so in principle it should work, but one really cannot
say without actually trying it.