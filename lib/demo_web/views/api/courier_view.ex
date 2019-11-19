defmodule DemoWeb.Api.CourierView do
  use DemoWeb, :view

  def render("create.json", %{courier: courier}) do
    %{created: %{courier: ToJson.to_json(courier)}}
  end

  def render("index.json", %{couriers: couriers}) do
    %{ count: length(couriers),
       couriers: ToJson.to_json(couriers),
     }
  end

  def render("show.json", %{courier: courier}) do
    %{courier: ToJson.to_json(courier)}
  end
end
