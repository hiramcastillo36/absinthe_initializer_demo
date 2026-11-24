# AbsintheInitializer Demo — `basic-no-auth`

This branch showcases the minimal GraphQL setup generated without authentication:

```bash
mix absinthe_initializer
```

- Adds `absinthe`, `absinthe_plug`, and `absinthe_phoenix` to `mix.exs`.
- Mounts `/api` (with complexity limit `200`) and `/graphiql` (dev only) in `router.ex`.
- Generates `Schema` (`query { hello }`) and `ChangesetErrors`.
- Does **not** generate accounts, migrations, plugs, caching, or rate limiting.

## Run with Docker Compose

```bash
docker compose up --build
```

```bash
curl -X POST http://localhost:4000/api \
  -H "Content-Type: application/json" \
  -d '{"query": "query { hello }"}'
```

See the [`main`](https://github.com/hiramcastillo36/absinthe_initializer) branch for the full branch comparison table.
