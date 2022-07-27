defmodule Budgexport.Budgets.BudgetList do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    embeds_many :budgets, Budget do
      field :firefly_id, :string
      field :name, :string
      field :auto_amount, :float
      field :is_active, :boolean
    end
  end

  @doc false
  def changeset(budget_list, attrs) do
    budget_list
    |> cast(attrs, [])
    |> cast_embed(:budgets, required: true, with: &budget_changeset/2)

    # |> validate_required([:budgets])
  end

  def budget_changeset(budget, attrs \\ %{}) do
    budget
    |> cast(attrs, [:firefly_id, :name, :auto_amount, :is_active])
    |> validate_required([:firefly_id, :name, :auto_amount, :is_active])
  end
end
