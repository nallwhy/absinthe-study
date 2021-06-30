defmodule PlateSlate.Ordering.Item do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :price, :decimal
    field :quantity, :integer
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :price, :quantity])
    |> validate_required([:name, :price, :quantity])
  end
end
