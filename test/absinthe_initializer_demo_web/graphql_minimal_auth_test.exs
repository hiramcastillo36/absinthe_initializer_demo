defmodule AbsintheInitializerDemoWeb.GraphqlMinimalAuthTest do
  use AbsintheInitializerDemoWeb.ConnCase, async: false

  alias AbsintheInitializerDemo.Auth.SessionCache

  @sign_up """
  mutation SignUp($email: String!, $password: String!) {
    signUp(email: $email, password: $password) {
      token
      user { id email }
    }
  }
  """

  @me "query { me { id email } }"
  @sign_out "mutation { signOut { message } }"

  defp gql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("content-type", "application/json")
    |> post("/api", Jason.encode!(%{query: query, variables: variables}))
  end

  test "authenticates directly against Postgres with cache :none and no rate limiter" do
    conn =
      build_conn()
      |> gql(@sign_up, %{email: "min@example.com", password: "super_secure_password_123"})

    assert %{"data" => %{"signUp" => %{"token" => token, "user" => %{"email" => "min@example.com"}}}} =
             json_response(conn, 200)

    # Cache is disabled (:none -> always :miss)
    assert SessionCache.get(token) == :miss

    me_conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@me)

    assert %{"data" => %{"me" => %{"email" => "min@example.com"}}} = json_response(me_conn, 200)

    out_conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@sign_out)

    assert %{"data" => %{"signOut" => %{"message" => "Signed out successfully."}}} =
             json_response(out_conn, 200)

    reused =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@me)

    assert %{"errors" => [%{"message" => "The session is invalid or expired."}]} =
             json_response(reused, 200)
  end
end
