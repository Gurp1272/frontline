defmodule Frontline.Repo do
  use Ecto.Repo,
    otp_app: :frontline,
    adapter: Ecto.Adapters.Postgres
end
