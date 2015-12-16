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
    files = Files.fetch(options[:token])
    files[:files]
    |> Enum.map( &Task.async(fn -> Janitor.post(options, &1) end) )
    |> Enum.map( &Task.await/1 )
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
