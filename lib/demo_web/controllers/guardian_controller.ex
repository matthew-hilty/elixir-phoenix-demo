defmodule DemoWeb.GuardianController do
  import Utilities, only: [prohibit_nil: 1]

  alias Demo.Accounts.Agent
  alias DemoWeb.Guardian.Plug, as: GuardianPlug
  alias DemoWeb.Guardian
  alias Plug.Conn

  @error :error
  @not_authenticated :not_authenticated
  @ok :ok

  def authenticate_agent(%Conn{assigns: %{agent: (%Agent{} = agent)}}) do
    {@ok, agent}
  end
  def authenticate_agent(_conn) do
    {@error, @not_authenticated}
  end

  def identify_agent(%Conn{} = conn) do
    with {@ok, token} <- conn |> GuardianPlug.current_token() |> prohibit_nil(),
         {@ok, (%Agent{} = agent), _claims} <- Guardian.resource_from_token(token) do
      {@ok, agent}
    else
      _ ->
        {@error, @not_authenticated}
    end
  end
end
