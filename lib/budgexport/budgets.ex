defmodule Budgexport.Budgets do
  def get_budget_with_monthly_amount(:test), do: mock_budgets()
  def get_budget_with_monthly_amount(:dev), do: mock_budgets()
  def get_budget_with_monthly_amount(_), do: get_budget_with_monthly_amount()

  defp mock_budgets() do
    [
      {"1", "example1", "1.03"},
      {"2", "example1", "12.40"},
      {"3", "example1", "123.05"},
      {"4", "example1", "1234.40"},
      {"5", "example1", "12345.03"},
      {"6", "example1", "123456.20"},
      {"7", "example1", "1.343"}
    ]
  end

  defp get_budget_with_monthly_amount() do
    token = Application.get_env(:budgexport, :pat)
    url = "#{Application.get_env(:budgexport, :firefly_url)}/api/v1/budgets"
    headers = [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} -> evaluate_budgets(body)
      _ -> {:error, :http_error}
    end
  end

  defp evaluate_budgets(response) do
    response
    |> Poison.decode!()
    |> Map.get("data", [])
    |> Enum.map(&get_name_and_amount/1)
  end

  defp get_name_and_amount(%{"attributes" => atts, "id" => id}), do: get_name_and_amount(atts, id)
  defp get_name_and_amount(_budget), do: get_name_and_amount(%{}, nil)

  defp get_name_and_amount(%{"name" => n, "auto_budget_amount" => nil}, id), do: {id, n, "0.00"}
  defp get_name_and_amount(%{"name" => n, "auto_budget_amount" => a}, id), do: {id, n, a}
  defp get_name_and_amount(_budget, _), do: {"invalid", nil}
end
