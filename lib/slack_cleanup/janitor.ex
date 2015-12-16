defmodule SlackCleanup.Janitor do
  def post(options, item) do
    url    = delete_url(options[:domain])
    params = delete_params(options[:token], item["id"])
    IO.puts "Deleting #{item["permalink"]}"
    case HTTPotion.post(url, params) do
      %HTTPotion.Response{status_code: 200} -> {:ok, item["permalink"]}
      %HTTPotion.Response{status_code: _}   -> {:error, item["permalink"], :not_found}
      %HTTPotion.HTTPError{message: reason}  -> {:error, item["permalink"], reason}
    end
  end

  defp delete_url(domain) do
    "https://#{domain}.slack.com/api/files.delete?t=#{:os.system_time(:seconds)}"
  end

  defp delete_params(token, file_id) do
    [body: "token=#{token}&file=#{file_id}&set_active=true&_attemps=1"]
  end
end
