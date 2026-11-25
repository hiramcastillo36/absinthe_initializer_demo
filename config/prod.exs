import Config

# Enforce HTTPS in production (satisfies Sobelow Config.HTTPS)
config :absinthe_initializer_demo, AbsintheInitializerDemoWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Req

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
