defmodule DemoWeb.Guardian do
  use Guardian, otp_app: :demo
  alias Demo.Accounts

  def subject_for_token(%{agent_id: agent_id} = _resource, _claims) do
    {:ok, to_string(agent_id)}
  end
  def subject_for_token(_resource, _claims) do
    {:error, :invalid_resource}
  end

  def resource_from_claims(%{"sub" => agent_id} = _claims) do
    Accounts.get_agent(agent_id)
  end
  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
