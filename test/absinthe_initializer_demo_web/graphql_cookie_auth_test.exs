defmodule AbsintheInitializerDemoWeb.GraphqlCookieAuthTest do
  use AbsintheInitializerDemoWeb.ConnCase, async: false

  @sign_up """
  mutation SignUp($email: String!, $password: String!) {
    signUp(email: $email, password: $password) {
      token
      user { id email }
    }
  }
  """

  @me "query { me { id email } }"

  defp gql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("content-type", "application/json")
    |> post("/api", Jason.encode!(%{query: query, variables: variables}))
  end

  defp conn_ip do
    %{build_conn() | remote_ip: {10, 0, :rand.uniform(250), :rand.uniform(250)}}
  end

  test "delivers session strictly via HttpOnly cookie, strips JSON token, and ignores Bearer" do
    conn =
      conn_ip()
      |> gql(@sign_up, %{email: "spa@example.com", password: "super_secure_password_123"})

    assert %{"data" => %{"signUp" => %{"token" => nil, "user" => %{"email" => "spa@example.com"}}}} =
             json_response(conn, 200)

    assert %{value: cookie_token, http_only: true, path: "/"} =
             conn.resp_cookies["_absinthe_initializer_demo_session"]

    # Cookie works
    ok_conn =
      conn_ip()
      |> put_req_cookie("_absinthe_initializer_demo_session", cookie_token)
      |> gql(@me)

    assert %{"data" => %{"me" => %{"email" => "spa@example.com"}}} = json_response(ok_conn, 200)

    # Bearer header is ignored in cookie-only mode
    rejected =
      conn_ip()
      |> put_req_header("authorization", "Bearer #{cookie_token}")
      |> gql(@me)

    assert %{"errors" => [%{"message" => "Please sign in first!"}]} = json_response(rejected, 200)
  end
end
