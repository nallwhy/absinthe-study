defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers

  import_types(Absinthe.Type.Custom, only: [:decimal])

  object :menu_queries do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      arg(:order, :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  object :search_queries do
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))

      resolve(&Resolvers.Menu.search/3)
    end
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a category name"
    field :category, :string

    @desc "Matching a tag"
    field :tag, :string

    @desc "Priced above a value"
    field :priced_above, :float

    @desc "Priced below a value"
    field :priced_below, :float

    @desc "Added to the menu before this date"
    field :added_before, :date

    @desc "Added to the menu after this date"
    field :added_after, :date
  end

  object :menu_item do
    interfaces([:search_result])

    field :id, :id
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :added_on, :date
  end

  object :category do
    interfaces([:search_result])

    field :name, :string
    field :description, :string

    field :items, list_of(:menu_item) do
      # TODO: Fix 1+N problem
      resolve(&Resolvers.Menu.menu_items_for_category/3)
    end
  end

  interface :search_result do
    field :name, :string

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ -> :menu_item
      %PlateSlate.Menu.Category{}, _ -> :category
      _, _ -> nil
    end)
  end

  object :menu_mutations do
    field :create_menu_item, :menu_item do
      arg(:input, non_null(:menu_item_input))

      resolve(&Resolvers.Menu.create_item/3)
    end
  end

  input_object :menu_item_input do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end
end
