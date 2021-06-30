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
    createMenuItem(input: $menuItemInput) {
      menuItem {
        name
        description
        price
      }
      errors {
        key
        message
      }
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
               "createMenuItem" => %{
                 "menuItem" => %{
                   "name" => menu_item_input["name"],
                   "description" => menu_item_input["description"],
                   "price" => menu_item_input["price"]
                 },
                 "errors" => nil
               }
             }
           }
  end

  test "createMenuItem field creates an item with an existing name fails", %{
    category_id_str: category_id_str
  } do
    menu_item_input = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id_str
    }

    response =
      post(build_conn(), "/api", query: @query, variables: %{"menuItemInput" => menu_item_input})

    assert %{
             "data" => %{
               "createMenuItem" => %{
                 "menuItem" => nil,
                 "errors" => [
                   %{"key" => "name", "message" => "has already been taken"}
                 ]
               }
             }
           } = json_response(response, 200)
  end
end
