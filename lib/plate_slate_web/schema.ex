defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Schema.Middleware

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def middleware(middleware, field, object) do
    middleware
    |> apply(:errors, field, object)
    |> apply(:get_string, field, object)
    |> apply(:debug, field, object)
  end

  defp apply(middleware, :errors, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  defp apply([], :get_string, field, %{identifier: :allergy_info}) do
    [{Absinthe.Middleware.MapGet, to_string(field.identifier)}]
  end

  defp apply(middleware, :debug, _field, _object) do
    if System.get_env("DEBUG") do
      [{Middleware.Debug, :start}] ++ middleware
    else
      middleware
    end
  end

  defp apply(middleware, _name, _field, _object) do
    middleware
  end

  def dataloader() do
    alias PlateSlate.Menu

    Dataloader.new()
    |> Dataloader.add_source(Menu, Menu.data())
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  import_types(__MODULE__.{AccountsTypes, MenuTypes, OrderingTypes})

  query do
    import_fields(:menu_queries)
    import_fields(:search_queries)
    import_fields(:accounts_queries)
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
