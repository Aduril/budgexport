defmodule Budgexport.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :auto_amount, :string
    # field :firefly_id, :string
    field :name, :string
    field :total_amount, :string
    # timestamps()
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :auto_amount, :total_amount, :firefly_id])
    |> validate_required([:name, :auto_amount, :total_amount, :firefly_id])
  end
end
