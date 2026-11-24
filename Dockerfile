FROM elixir:1.18.3-otp-27

RUN apt-get update -y && apt-get install -y --no-install-recommends git build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock* ./
RUN mix deps.get

COPY . .

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
