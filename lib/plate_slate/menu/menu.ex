defmodule PlateSlate.Menu do
  import Ecto.Query
  alias PlateSlate.Repo

  alias PlateSlate.Menu.Category

  def list_categories do
    Repo.all(Category)
  end

  def list_categories_by_id(_, ids) do
    Category
    |> where([c], c.id in ^Enum.uniq(ids))
    |> Repo.all()
    |> Map.new(fn category ->
      {category.id, category}
    end)
  end

  def get_category!(id) do
    Repo.get!(Category, id)
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias PlateSlate.Menu.Item

  def list_items(args) do
    args
    |> items_query()
    |> Repo.all()
  end

  defp items_query(args) do
    Enum.reduce(args, Item, fn
      {:order, order}, query -> query |> order_by({^order, :name})
      {:filter, filter}, query -> query |> filter_with(filter)
    end)
  end

  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:name, name}, query ->
        from q in query, where: ilike(q.name, ^"%#{name}%")

      {:category, category_name}, query ->
        from q in query,
          join: c in assoc(q, :category),
          where: ilike(c.name, ^"%#{category_name}%")

      {:tag, tag_name}, query ->
        from q in query, join: t in assoc(q, :tags), where: ilike(t.name, ^"%#{tag_name}%")

      {:priced_above, price}, query ->
        from q in query, where: q.price >= ^price

      {:priced_below, price}, query ->
        from q in query, where: q.price <= ^price

      {:added_before, date}, query ->
        from q in query, where: q.added_on <= ^date

      {:added_after, date}, query ->
        from q in query, where: q.added_on >= ^date
    end)
  end

  def get_item!(id) do
    Repo.get!(Item, id)
  end

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  @search [Item, Category]
  def search(term) do
    pattern = "%#{term}%"

    Enum.flat_map(@search, &search_ecto(&1, pattern))
  end

  defp search_ecto(ecto_schema, pattern) do
    Repo.all(
      from q in ecto_schema, where: ilike(q.name, ^pattern) or ilike(q.description, ^pattern)
    )
  end

  # Dataloader

  def data() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Item, args) do
    items_query(args)
  end

  def query(queryable, _) do
    queryable
  end
end
