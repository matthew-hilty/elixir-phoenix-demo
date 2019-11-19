defmodule DemoWeb.Utilities do
  alias Ecto.Changeset

  @doc """
  Returns an changeset that facilitates form validation.

  Note that calling `form_for` on changesets returned from `to_changeset`
  requires the additional options `:as` and `:method`. See below for an example.

  ## Examples
  Data submitted from the following form, after parsing and validation,
  is meant to represent a `Cat` data type with the fields `name`, `age`, and `owner`.

      ```
      <form action="/cats" method="post">
        <input name="_method" type="hidden" value="put">
        <div class="form-group">
          <label for="cat_name">Patient id</label>
          <input id="cat_name" name="cat[name]"/>
        </div>
        <div class="form-group">
          <label for="cat_age">Pharmacy id</label>
          <input id="cat_age" name="cat[age]"/>
        </div>
        <div class="form-group">
          <label for="cat_owner">Courier id</label>
          <input id="cat_owner" name="cat[owner]"></div>
        </div>
        <button type="submit">Submit</button>
      </form>
      ```

  Suppose that a user's submission data is

      ```
      %{cat: %{name: "Bastet", age: 4909, owner: "Alf"}}
      ```

  However, because Alf should not be permitted to own cats, this data is invalid.
  And, therefore, the form should be re-rendered with error messages directing
  the user to make new selections.

  The following invocation of `to_changeset` and `form_for` transforms the
  previous form into the new form below that includes pertinent error
  messages as well as previously submitted valid data.

      iex> errors = %{owner: ["is a Melmackian"]}
      iex> valid_data = %{name: "Bastet", age: 4909}
      iex> changeset = to_changeset(errors, valid_data)
      iex> form_for(changeset, "/cats", [as: "cat", method: "put"], fn (form) -> ... end)

      ```
      <form action="/cats" method="post">
        <input name="_method" type="hidden" value="put">
        <div class="alert alert-danger">
          <p>Oops, something went wrong! Please check the errors below.</p>
        </div>
        <div class="form-group">
          <label for="cat_name">Patient id</label>
          <input id="cat_name" name="cat[name]" value="Bastet"/>
        </div>
        <div class="form-group">
          <label for="cat_age">Pharmacy id</label>
          <input id="cat_age" name="cat[age]" value="4909"/>
        </div>
        <div class="form-group">
          <label for="cat_owner">Courier id</label>
          <input id="cat_owner" name="cat[owner]"></div>
          <span class="help-block">is a Melmackian</span>
        </div>
        <button type="submit">Submit</button>
      </form>
      ```

  """
  def to_changeset(%{} = errors, %{} = valid_results) do
    errors
    |> Enum.reduce(
        Changeset.cast({%{}, to_changeset_types(errors)}, valid_results, []),
        fn
          ({key, []}, acc) ->
            Changeset.add_error(acc, key, "is invalid", [])
          ({key, [value | _] = values}, acc) when is_binary(value) ->
            Changeset.add_error(acc, key, Enum.join(values, "; "), [])
        end)
    |> Map.put(:action, :show_errors)
  end

  defp to_changeset_types(%{} = map) do
    Enum.reduce(
      map,
      map,
      fn ({key, _}, acc) ->
        Map.replace!(acc, key, :any)
      end)
  end
end
