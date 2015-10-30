defmodule SlackCleanup do
  alias SlackCleanup.Files
  alias SlackCleanup.Janitor

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "Usage: slack_cleanup --token=YOUR_SLACK_TOKEN --domain=YOUR_SLACK_DOMAIN"
  end

  def process(options) do
    Files.fetch(options[:token])
    |> Enum.map( fn (item) -> Task.async(fn -> Janitor.post(options, item) end) end )
    |> Enum.map( fn (task) -> Task.await(task) end )
    |> Enum.each( fn (response) -> 
      case response do
        {:ok, permalink}            -> IO.puts "Successfully deleted #{permalink}"
        {:error, permalink, reason} -> IO.puts "Failed to delete #{permalink} - #{reason}"
      end
    end)
    IO.puts("Finished.")
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [domain: :string, token: :string]
    )
    options
  end
end
