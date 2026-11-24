defmodule AbsintheInitializerDemoWeb.Router do
  use AbsintheInitializerDemoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug AbsintheInitializerDemoWeb.Plugs.SetCurrentUser
  end

  scope "/" do
    pipe_through :api

    forward "/api",
      Absinthe.Plug,
      schema: AbsintheInitializerDemoWeb.Schema,
      analyze_complexity: true,
      max_complexity: 200,
        before_send: {AbsintheInitializerDemoWeb.Plugs.AuthCookie, :before_send}
  end

  if Application.compile_env(:absinthe_initializer_demo, :dev_routes) do
    scope "/" do
      pipe_through :api

      forward "/graphiql",
        Absinthe.Plug.GraphiQL,
        schema: AbsintheInitializerDemoWeb.Schema,
        before_send: {AbsintheInitializerDemoWeb.Plugs.AuthCookie, :before_send}
    end
  end

  scope "/api", AbsintheInitializerDemoWeb do
    pipe_through :api
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:absinthe_initializer_demo, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
