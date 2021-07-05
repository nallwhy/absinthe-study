defmodule PlateSlateWeb.Schema.Subscription.NewOrderTest do
  use PlateSlateWeb.SubscriptionCase
  alias PlateSlate.Factory

  @login """
  mutation ($email: String!, $role: Role!) {
    login(role: $role, password: "super-secret", email: $email) {
      token
    }
  }
  """
  @subscription """
  subscription {
    newOrder {
      customerNumber
    }
  }
  """
  @mutation """
  mutation ($input: PlaceOrderInput!) {
    placeOrder(input: $input) {
      order {
        id
      }
    }
  }
  """
  test "new orders can be subscribed to", %{socket: socket} do
    # login
    user = Factory.create_user("employee")
    ref = push_doc(socket, @login, variables: %{"email" => user.email, "role" => "EMPLOYEE"})

    assert_reply ref, :ok, %{data: %{"login" => %{"token" => _}}}

    # setup a subscription
    ref = push_doc(socket, @subscription)
    assert_reply ref, :ok, %{subscriptionId: subscription_id}

    # run a mutation to trigger the subscription
    order_input = %{
      "customerNumber" => 24,
      "items" => [
        %{"menuItemId" => menu_item("Reuben").id, "quantity" => 2}
      ]
    }

    ref = push_doc(socket, @mutation, variables: %{"input" => order_input})
    assert_reply ref, :ok, reply
    assert %{data: %{"placeOrder" => %{"order" => %{"id" => _}}}} = reply

    # check to see if we got subscription data
    expected = %{
      result: %{data: %{"newOrder" => %{"customerNumber" => 24}}},
      subscriptionId: subscription_id
    }

    assert_push "subscription:data", push
    assert expected == push
  end

  test "customers can't see other customer orders", %{socket: socket} do
    customer1 = Factory.create_user("customer")

    # login as customer1
    ref = push_doc(socket, @login, variables: %{"email" => customer1.email, "role" => "CUSTOMER"})
    assert_reply ref, :ok, %{data: %{"login" => %{"token" => _}}}

    # subscribe to orders
    ref = push_doc(socket, @subscription)
    assert_reply ref, :ok, %{subscriptionId: _subscription_id}

    # customer1 places order
    place_order(customer1)
    assert_push "subscription:data", _

    # customer2 places order
    customer2 = Factory.create_user("customer")
    place_order(customer2)
    refute_receive _
  end

  defp place_order(customer) do
    order_input = %{
      "customerNumber" => 24,
      "items" => [%{"quantity" => 2, "menuItemId" => menu_item("Reuben").id}]
    }

    {:ok, %{data: %{"placeOrder" => _}}} =
      Absinthe.run(@mutation, PlateSlateWeb.Schema,
        context: %{current_user: customer},
        variables: %{"input" => order_input}
      )
  end
end
