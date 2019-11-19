defprotocol Equiv do
  def equiv?(equiv_value, term)
end

defimpl Equiv, for: [Atom, BitString, Date, Integer, Number, String, Time] do
  def equiv?(equiv_value, term) do
    equiv_value == term
  end
end

defimpl Equiv, for: List do
  def equiv?([], []), do: true
  def equiv?([_ | _], []), do: false
  def equiv?([], [_ | _]), do: false
  def equiv?([value0 | values0], [value1 | values1]) do
    Equiv.equiv?(value0, value1)
      && Equiv.equiv?(values0, values1)
  end
end

defimpl Equiv, for: Map do
  def equiv?(%{} = map0, %{} = map1) do
    map0
    |> Enum.reduce_while(true, fn ({key, value}, _) ->
          if Equiv.equiv?(value, Map.get(map1, key)) do
            {:cont, true}
          else
            {:halt, false}
          end
        end)
  end
end
