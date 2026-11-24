# AbsintheInitializer Demo — `auth-cookie-only`

This branch showcases **HttpOnly Cookie-only** authentication (ideal for browser SPAs):

```bash
mix absinthe_initializer --auth --auth-transport cookie --cache ets
```

- Sets `transport: :cookie` in `config/config.exs`.
- `signUp` and `signIn` deliver the session token exclusively via an `HttpOnly` cookie and strip `token` (`null`) from the JSON response body.
- `Authorization: Bearer` headers are ignored; cookie CSRF checks (`Sec-Fetch-Site` + `Content-Type: application/json`) are enforced.
- Uses zero-dependency ETS session cache and ETS rate limiting.

## Run with Docker Compose

```bash
docker compose up --build
```

```bash
curl -i -c cookies.txt -X POST http://localhost:4000/api \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation($e:String!,$p:String!){signUp(email:$e,password:$p){token user{id email}}}","variables":{"e":"spa@example.com","p":"super_secure_password_123"}}'

curl -b cookies.txt -X POST http://localhost:4000/api \
  -H "Content-Type: application/json" \
  -d '{"query":"query { me { id email } }"}'
```
