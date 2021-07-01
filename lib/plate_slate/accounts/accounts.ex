defmodule PlateSlate.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias PlateSlate.Repo
  alias Comeonin.Ecto.Password

  alias PlateSlate.Accounts.User

  def authenticate(role, email, password) do
    user = Repo.get_by(User, role: to_string(role), email: email)

    with %{password: digest} <- user,
         true <- Password.valid?(password, digest) do
      {:ok, user}
    else
      _ -> :error
    end
  end
end
