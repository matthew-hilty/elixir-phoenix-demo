defmodule DemoWeb.ControllerUtilities do
  @error :error
  @invalid_parameter :invalid_parameter
  @ok :ok

  def validate_id_type(value) do
    validate_parameter(
      value,
      "id",
      fn (x) ->
        is_positive_integer(x) || is_positive_integer_string(x)
      end)
  end

  def validate_parameter(value, parameter_name, predicate) do
    if predicate.(value) do
      {@ok, value}
    else
      {@error, {@invalid_parameter, parameter_name}}
    end
  end

  defp is_positive_integer(x) do
    is_integer(x) && x > 0
  end

  defp is_positive_integer_string(x) do
    case Utilities.to_integer(x) do
      {:ok, y} -> y > 0
      _ -> false
    end
  end
end
