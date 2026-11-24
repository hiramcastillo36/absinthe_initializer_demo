defmodule AbsintheInitializerDemoWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types AbsintheInitializerDemoWeb.Schema.Context.Accounts.Types
  import_types AbsintheInitializerDemoWeb.Schema.Context.Accounts.Queries
  import_types AbsintheInitializerDemoWeb.Schema.Context.Accounts.Mutations

  query do
    import_fields :account_queries
  end

  mutation do
    import_fields :account_mutations
  end
end
