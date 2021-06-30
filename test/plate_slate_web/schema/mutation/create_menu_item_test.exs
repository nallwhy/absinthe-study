defmodule PlateSlateWeb.Schema.Mutation.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true
  import Ecto.Query
  alias PlateSlate.{Repo, Menu}

  setup do
    PlateSlate.Seeds.run()

    category_id_str =
      from(c in Menu.Category, where: c.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string()

    {:ok, category_id_str: category_id_str}
  end

  @query """
  mutation ($menuItemInput: MenuItemInput!) {
    menuItem: createMenuItem(input: $menuItemInput) {
      name
      description
      price
    }
  }
  """
  test "createMenuItem field creates an item", %{category_id_str: category_id_str} do
    menu_item_input = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id_str
    }

    response =
      post(build_conn(), "/api", query: @query, variables: %{"menuItemInput" => menu_item_input})

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItem" => %{
                 "name" => menu_item_input["name"],
                 "description" => menu_item_input["description"],
                 "price" => menu_item_input["price"]
               }
             }
           }
  end
end
