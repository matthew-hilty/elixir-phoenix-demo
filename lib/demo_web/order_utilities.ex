defmodule DemoWeb.OrderUtilities do
  import Utilities,
    only: [ bind_value: 2,
            get_date_today: 0,
            map_error: 2,
            map_value: 2,
            prohibit_nil: 2,
            to_integer: 1,
          ]

  alias Demo.Accounts.{Administrator,Courier,Pharmacy}
  alias Demo.Orders.Order
  alias Demo.OrderStates.OrderState

  @default_order_state_description OrderState.active()
  @default_pickup_date "today"
  @default_pickup_time "14:00"

  @absent_account_id :absent_account_id
  @absent_patient_id :absent_patient_id
  @all :all
  @courier_id :courier_id
  @error :error
  @invalid_account_id :invalid_account_id
  @invalid_date :invalid_date
  @invalid_order_state_description :invalid_order_state_description
  @invalid_time :invalid_time
  @not_authorized :not_authorized
  @ok :ok
  @pharmacy_id :pharmacy_id
  @unspecified :unspecified

  def normalize_validate_creation(params, account) do
    requirements = get_required_ids(account)
    courier_id =
      params
      |> get_courier_id_param_or_unspecified()
      |> validate_account_id_create(requirements.courier_id)
    order_state_description =
      params
      |> get_order_state_description_param_or_default()
      |> validate_order_state_description()
    patient_id =
      params
      |> get_patient_id_param_result()
      |> bind_value(&validate_id/1)
    pharmacy_id =
      params
      |> get_pharmacy_id_param_or_unspecified()
      |> validate_account_id_create(requirements.pharmacy_id)
    pickup_date =
      params
      |> get_pickup_date_param_or_default()
      |> validate_date()
    pickup_time =
      params
      |> get_pickup_time_param_or_default()
      |> validate_time()
    %{ courier_id: courier_id,
       order_state_description: order_state_description,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end

  def normalize_validate_index(params, account) do
    requirements = get_required_ids(account)
    courier_id =
      params
      |> get_courier_id_param_or_unspecified()
      |> validate_account_id_index(requirements.courier_id)
    order_state_description =
      params
      |> get_order_state_description_param_or_default()
      |> check_all_or_validate(&validate_order_state_description/1)
    patient_id =
      params
      |> get_patient_id_param_or_all()
      |> check_all_or_validate(&validate_id/1)
    pharmacy_id =
      params
      |> get_pharmacy_id_param_or_unspecified()
      |> validate_account_id_index(requirements.pharmacy_id)
    pickup_date =
      params
      |> get_pickup_date_param_or_default()
      |> check_all_or_validate(&validate_date/1)
    %{ courier_id: courier_id,
       order_state_description: order_state_description,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
     }
  end

  def normalize_validate_update(%Order{} = order, params, account) do
    requirements = get_required_ids(account)
    authorized? = is_integer(requirements.administrator_id)
    courier_id =
      params
      |> get_courier_id_param_or_unspecified()
      |> validate_account_id_update(requirements.courier_id)
      |> bind_value(validate_order_courier(order, authorized?))
    order_state_description =
      params
      |> get_order_state_description_param_or_default()
      |> validate_order_state_description()
    patient_id =
      params
      |> get_pharmacy_id_param_or_unspecified()
      |> check_unspecified_or_validate(order.patient.id, &validate_id/1)
    pharmacy_id =
      params
      |> get_pharmacy_id_param_or_unspecified()
      |> validate_account_id_update(requirements.pharmacy_id)
      |> bind_value(validate_order_pharmacy(order, authorized?))
    pickup_date =
      params
      |> get_pickup_date_param_or_default()
      |> validate_date()
    pickup_time =
      params
      |> get_pickup_time_param_or_default()
      |> validate_time()
    %{ courier_id: courier_id,
       order_state_description: order_state_description,
       patient_id: patient_id,
       pharmacy_id: pharmacy_id,
       pickup_date: pickup_date,
       pickup_time: pickup_time,
     }
  end

  defp check_all_or_validate(id, validator) do
    if id == "all" do
      {@ok, @all}
    else
      validator.(id)
    end
  end

  defp check_unspecified_or_validate(value, default, fun) do
    if value == @unspecified do
      {@ok, default}
    else
      fun.(value)
    end
  end

  defp get_courier_id_param_or_unspecified(params) do
    params
    |> get_param_or_unspecified("courier_id")
  end

  defp get_order_state_description_param_or_default(params) do
    Map.get(params, "order_state",
      Map.get(params, "order_state_description",
         @default_order_state_description))
  end

  defp get_param_or_unspecified(params, key) do
    param = Map.get(params, key)
    if is_nil(param) do
      @unspecified
    else
      to_string(param)
    end
  end

  defp get_patient_id_param_or_all(params) do
    params
    |> Map.get("patient_id", "all")
    |> to_string()
  end

  defp get_patient_id_param_result(params) do
    params
    |> Map.get("patient_id")
    |> prohibit_nil(@absent_patient_id)
    |> map_value(&to_string/1)
  end

  defp get_pharmacy_id_param_or_unspecified(params) do
    params
    |> get_param_or_unspecified("pharmacy_id")
  end

  defp get_pickup_date_param_or_default(params) do
    Map.get(params, "pickup_date", @default_pickup_date)
  end

  defp get_pickup_time_param_or_default(params) do
    Map.get(params, "pickup_time", @default_pickup_time)
  end

  defp get_required_ids(account) do
    case account do
      %Courier{id: id} ->
        %{courier_id: id, pharmacy_id: nil, administrator_id: nil}
      %Pharmacy{id: id} ->
        %{courier_id: nil, pharmacy_id: id, administrator_id: nil}
      %Administrator{id: id} ->
        %{courier_id: nil, pharmacy_id: nil, administrator_id: id}
    end
  end

  defp normalize_datetime_segment(segment) do
    if String.length(segment) == 1 do
      "0#{segment}"
    else
      segment
    end
  end

  defp validate_account_id_against_authenticated_user_id(@unspecified, required_id)
    when is_integer(required_id) do
      {@ok, required_id}
  end
  defp validate_account_id_against_authenticated_user_id(account_id, required_id)
    when is_binary(account_id) and is_integer(required_id) do
      if account_id == to_string(required_id) do
        {@ok, required_id}
      else
        case to_integer(account_id) do
          {@ok, _} ->
            {@error, @not_authorized}
          {@error, _} ->
            {@error, @invalid_account_id}
        end
      end
  end

  defp validate_account_id_create(account_id, required_id) do
    cond do
      is_integer(required_id) ->
        validate_account_id_against_authenticated_user_id(account_id, required_id)
      account_id == @unspecified ->
        {@error, @absent_account_id}
      true ->
        validate_id(account_id)
    end
  end

  defp validate_account_id_index(account_id, required_id) do
    cond do
      is_integer(required_id) ->
        validate_account_id_against_authenticated_user_id(account_id, required_id)
      account_id == @unspecified ->
        {@ok, @all}
      true ->
        check_all_or_validate(account_id, &validate_id/1)
    end
  end

  defp validate_account_id_update(account_id, required_id) do
    cond do
      is_integer(required_id) ->
        validate_account_id_against_authenticated_user_id(account_id, required_id)
      account_id == @unspecified ->
        {@ok, @unspecified}
      true ->
        validate_id(account_id)
    end
  end

  defp validate_date("today"), do: {@ok, get_date_today() }
  defp validate_date(%{"year" => year, "month" => month, "day" => day}) do
    month = normalize_datetime_segment(month)
    day = normalize_datetime_segment(day)
    validate_date("#{year}-#{month}-#{day}")
  end
  defp validate_date(iso8601_date_or_error)
    when is_binary(iso8601_date_or_error) do
      iso8601_date_or_error
      |> Date.from_iso8601()
      |> map_error(fn (_) -> @invalid_date end)
  end
  defp validate_date(_), do: {@error, @invalid_date}

  defp validate_id(id) do
    msg = @invalid_account_id
    id
    |> to_integer()
    |> bind_value(fn (id) -> if (id > 0), do: {@ok, id}, else: {@error, msg} end)
    |> map_error(fn (_) -> msg end)
  end

  defp validate_order_account(account_id_key, %Order{} = order, authorized?) do
    fn (account_id) ->
      cond do
        account_id == @unspecified ->
          {@ok, Map.get(order, account_id_key)}
        account_id == Map.get(order, account_id_key) ->
          {@ok, account_id}
        authorized? ->
          {@ok, account_id}
        true ->
          {@error, @not_authorized}
      end
    end
  end

  defp validate_order_courier(%Order{} = order, authorized?) do
    validate_order_account(@courier_id, order, authorized?)
  end

  defp validate_order_pharmacy(%Order{} = order, authorized?) do
    validate_order_account(@pharmacy_id, order, authorized?)
  end

  defp validate_order_state_description(order_state_description) do
    if order_state_description in OrderState.order_states do
      {@ok, order_state_description}
    else
      {@error, @invalid_order_state_description}
    end
  end

  defp validate_time(%{"hour" => hour, "minute" => minute}) do
    nhour = normalize_datetime_segment(hour)
    nminute = normalize_datetime_segment(minute)
    validate_time("#{nhour}:#{nminute}")
  end
  defp validate_time(iso8601_time_or_error)
    when is_binary(iso8601_time_or_error) do
      "#{iso8601_time_or_error}:00"
      |> Time.from_iso8601()
      |> map_error(fn (_) -> @invalid_time end)
  end
  defp validate_time(_), do: {@error, @invalid_time}
end
