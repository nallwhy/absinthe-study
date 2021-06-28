defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlate.Menu
  alias PlateSlate.Repo

  query do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      resolve fn _, _, _ -> {:ok, Repo.all(Menu.Item)} end
    end
  end

  object :menu_item do
    field :id, :id
    field :name, :string
    field :description, :string
  end
end
