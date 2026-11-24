# AbsintheInitializer Demo — `auth-bearer-cachex`

This branch showcases **Bearer-only** authentication backed by **Cachex**:

```bash
mix absinthe_initializer --auth --auth-transport bearer --cache cachex
```

- Sets `transport: :bearer` and `cache: :cachex` in `config/config.exs`.
- Adds `{:cachex, "~> 4.0"}` to `mix.exs` and `{Cachex, name: :absinthe_initializer_demo_session_cache}` to `application.ex`.
- Does **not** generate `AuthCookie` plug/middleware or set response cookies.
- Enforces ETS rate limiting on `signUp`, `signIn` (IP + email), and invalid token spraying.

## Run with Docker Compose

```bash
docker compose up --build
```

```bash
curl -X POST http://localhost:4000/api \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation($e:String!,$p:String!){signUp(email:$e,password:$p){token user{id email}}}","variables":{"e":"mobile@example.com","p":"super_secure_password_123"}}'

curl -X POST http://localhost:4000/api \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"query":"query { me { id email } }"}'
```
