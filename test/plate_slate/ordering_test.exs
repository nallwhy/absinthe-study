defmodule PlateSlate.OrderingTest do
  use PlateSlate.DataCase, async: true

  alias PlateSlate.Ordering

  describe "orders" do
    alias PlateSlate.Ordering.Order

    setup do
      PlateSlate.Seeds.run()
    end

    test "create_order/1 with valid data creates a order" do
      chai = Repo.get_by!(PlateSlate.Menu.Item, name: "Masala Chai")
      fries = Repo.get_by!(PlateSlate.Menu.Item, name: "French Fries")

      attrs = %{
        ordered_at: "2010-04-17T14:00:00Z",
        state: "created",
        items: [
          %{menu_item_id: chai.id, quantity: 1},
          %{menu_item_id: fries.id, quantity: 2}
        ]
      }

      assert {:ok, %Order{} = order} = Ordering.create_order(attrs)

      assert Enum.map(order.items, &Map.take(&1, [:name, :price, :quantity])) == [
               %{name: chai.name, price: chai.price, quantity: 1},
               %{name: fries.name, price: fries.price, quantity: 2}
             ]

      assert order.state == "created"
    end
  end
end
