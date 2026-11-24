# AbsintheInitializer Demo — `auth-minimal`

This branch showcases **minimal Bearer authentication** (direct PostgreSQL lookup, no cache, no ETS rate limiter):

```bash
mix absinthe_initializer --auth --auth-transport bearer --cache none --no-rate-limit
```

- Sets `transport: :bearer`, `cache: :none`, and `rate_limit: [enabled: false, ...]` in `config/config.exs`.
- Does **not** add any extra supervision children to `application.ex` (no ETS cache, no Cachex, no RateLimiter).
- Still hashes session tokens with SHA-256 in PostgreSQL, prevents `is_admin` mass assignment, protects `/graphiql` behind `:dev_routes`, and enforces GraphQL complexity limits.

## Run with Docker Compose

```bash
docker compose up --build
```
