defmodule BudgexportWeb.BudgetLive do
  use BudgexportWeb, :live_view

  alias Budgexport.Budgets.BudgetList

  def mount(_params, _session, socket) do
    budgets = Budgexport.Budgets.get_budget_with_monthly_amount() |> create_changeset()

    socket
    |> assign(:budget_sum, get_budget_sum(budgets))
    |> assign(:changeset, budgets)
    |> (&{:ok, &1}).()
  end

  def render(assigns) do
    BudgexportWeb.PageView.render("index.html", assigns)
  end

  defp create_changeset(budgets) do
    budgets
    |> Enum.map(&tuple_to_budget_map/1)
    |> (&BudgetList.changeset(%BudgetList{}, %{budgets: &1})).()
  end

  defp get_budget_sum(budget_list) do
    budget_list
    |> Ecto.Changeset.get_field(:budgets)
    |> Enum.reduce(0, &sum_active_budgets/2)
    |> :erlang.float_to_binary(decimals: 2)
  end

  defp sum_active_budgets(%{is_active: false}, acc), do: acc
  defp sum_active_budgets(%{auto_amount: amount}, acc), do: acc + amount

  defp tuple_to_budget_map({index, name, auto_amount}, is_active \\ true) do
    %{
      firefly_id: index,
      name: name,
      auto_amount: String.to_float(auto_amount),
      is_active: is_active
    }
  end

  def handle_event("change_active", params, socket) do
    socket
    |> update_budgets(params)
    |> (&{:noreply, &1}).()
  end

  def handle_event("sortby", %{"sortby" => field}, socket) do
    socket
    |> sort_by_field(field)
    |> (&{:noreply, &1}).()
  end

  def handle_event(a, b, socket) do
    a |> IO.inspect()
    b |> IO.inspect()
    {:noreply, socket}
  end

  defp update_budgets(socket, params) do
    form_budgets = params |> get_in(["budget_list", "budgets"]) |> Map.values()

    updated_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:budgets)
      |> Enum.map(&update_active_state(&1, form_budgets))
      |> (&BudgetList.changeset(socket.assigns.changeset, %{budgets: &1})).()

    socket
    |> assign(:changeset, updated_changeset)
    |> assign(:budget_sum, get_budget_sum(updated_changeset))
  end

  defp update_active_state(%{firefly_id: firefly_id} = budget, form_budgets) do
    form_budgets
    |> Enum.find(fn %{"firefly_id" => fid} -> firefly_id === fid end)
    |> (&Map.put(budget, :is_active, &1["is_active"] === "true")).()
    |> Map.from_struct()
  end

  defp sort_by_field(socket, "name"), do: sort_budgets_by(socket, :name)
  defp sort_by_field(socket, "active"), do: sort_budgets_by(socket, :is_active)
  defp sort_by_field(socket, "auto_amount"), do: sort_budgets_by(socket, :auto_amount)
  defp sort_by_field(socket, _), do: socket

  defp sort_budgets_by(socket, field) do
    socket
    |> assign_order(field)
    |> sort_changeset(field)
  end

  defp assign_order(socket, field) do
    if socket.assigns[:order_by] === field do
      socket |> change_order()
    else
      socket
      |> assign(:order, :desc)
      |> assign(:order_by, field)
    end
  end

  defp change_order(%{assigns: %{order: :asc}} = socket), do: assign(socket, :order, :desc)
  defp change_order(%{assigns: %{order: :desc}} = socket), do: assign(socket, :order, :asc)
  defp change_order(socket), do: assign(socket, :order, :desc)

  defp sort_changeset(socket, field) do
    sorted_changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:budgets)
      |> Enum.map(&Map.from_struct/1)
      |> Enum.sort_by(fn budget -> budget[field] end, socket.assigns.order)
      |> (&BudgetList.changeset(socket.assigns.changeset, %{budgets: &1})).()

    assign(socket, :changeset, sorted_changeset)
  end
end
