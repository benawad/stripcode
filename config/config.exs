# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :only_codes,
  ecto_repos: [OnlyCodes.Repo]

# Configures the endpoint
config :only_codes, OnlyCodesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4QodeqtjYrnfsWt1ZyGNf6jwAX/MjctjOKLZT6UajVR7J2lPAr5kfp4+sCZavuCq",
  render_errors: [view: OnlyCodesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: OnlyCodes.PubSub,
  live_view: [signing_salt: "1vfKGl36"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
