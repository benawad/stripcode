defmodule OnlyCodes.Repo do
  use Ecto.Repo,
    otp_app: :only_codes,
    adapter: Ecto.Adapters.Postgres
end
