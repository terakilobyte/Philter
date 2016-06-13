defmodule Philter.TwimlController do
  use Philter.Web, :controller

  def index(conn, %{"song" => song}) do
    render(conn, "index.html", song: song)
  end

end
