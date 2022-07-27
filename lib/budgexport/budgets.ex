defmodule Budgexport.Budgets do
  def get_budget_with_monthly_amount() do
    token = Application.get_env(:budgexport, :pat)
    url = "#{Application.get_env(:budgexport, :firefly_url)}/api/v1/budgets"
    headers = [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]
    IO.inspect(url)

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
