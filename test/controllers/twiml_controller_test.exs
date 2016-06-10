defmodule Philter.TwimlControllerTest do
  use Philter.ConnCase

  alias Philter.Twiml
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, twiml_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing twiml"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, twiml_path(conn, :new)
    assert html_response(conn, 200) =~ "New twiml"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, twiml_path(conn, :create), twiml: @valid_attrs
    assert redirected_to(conn) == twiml_path(conn, :index)
    assert Repo.get_by(Twiml, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, twiml_path(conn, :create), twiml: @invalid_attrs
    assert html_response(conn, 200) =~ "New twiml"
  end

  test "shows chosen resource", %{conn: conn} do
    twiml = Repo.insert! %Twiml{}
    conn = get conn, twiml_path(conn, :show, twiml)
    assert html_response(conn, 200) =~ "Show twiml"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, twiml_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    twiml = Repo.insert! %Twiml{}
    conn = get conn, twiml_path(conn, :edit, twiml)
    assert html_response(conn, 200) =~ "Edit twiml"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    twiml = Repo.insert! %Twiml{}
    conn = put conn, twiml_path(conn, :update, twiml), twiml: @valid_attrs
    assert redirected_to(conn) == twiml_path(conn, :show, twiml)
    assert Repo.get_by(Twiml, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    twiml = Repo.insert! %Twiml{}
    conn = put conn, twiml_path(conn, :update, twiml), twiml: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit twiml"
  end

  test "deletes chosen resource", %{conn: conn} do
    twiml = Repo.insert! %Twiml{}
    conn = delete conn, twiml_path(conn, :delete, twiml)
    assert redirected_to(conn) == twiml_path(conn, :index)
    refute Repo.get(Twiml, twiml.id)
  end
end
