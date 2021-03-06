defmodule PlateSlateWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  object :accounts_queries do
    field :me, :user do
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.Accounts.me/3)
    end
  end

  object :accounts_mutations do
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:role, non_null(:role))

      resolve(&Resolvers.Accounts.login/3)

      middleware(fn res, _ ->
        with %{value: %{user: user}} <- res do
          %{res | context: Map.put(res.context, :current_user, user)}
        end
      end)
    end
  end

  object :session do
    field :token, :string
    field :user, :user
  end

  enum :role do
    value(:employee)
    value(:customer)
  end

  interface :user do
    field :email, :string
    field :name, :string

    resolve_type(fn
      %{role: "employee"}, _ -> :employee
      %{role: "customer"}, _ -> :customer
    end)
  end

  object :employee do
    interface(:user)

    field :email, :string
    field :name, :string
  end

  object :customer do
    interface(:user)

    field :email, :string
    field :name, :string

    field :orders, list_of(:order) do
      resolve(fn customer, _, _ ->
        import Ecto.Query

        orders =
          PlateSlate.Ordering.Order
          |> where(customer_id: ^customer.id)
          |> PlateSlate.Repo.all()

        {:ok, orders}
      end)
    end
  end
end
