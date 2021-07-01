defmodule PlateSlateWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers

  object :accounts_mutations do
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:role, non_null(:role))

      resolve(&Resolvers.Accounts.login/3)
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
    field :orders, list_of(:order)
  end
end
