defmodule LRUCache.Router do
  use Plug.Router
  use Plug.ErrorHandler

  @prefix "/api"

  alias LRUCache

  require Logger

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get("#{@prefix}/:key") do
    key = Map.get(conn.params, "key")
    Logger.info("GET #{@prefix}/#{inspect(key)}")

    return_model(conn, LRUCache.get(key))
  end

  post("#{@prefix}") do
    key = Map.get(conn.params, "key")
    value = Map.get(conn.params, "value")
    Logger.info("POST #{@prefix} - key: #{inspect(key)}, value: #{inspect(value)}")

    return_model(conn, LRUCache.put(key, value))
  end

  @spec return_model(Plug.Conn.t(), {:error, any} | {:ok, any}) :: Plug.Conn.t()
  defp return_model(conn, {:ok, value}) do
    case Poison.encode(value) do
      {:ok, json} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json)

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(400, inspect(error))
    end
  end

  defp return_model(conn, {:error, :not_found}) do
    conn
        |> put_resp_content_type("text/plain")
        |> send_resp(404, "Not Found")
  end

  defp return_model(conn, {:error, error}) do
    conn
        |> put_resp_content_type("text/plain")
        |> send_resp(400, inspect(error))
  end
end
