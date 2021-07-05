defmodule PlateSlateWeb.Resolvers.Menu do
  import Absinthe.Resolution.Helpers, only: [async: 1]
  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def menu_items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)

    {:ok, PlateSlate.Repo.all(query)}
  end

  def category_for_menu_item(menu_item, _, _) do
    async(fn ->
      query = Ecto.assoc(menu_item, :category)

      {:ok, PlateSlate.Repo.one(query)}
    end)
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_, %{input: params}, _) do
    with {:ok, menu_item} <- Menu.create_item(params) do
      {:ok, %{menu_item: menu_item}}
    end
  end
end
