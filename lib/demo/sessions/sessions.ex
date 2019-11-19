defmodule Demo.Sessions do
  @moduledoc """
  The Sessions context.
  """

  alias Demo.Repo
  alias Demo.Accounts.{Agent,Credential}

  @doc """
  Gets a single agent corresponding to a username and password.

  ## Examples

      iex> get_agent_by_username_and_password("abc", "uvw")
      {:ok, %Agent{}}

      iex> get_agent_by_username_and_password("dec", "xyz")
      {:error, :no_resource}

  """
  def get_agent_by_username_and_password(username, password)
    when is_binary(username) and is_binary(password) do
      agent =
        Agent
        |> Repo.get_by(username: username)
        |> Repo.preload(:credential)
      cond do
        is_nil(agent) ->
          {:error, :unauthenticated}
        Comeonin.Bcrypt.checkpw(password, agent.credential.password_digest) ->
          {:ok, agent}
        true ->
          {:error, :unauthenticated}
      end
  end

  @doc false
  def session_changeset(params) do
    %Agent{}
    |> Agent.changeset(params)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.validate/2)
  end
end
