defmodule SlackCleanup.Janitor do
  alias HTTPotion.Response
  alias HTTPotion.HTTPError

  @error_in_200_template "{\"ok\":false,\"error\""

  def post(options, item) do
    IO.puts "Deleting #{item["permalink"]}"
    try do
      response = HTTPotion.post(url(options, item), timeout: 10_000)
      case response do
        %Response{status_code: 200, body: @error_in_200_template <> body} ->
          {:error, item["permalink"], Poison.decode!(@error_in_200_template <> body)["error"]}
        %Response{status_code: 200} -> {:ok, item["permalink"]}
        %Response{status_code: _}   -> {:error, item["permalink"], :not_found}
        %HTTPError{message: reason}  -> {:error, item["permalink"], reason}
      end
    rescue
      error in HTTPError ->
        case error do
          %HTTPError{message: "req_timedout"} ->
            :timer.sleep(1_000)
            post(options, item)
        end
    end
  end

  defp url(options, item) do
    "https://#{options[:domain]}.slack.com/api/files.delete?token=#{options[:token]}&file=#{item["id"]}"
  end
end
