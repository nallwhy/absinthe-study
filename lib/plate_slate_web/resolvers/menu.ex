defmodule PlateSlateWeb.Resolvers.Menu do
  import Absinthe.Resolution.Helpers, only: [on_load: 2]
  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  # def menu_items_for_category(category, args, %{context: %{loader: loader}}) do
  #   loader
  #   |> Dataloader.load(Menu, {:items, args}, category)
  #   |> on_load(fn loader ->
  #     items = Dataloader.get(loader, Menu, {:items, args}, category)

  #     {:ok, items}
  #   end)
  # end

  def category_for_menu_item(menu_item, _, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Menu, :category, menu_item)
    |> on_load(fn loader ->
      category = Dataloader.get(loader, Menu, :category, menu_item)

      {:ok, category}
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
