# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :absinthe_initializer_demo,
  ecto_repos: [AbsintheInitializerDemo.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :absinthe_initializer_demo, AbsintheInitializerDemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: AbsintheInitializerDemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AbsintheInitializerDemo.PubSub,
  live_view: [signing_salt: "7zuViQwV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :absinthe_initializer_demo, AbsintheInitializerDemo.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
config :absinthe_initializer_demo, AbsintheInitializerDemo.Auth,
  transport: :bearer,
  cookie_name: "_absinthe_initializer_demo_session",
  cookie_opts: [
    http_only: true,
    secure: config_env() == :prod,
    same_site: "Lax",
    path: "/",
    max_age: 604_800
  ],
  csrf_protection: true,
  trust_proxy: false,
  session_ttl_days: 7,
  cache: :none,
  cache_ttl_seconds: 300,
  rate_limit: [enabled: false, max_requests: 10, window_seconds: 60]

import_config "#{config_env()}.exs"
