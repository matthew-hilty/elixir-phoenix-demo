defprotocol ToJson do
  def to_json(value)
end

defimpl ToJson, for: Atom do
  def to_json(nil), do: nil
  def to_json(true), do: true
  def to_json(false), do: false
  def to_json(atom), do: to_string(atom)
end

defimpl ToJson, for: BitString do
  def to_json(bit_string), do: to_string(bit_string)
end

defimpl ToJson, for: Date do
  def to_json(%Date{} = date), do: to_string(date)
end

defimpl ToJson, for: Integer do
  def to_json(integer), do: integer
end

defimpl ToJson, for: List do
  def to_json([]), do: []
  def to_json([_ | _] = values) do
    Enum.map(values, &ToJson.to_json/1)
  end
end

defimpl ToJson, for: Map do
  def to_json(%{} = map) do
    Enum.reduce(map, %{}, fn ({key, value}, memo) ->
      Map.put(memo, to_string(key), ToJson.to_json(value))
    end)
  end
end

defimpl ToJson, for: Number do
  def to_json(number), do: number
end

defimpl ToJson, for: String do
  def to_json(string), do: string
end

defimpl ToJson, for: Time do
  def to_json(%Time{} = time) do
    time |> Time.to_iso8601() |> String.slice(0..4)
  end
end
