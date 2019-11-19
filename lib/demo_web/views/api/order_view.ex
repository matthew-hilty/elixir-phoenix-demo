defmodule DemoWeb.Api.OrderView do
  use DemoWeb, :view

  @all :all
  @order_state :order_state
  @order_state_description :order_state_description

  def render("cancel.json", %{order: order}) do
    %{canceled: %{order: ToJson.to_json(order)}}
  end

  def render("create.json", %{order: order}) do
    %{created: %{order: ToJson.to_json(order)}}
  end

  def render("deliver.json", %{order: order}) do
    %{delivered: %{order: ToJson.to_json(order)}}
  end

  def render("index.json", %{orders: orders, query_params: query_params}) do
    %{ count: length(orders),
       orders: ToJson.to_json(orders),
       query_params: display_query_params(query_params),
     }
  end

  def render("mark_undeliverable.json", %{order: order}) do
    %{undeliverable: %{order: ToJson.to_json(order)}}
  end

  def render("show.json", %{order: order}) do
    %{order: ToJson.to_json(order)}
  end

  defp display_query_params(%{order_state_description: @all} = query_params) do
    query_params
    |> Map.delete(@order_state_description)
    |> Map.put(@order_state, "all")
  end
  defp display_query_params(%{order_state_description: description} = query_params) do
    query_params
    |> Map.delete(@order_state_description)
    |> Map.put(@order_state, description)
  end
  defp display_query_params(query_params), do: query_params
end
