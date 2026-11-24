defmodule AbsintheInitializerDemoWeb.GraphqlBasicTest do
  use AbsintheInitializerDemoWeb.ConnCase, async: true

  test "resolves basic GraphQL hello query without auth" do
    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api", Jason.encode!(%{query: "query { hello }"}))

    assert %{"data" => %{"hello" => "world"}} = json_response(conn, 200)
  end
end
