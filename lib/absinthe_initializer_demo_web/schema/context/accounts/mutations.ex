defmodule AbsintheInitializerDemoWeb.Schema.Context.Accounts.Mutations do
  @moduledoc """
  GraphQL mutations for user registration, sign in, and session revocation.
  """

  use Absinthe.Schema.Notation

  alias AbsintheInitializerDemoWeb.Resolvers
  alias AbsintheInitializerDemoWeb.Schema.Middleware

  object :account_mutations do
    @desc "Register a new user account and start a session."
    field :sign_up, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      middleware Middleware.RateLimit, action: :sign_up
      resolve &Resolvers.Accounts.sign_up/3
    end

    @desc "Authenticate an existing user and start a session."
    field :sign_in, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      middleware Middleware.RateLimit, action: :sign_in, by_arg: :email
      resolve &Resolvers.Accounts.sign_in/3
    end

    @desc "Revoke the current user session."
    field :sign_out, :sign_out_result do
      middleware Middleware.Authenticate
      resolve &Resolvers.Accounts.sign_out/3
    end

    @desc "Revoke all active sessions for the authenticated user across all devices."
    field :sign_out_all, :sign_out_result do
      middleware Middleware.Authenticate
      resolve &Resolvers.Accounts.sign_out_all/3
    end
  end
end
