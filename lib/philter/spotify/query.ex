defmodule Philter.Spotify.Query do

  def start_link(song, twilio_data, query_ref, owner) do
    Task.start_link(__MODULE__, :fetch, [song, twilio_data, query_ref, owner])
  end

  def fetch(song, twilio_data, query_ref, owner) do
    case String.lstrip(song) do
      "" ->
        send_results(nil, twilio_data, query_ref, owner)
      _ ->
        song
        |> String.lstrip |> String.rstrip
        |> fetch_from_spotify
        |> send_results(twilio_data, query_ref, owner)
    end
  end

  defp send_results(nil, twilio_data, query_ref, owner) do
    send(owner, {:results, query_ref, nil, twilio_data})
  end

  defp send_results(preview_url, twilio_data, query_ref, owner) do
    send(owner, {:results, query_ref, preview_url, twilio_data})
  end

  defp fetch_from_spotify(query_str) do
    %{:body => response} = HTTPotion.get("https://api.spotify.com/v1/search?type=track&q=" <> URI.encode(query_str))
    {:ok, body} = Poison.decode(response)
    body
    |> get_in(["tracks", "items"])
    |> List.first
    |> get_in(["preview_url"])
  end

end
