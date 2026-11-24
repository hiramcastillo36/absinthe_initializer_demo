defmodule AbsintheInitializerDemoWeb.Schema.Context.Accounts.Queries do
  @moduledoc """
  GraphQL queries related to user accounts.
  """

  use Absinthe.Schema.Notation

  alias AbsintheInitializerDemoWeb.Resolvers
  alias AbsintheInitializerDemoWeb.Schema.Middleware

  object :account_queries do
    @desc "Returns the currently authenticated user."
    field :me, :user do
      middleware Middleware.Authenticate
      resolve &Resolvers.Accounts.me/3
    end
  end
end
