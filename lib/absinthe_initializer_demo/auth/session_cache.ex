defmodule AbsintheInitializerDemo.Auth.SessionCache do
  @moduledoc """
  Behaviour and facade for caching resolved session users.

  Configure the adapter in `config/config.exs`:

      config :absinthe_initializer_demo, AbsintheInitializerDemo.Auth,
        cache: :ets # :ets | :cachex | :none | MyCustomCacheModule
  """

  alias AbsintheInitializerDemo.Auth.Config

  @callback get(token :: String.t()) :: {:ok, struct()} | :miss
  @callback put(token :: String.t(), user :: struct(), ttl_seconds :: pos_integer()) :: :ok
  @callback delete(token :: String.t()) :: :ok
  @callback delete_user_sessions(user_id :: term()) :: :ok

  def get(token) do
    case adapter() do
      nil -> :miss
      mod -> mod.get(token)
    end
  end

  def put(token, user, ttl_seconds \\ Config.cache_ttl_seconds()) do
    case adapter() do
      nil -> :ok
      mod -> mod.put(token, user, ttl_seconds)
    end
  end

  def delete(token) do
    case adapter() do
      nil -> :ok
      mod -> mod.delete(token)
    end
  end

  def delete_user_sessions(user_id) do
    case adapter() do
      nil -> :ok
      mod -> mod.delete_user_sessions(user_id)
    end
  end

  defp adapter do
    case Config.cache() do
      :none -> nil
      :ets -> AbsintheInitializerDemo.Auth.SessionCache.ETS
      :cachex -> AbsintheInitializerDemo.Auth.SessionCache.Cachex
      mod when is_atom(mod) -> mod
    end
  end
end
