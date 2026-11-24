defmodule AbsintheInitializerDemo.Repo do
  use Ecto.Repo,
    otp_app: :absinthe_initializer_demo,
    adapter: Ecto.Adapters.Postgres
end
