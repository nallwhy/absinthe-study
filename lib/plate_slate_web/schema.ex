defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers

  query do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:matching, :string)
      arg(:order, :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  object :menu_item do
    field :id, :id
    field :name, :string
    field :description, :string
  end
end
