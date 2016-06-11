defmodule Philter.Spotify do

  @process Philter.Spotify.Query
  @supervisor Philter.Spotify.Supervisor
  @ngrok_url "http://tkb.ngrok.io/twiml?song="

  alias ExTwilio

  def start_link(proc, song, twilio_data, query_ref, owner) do
    proc.start_link(song, twilio_data, query_ref, owner)
  end

  def search(song, twilio_data) do
    song
    |> spawn_search(twilio_data)
    |> await_results
  end

  def spawn_search(song, twilio_data) do
    query_ref = make_ref()
    opts = [@process, song, twilio_data, query_ref, self()]
    {:ok, pid} = Supervisor.start_child(@supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end

  defp await_results(process) do
    timeout = 9000
    timer = Process.send_after(self(), :timedout, timeout)
    results = await_result(process, "", :infinity)
    cleanup(timer)
    results
  end

  defp await_result(query_process, _result, _timeout) do
    {pid, monitor_ref, query_ref} = query_process

    receive do
      {:results, ^query_ref, result, twilio_data} ->
        Process.demonitor(monitor_ref, [:flush])
        notify_success(result, twilio_data)
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        # some kind of error logging
        IO.puts("oops")
      :timedout ->
        kill(pid, monitor_ref)
        IO.puts("oops")
        #some kind of error logging
    end
  end

  defp notify_success(nil, %{from: from, to: to}) do
    ExTwilio.Message.create([
      From: to,
      To: from,
      Body: "Sorry, I couldn't find your song on Spotify"
    ])
  end


  defp notify_success(preview_url, %{from: from, to: to}) do
    ExTwilio.Message.create([
      From: to,
      To: from,
      Body: "Your clip is on the way!"
    ])

    ExTwilio.Call.create([
      From: to,
      To: from,
      Url: @ngrok_url <> "#{URI.encode_www_form(preview_url)}"
    ])
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end

end
