defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  import_types(__MODULE__.MenuTypes)

  query do
    import_fields(:menu_queries)
    import_fields(:search_queries)
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
end
