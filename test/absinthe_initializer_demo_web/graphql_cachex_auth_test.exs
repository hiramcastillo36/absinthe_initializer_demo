defmodule AbsintheInitializerDemoWeb.GraphqlCachexAuthTest do
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
  @sign_out_all "mutation { signOutAll { message } }"

  defp gql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("content-type", "application/json")
    |> post("/api", Jason.encode!(%{query: query, variables: variables}))
  end

  defp conn_ip do
    %{build_conn() | remote_ip: {10, 0, :rand.uniform(250), :rand.uniform(250)}}
  end

  test "authenticates via Bearer with Cachex caching and revokes via signOutAll" do
    conn =
      conn_ip()
      |> gql(@sign_up, %{email: "mobile@example.com", password: "super_secure_password_123"})

    assert %{"data" => %{"signUp" => %{"token" => token, "user" => %{"email" => "mobile@example.com"}}}} =
             json_response(conn, 200)

    # Bearer-only mode sets no session cookie
    assert conn.resp_cookies == %{}

    # Cachex holds the session user
    assert {:ok, %{email: "mobile@example.com"}} = SessionCache.get(token)

    me_conn =
      conn_ip()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@me)

    assert %{"data" => %{"me" => %{"email" => "mobile@example.com"}}} = json_response(me_conn, 200)

    # signOutAll clears Cachex and revokes token
    out_conn =
      conn_ip()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@sign_out_all)

    assert %{"data" => %{"signOutAll" => %{"message" => "All sessions revoked."}}} =
             json_response(out_conn, 200)

    assert SessionCache.get(token) == :miss
  end
end
