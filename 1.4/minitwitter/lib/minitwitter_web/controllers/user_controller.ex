defmodule MinitwitterWeb.UserController do
  use MinitwitterWeb, :controller

  alias Minitwitter.Accounts
  alias Minitwitter.Accounts.User
  alias MinitwitterWeb.Auth

  plug :authenticate_user when action in [:index, :show, :edit, :delete]
  plug :correct_user when action in [:edit, :update]
  plug :admin_user when action in [:delete]

  def index(conn, params) do
    page = Accounts.list_users(params)

    render(conn, "index.html",
      users: page.entries,
      page: page
    )
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to Minitwitter App!")
        |> Auth.login(user)
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    # conn =
    #   case Auth.admin_user?(conn) do
    #     true -> conn
    #     _ -> Auth.correct_user(conn, user)
    #   end

    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
