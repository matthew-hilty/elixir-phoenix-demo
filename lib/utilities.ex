defmodule Utilities do
  @ok :ok
  @error :error

  @doc """
  Traverses a structure of individually validated components,
  and removes the :ok and :error validation markers,
  the result being either a collection entirely comprising valid results
  or a partitioned collection of both errors and valid results.

  ## Examples

      iex> accumulate_errors(%{})
      {:ok, %{}}

      iex> accumulate_errors(%{a: {:ok, 24}, b: {:ok, :y}, c: {:ok, "z"}})
      {:ok, %{a: 24, b: :y, c: "z"}}

      iex> accumulate_errors(%{a: {:ok, 24}, b: {:error, :y}, c: {:ok, "z"}})
      {:error, %{errors: %{b: :b}, valid_results: %{a: 24, c: "z"}}}

      iex> accumulate_errors(%{a: {:error, 24}, b: {:error, :y}, c: {:ok, "z"}})
      {:error, %{errors: %{a: 24, b: :y}, valid_results: %{c: "z"}}}

      iex> accumulate_errors(%{a: {:error, 24}, b: {:error, :y}, c: {:error, "z"}})
      {:error, %{errors: %{a: 24, b: :y, c: "z"}, valid_results: %{}}}

  """
  def accumulate_errors(%{} = map) do
    reduce = fn
      ({key, {@ok, value}}, {@ok, valid_map}) ->
        {@ok, Map.put(valid_map, key, value)}
      ({key, {@ok, value}}, {@error, %{valid_results: valid_map} = map1}) ->
        {@error, Map.put(map1, :valid_results, Map.put(valid_map, key, value))}
      ({key, {@error, value}}, {@ok, valid_map}) ->
        {@error, %{errors: %{key => value}, valid_results: valid_map}}
      ({key, {@error, value}}, {@error, %{errors: error_map} = map1}) ->
        {@error, Map.put(map1, :errors, Map.put(error_map, key, value))}
    end
    Enum.reduce(map, {@ok, %{}}, reduce)
  end

  def bind_error({@ok, value}, _fun), do: {@ok, value}
  def bind_error({@error, value}, fun), do: fun.(value)

  def bind_value({@ok, value}, fun), do: fun.(value)
  def bind_value({@error, value}, _fun), do: {@error, value}

  def get_date_today() do
    :calendar.local_time()
    |> elem(0)
    |> Date.from_erl()
    |> elem(1)
    |> Date.to_iso8601()
  end

  def map_error({@ok, value}, _fun), do: {@ok, value}
  def map_error({@error, value}, fun), do: {@error, fun.(value)}

  def map_value({@ok, value}, fun), do: {@ok, fun.(value)}
  def map_value({@error, value}, _fun), do: {@error, value}

  def modify_if(value, true, transform), do: transform.(value)
  def modify_if(value, false, _), do: value
  def modify_if(value, predicate, transform) do
    if predicate.(value) do
      transform.(value)
    else
      value
    end
  end

  def nilify_error({@ok, value}), do: value
  def nilify_error({@error, _}), do: nil

  def prohibit_nil(value), do: prohibit_nil(value, :invalid_nil)
  def prohibit_nil(nil, msg), do: {@error, msg}
  def prohibit_nil(value, _msg), do: {@ok, value}

  def replace_old(map, key, value) do
    try do
      Map.replace!(map, key, value)
    rescue
      KeyError -> map
    end
  end

  def same_members?(list0, list1) when is_list(list0) and is_list(list1) do
    :lists.sort(list0) == :lists.sort(list1)
  end

  def to_integer(value) when is_binary(value) do
    try do
      {@ok, String.to_integer(value)}
    rescue
      ArgumentError -> {@error, :invalid_integer_format}
    end
  end

  def to_json(%_{} = struct, [_ | _] = keys) do
    struct
    |> Map.from_struct()
    |> Map.take(keys)
    |> ToJson.to_json()
  end
end
