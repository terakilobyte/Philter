defmodule Philter.TwimlController do
  use Philter.Web, :controller

  alias Philter.Twiml

  def index(conn, _params) do
    IO.inspect(get_in(conn.params, ["song"]))
    song =
      conn.params
      |> get_and_decode_song_request
    render(conn, "index.html", song: song)
  end

  defp get_and_decode_song_request(params) do
    params
    |> Map.get("song")
    |> URI.decode
  end
end
