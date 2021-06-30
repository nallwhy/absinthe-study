defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  import_types(__MODULE__.{MenuTypes, OrderingTypes})

  query do
    import_fields(:menu_queries)
    import_fields(:search_queries)
  end

  mutation do
    import_fields(:menu_mutations)
    import_fields(:ordering_mutations)
  end

  # Reimplementation of date of Absinthe.Type.Custom
  scalar :date do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end
end
