defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Schema.Middleware

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, field, %{identifier: :allergy_info} = object) do
    new_middleware = {Absinthe.Middleware.MapGet, to_string(field.identifier)}

    middleware
    |> Absinthe.Schema.replace_default(new_middleware, field, object)
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  import_types(__MODULE__.{AccountsTypes, MenuTypes, OrderingTypes})

  query do
    import_fields(:menu_queries)
    import_fields(:search_queries)
  end

  mutation do
    import_fields(:accounts_mutations)
    import_fields(:menu_mutations)
    import_fields(:ordering_mutations)
  end

  subscription do
    import_fields(:ordering_subscriptions)
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
