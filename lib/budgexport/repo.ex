defmodule Budgexport.Repo do
  use Ecto.Repo,
    otp_app: :budgexport,
    adapter: Ecto.Adapters.Postgres
end
