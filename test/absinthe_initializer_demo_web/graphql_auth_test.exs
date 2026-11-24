defmodule AbsintheInitializerDemoWeb.GraphqlAuthTest do
  use AbsintheInitializerDemoWeb.ConnCase, async: false

  alias AbsintheInitializerDemo.Accounts
  alias AbsintheInitializerDemo.Auth.SessionCache

  @sign_up """
  mutation SignUp($email: String!, $password: String!) {
    signUp(email: $email, password: $password) {
      token
      user { id email isAdmin }
    }
  }
  """

  @me "query { me { id email isAdmin } }"
  @sign_out "mutation { signOut { message } }"
  @sign_out_all "mutation { signOutAll { message } }"

  defp gql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("content-type", "application/json")
    |> post("/api", Jason.encode!(%{query: query, variables: variables}))
  end

  defp conn_ip(ip \\ nil) do
    %{build_conn() | remote_ip: ip || {10, 0, :rand.uniform(250), :rand.uniform(250)}}
  end

  test "signUp, Bearer + Cookie auth, ETS cache hit, CSRF check, and signOut" do
    conn =
      conn_ip()
      |> gql(@sign_up, %{email: "demo@example.com", password: "super_secure_password_123"})

    assert %{"data" => %{"signUp" => %{"token" => token, "user" => %{"email" => "demo@example.com"}}}} =
             json_response(conn, 200)

    assert %{value: ^token, http_only: true, path: "/"} =
             conn.resp_cookies["_absinthe_initializer_demo_session"]

    assert {:ok, _user} = SessionCache.get(token)

    # Bearer works
    bearer_conn =
      conn_ip()
      |> put_req_header("authorization", "Bearer #{token}")
      |> gql(@me)

    assert %{"data" => %{"me" => %{"email" => "demo@example.com"}}} =
             json_response(bearer_conn, 200)

    # Cookie works
    cookie_conn =
      conn_ip()
      |> put_req_cookie("_absinthe_initializer_demo_session", token)
      |> gql(@me)

    assert %{"data" => %{"me" => %{"email" => "demo@example.com"}}} =
             json_response(cookie_conn, 200)

    # Cross-site cookie blocked by CSRF check
    csrf_conn =
      conn_ip()
      |> put_req_header("sec-fetch-site", "cross-site")
      |> put_req_cookie("_absinthe_initializer_demo_session", token)
      |> gql(@me)

    assert %{"errors" => [%{"message" => "Cross-site cookie request rejected." <> _}]} =
             json_response(csrf_conn, 200)

    # Sign out revokes session + clears cookie + clears cache
    out_conn =
      conn_ip()
      |> put_req_cookie("_absinthe_initializer_demo_session", token)
      |> gql(@sign_out)

    assert %{"data" => %{"signOut" => %{"message" => "Signed out successfully."}}} =
             json_response(out_conn, 200)

    assert %{max_age: 0} = out_conn.resp_cookies["_absinthe_initializer_demo_session"]
    assert SessionCache.get(token) == :miss
  end

  test "signOutAll revokes all sessions and blocks invalid tokens" do
    {:ok, user} =
      Accounts.register_user(%{email: "multi@example.com", password: "super_secure_password_123"})

    t1 = Accounts.generate_user_session_token(user)
    t2 = Accounts.generate_user_session_token(user)

    conn = conn_ip() |> put_req_header("authorization", "Bearer #{t1}") |> gql(@sign_out_all)
    assert %{"data" => %{"signOutAll" => %{"message" => "All sessions revoked."}}} = json_response(conn, 200)

    for token <- [t1, t2] do
      c = conn_ip() |> put_req_header("authorization", "Bearer #{token}") |> gql(@me)
      assert %{"errors" => [%{"message" => "The session is invalid or expired."}]} = json_response(c, 200)
    end
  end
end
