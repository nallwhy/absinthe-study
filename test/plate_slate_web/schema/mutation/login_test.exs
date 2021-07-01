defmodule PlateSlateWeb.Schema.Mutation.LoginEmployeeTest do
  use PlateSlateWeb.ConnCase, asycn: true
  alias PlateSlate.Factory

  @query """
  mutation ($email: String!) {
    login(role: EMPLOYEE, email: $email, password: "super-secret") {
      token
      user {
        name
      }
    }
  }
  """
  test "creating an employee session" do
    user = Factory.create_user("employee")

    response = post(build_conn(), "/api", %{query: @query, variables: %{"email" => user.email}})

    assert %{"data" => %{"login" => %{"token" => token, "user" => user_data}}} =
             json_response(response, 200)

    assert user_data == %{"name" => user.name}
    assert PlateSlateWeb.Authentication.verify(token) == {:ok, %{role: :employee, id: user.id}}
  end
end
