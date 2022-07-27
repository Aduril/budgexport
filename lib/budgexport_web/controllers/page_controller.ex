defmodule BudgexportWeb.PageController do
  use BudgexportWeb, :controller

  def index(conn, _params) do
    budgets = Budgexport.Budgets.get_budget_with_monthly_amount()

    budget_sum =
      budgets
      |> Enum.reduce(0, fn {_, v}, acc -> String.to_float(v) + acc end)
      |> :erlang.float_to_binary(decimals: 2)

    conn
    |> Plug.Conn.assign(:budgets, budgets)
    |> Plug.Conn.assign(:budget_sum, budget_sum)
    |> render("index.html")
  end
end
