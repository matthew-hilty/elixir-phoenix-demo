# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :demo,
  ecto_repos: [Demo.Repo]

# Configures the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZZMSGnkc3iCnqTd1Xl84slJ08+WFWXqZ3A0AqjFoy+c4s2Cahr4vVRSpJdbBsOd2",
  render_errors: [view: DemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Demo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :mime, :types, %{
  "application/json" => ["json"],
  "text/csv" => ["csv"]
}

config :demo, DemoWeb.Guardian,
  issuer: "Demo",
  secret_key: "MDLMflIpKod5YCnkdiY7C4E3ki2rgcAAMwfBl0+vyC5uqJNgoibfQmAh7J3uZWVK",
  # optional
  allowed_algos: ["HS256"],
  ttl: {1, :minutes},
  allowed_drift: 2000,
  verify_issuer: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
