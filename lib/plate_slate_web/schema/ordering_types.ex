defmodule PlateSlateWeb.Schema.OrderingTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers

  object :ordering_mutations do
    field :place_order, :order_result do
      arg(:input, non_null(:place_order_input))

      resolve(&Resolvers.Ordering.place_order/3)
    end
  end

  object :ordering_subscriptions do
    field :new_order, :order do
      config(fn _args, _info -> {:ok, topic: "*"} end)
      # resolve(fn root, _, _ -> {:ok, root} end)
    end
  end

  input_object :place_order_input do
    field :customer_number, :integer
    field :items, non_null(list_of(non_null(:place_order_item_input)))
  end

  input_object :place_order_item_input do
    field :menu_item_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  object :order_result do
    field :order, :order
    field :errors, list_of(:input_error)
  end

  object :order do
    field :id, :id
    field :customer_number, :integer
    field :items, list_of(:order_item)
    field :state, :string
  end

  object :order_item do
    field :name, :string
    field :quantity, :integer
  end
end
