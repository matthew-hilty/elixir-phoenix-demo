defmodule DemoWeb.Api.PharmacyView do
  use DemoWeb, :view

  def render("create.json", %{pharmacy: pharmacy}) do
    %{created: %{pharmacy: ToJson.to_json(pharmacy)}}
  end

  def render("index.json", %{pharmacies: pharmacies}) do
    %{ count: length(pharmacies),
       pharmacies: ToJson.to_json(pharmacies),
     }
  end

  def render("show.json", %{pharmacy: pharmacy}) do
    %{pharmacy: ToJson.to_json(pharmacy)}
  end
end
