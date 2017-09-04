defmodule Discuss.AuthController do
  use Discuss.Web, :controller

  plug Ueberauth
  alias Discuss.User

  def callback(conn, params) do
    %{assigns: %{ueberauth_auth: auth}} = conn
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: params["provider"]}
    changeset = User.changeset(%User{}, user_params)
    sign_in(conn, changeset)
  end

  def sign_in(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome to Discuss!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  def insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end
