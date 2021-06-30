defmodule PlateSlate.Menu.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias PlateSlate.Menu.{Category, ItemTag}

  schema "items" do
    field :added_on, :date
    field :description, :string
    field :name, :string
    field :price, :decimal

    belongs_to :category, Category
    many_to_many :tags, ItemTag, join_through: "items_taggings"

    timestamps()
  end

  def changeset(%__MODULE__{} = item, attrs) do
    item
    |> cast(attrs, [:name, :description, :price, :added_on, :category_id])
    |> validate_required([:name, :price])
    |> foreign_key_constraint(:category)
    |> unique_constraint(:name)
  end
end
