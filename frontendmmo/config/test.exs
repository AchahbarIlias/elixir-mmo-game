import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :frontendmmo, FrontendmmoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6rc6AN8ps8gpC6m0+MJuocG6A0TEdGcLBzPLQBa9bNQadZ8hh5OVoTwKDqwGI1UJ",
  server: false

# In test we don't send emails.
config :frontendmmo, Frontendmmo.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
