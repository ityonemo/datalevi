defmodule Datalevi.Repo do
  use Ecto.Repo,
    otp_app: :datalevi,
    adapter: Ecto.Adapters.Postgres
end
