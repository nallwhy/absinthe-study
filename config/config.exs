# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :plate_slate,
  ecto_repos: [PlateSlate.Repo]

# Configures the endpoint
config :plate_slate, PlateSlateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WQvslvHE3rHz2zlPtWVknL+1yLN290GA92CZ717fUPOn8CD+4P9KG0JE/PpzbrJP",
  render_errors: [view: PlateSlateWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: PlateSlate.PubSub,
  live_view: [signing_salt: "0bO7Le8R"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
