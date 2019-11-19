defmodule Demo.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Demo.Repo
  alias Demo.Accounts.{Administrator,Agent,Courier,Credential,Pharmacy}
  alias Ecto.Changeset

  @no_resource :no_resource

  @doc """
  Gets a single agent.

  ## Examples

      iex> get_agent(123)
      {:ok, %Agent{}}

      iex> get_agent(456)
      {:error, :no_resource}

  """
  def get_agent(id) do
    query =
      from a in Agent,
      left_join: ad in assoc(a, :administrator),
      left_join: c in assoc(a, :courier),
      left_join: ph in assoc(a, :pharmacy),
      where: a.id == ^id,
      preload: [administrator: ad, courier: c, pharmacy: ph]
    query
    |> Repo.one()
    |> Utilities.prohibit_nil(@no_resource)
    |> Utilities.map_value(&set_account_type/1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent()
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_agent(), do: Agent.changeset(%Agent{}, %{})

  @doc """
  Returns an agent's associated account type.

  ## Examples

      iex> specify_agent(%Agent{administrator: %Administrator{}})
      %Administrator{}

      iex> specify_agent(%Agent{courier: %Courier{}})
      %Courier{}

      iex> specify_agent(%Agent{pharmacy: %Pharmacy{}})
      %Pharmacy{}

  """
  def specify_agent(%Agent{} = agent) do
    %{administrator: administrator, courier: courier, pharmacy: pharmacy} = agent
    cond do
      !is_nil(administrator) ->
        agent.administrator
      !is_nil(courier) ->
        agent.courier
      !is_nil(pharmacy) ->
        agent.pharmacy
      true ->
        raise "Invalid agent"
    end
  end

  @doc """
  Returns the list of administrators.

  ## Examples

      iex> list_administrators()
      [%Administrator{}, ...]

  """
  def list_administrators(), do: list_accounts(Administrator)

  @doc """
  Gets a single administrator.

  ## Examples

      iex> get_administrator(123)
      {:ok, %Administrator{}}

      iex> get_administrator(456)
      {:error, :no_resource}

  """
  def get_administrator(id), do: get_account(Administrator, id)

  @doc """
  Creates a administrator.

  ## Examples

      iex> create_administrator(%{field: value})
      {:ok, %Agent{administrator: %Administrator{}}}

      iex> create_administrator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administrator(attrs \\ %{}) do
    create_account(:administrator, &Administrator.changeset/2, attrs)
  end

  @doc """
  Deletes a Administrator and its corresponding Agent.

  ## Examples

      iex> delete_administrator(administrator)
      {:ok, %Administrator{}}

      iex> delete_administrator(administrator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_administrator(%Administrator{} = administrator) do
    delete_account(administrator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent-cum-administrator changes.

  ## Examples

      iex> change_administrator()
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_administrator(), do: change_agent()

  @doc """
  Returns the list of pharmacies.

  ## Examples

      iex> list_pharmacies()
      [%Pharmacy{}, ...]

  """
  def list_pharmacies(), do: list_accounts(Pharmacy)

  @doc """
  Gets a single pharmacy.

  ## Examples

      iex> get_pharmacy(123)
      {:ok, %Pharmacy{}}

      iex> get_pharmacy(456)
      {:error, :no_resource}

  """
  def get_pharmacy(id), do: get_account(Pharmacy, id)

  @doc """
  Creates a pharmacy.

  ## Examples

      iex> create_pharmacy(%{field: value})
      {:ok, %Agent{pharmacy: %Pharmacy{}}}

      iex> create_pharmacy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pharmacy(attrs \\ %{}) do
    create_account(:pharmacy, &Pharmacy.changeset/2, attrs)
  end

  @doc """
  Deletes a Pharmacy and its corresponding Agent.

  ## Examples

      iex> delete_pharmacy(pharmacy)
      {:ok, %Pharmacy{}}

      iex> delete_pharmacy(pharmacy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pharmacy(%Pharmacy{} = pharmacy) do
    delete_account(pharmacy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent-cum-pharmacy changes.

  ## Examples

      iex> change_pharmacy()
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_pharmacy(), do: change_agent()

  @doc """
  Returns the list of couriers.

  ## Examples

      iex> list_couriers()
      [%Courier{}, ...]

  """
  def list_couriers(), do: list_accounts(Courier)

  @doc """
  Gets a single courier.

  ## Examples

      iex> get_courier(123)
      {:ok, %Courier{}}

      iex> get_courier(456)
      {:error, :no_resource}

  """
  def get_courier(id), do: get_account(Courier, id)

  @doc """
  Creates a courier.

  ## Examples

      iex> create_courier(%{field: value})
      {:ok, %Agent{courier: %Courier{}}}

      iex> create_courier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_courier(attrs \\ %{}) do
    create_account(:courier, &Courier.changeset/2, attrs)
  end

  @doc """
  Deletes a Courier and its corresponding Agent.

  ## Examples

      iex> delete_courier(courier)
      {:ok, %Courier{}}

      iex> delete_courier(courier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_courier(%Courier{} = courier) do
    delete_account(courier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent-cum-courier changes.

  ## Examples

      iex> change_courier()
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_courier(), do: change_agent()

  defp create_account(key, fun, attrs) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Changeset.cast_assoc(key, with: fun)
    |> Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
    |> Utilities.map_value(fn (%{^key => account, username: username} = agent) ->
          %{agent | key => %{account | username: username}}
        end)
  end

  defp delete_account(%{agent: %Agent{}} = account) do
    # Because, when the database deletes an agent, it also deletes the
    # agent's corresponding administrator, courier, or pharmacy,
    # the effect-ful expression, e.g., `Repo.delete(pharmacy)` is not needed.
    # Deleting `pharmacy.agent` alone is sufficient.
    account.agent
    |> Repo.delete()
    |> Utilities.map_value(fn (_agent) -> account end)
  end

  defp get_account(account_module, id) do
    account_module
    |> Repo.get(id)
    |> Repo.preload(:agent)
    |> Utilities.prohibit_nil(@no_resource)
    |> Utilities.map_value(&set_username/1)
  end

  defp list_accounts(account_module) do
    account_module
    |> Repo.all()
    |> Repo.preload(:agent)
    |> Enum.map(&set_username/1)
  end

  defp set_account_type(%Agent{} = agent) do
    %{administrator: administrator, courier: courier, pharmacy: pharmacy} = agent
    cond do
      !is_nil(administrator) ->
        %{agent | account_type: "administrator"}
      !is_nil(courier) ->
        %{agent | account_type: "courier"}
      !is_nil(pharmacy) ->
        %{agent | account_type: "pharmacy"}
      true ->
        raise "Invalid agent"
    end
  end

  defp set_username(%{agent: %{username: username}, username: _} = account)
    when is_binary(username) do
      %{account | username: username}
  end

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential(123)
      {:ok, %Credential{}}

      iex> get_credential!(456)
      {:error, :no_resource}

  """
  def get_credential!(id) do
    Credential
    |> Repo.get(id)
    |> Utilities.prohibit_nil(@no_resource)
  end

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{source: %Credential{}}

  """
  def change_credential(%Credential{} = credential) do
    Credential.changeset(credential, %{})
  end
end
