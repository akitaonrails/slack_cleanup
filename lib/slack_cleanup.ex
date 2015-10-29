defmodule SlackCleanup do
  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given"
  end

  def process(options) do
    IO.puts "Domain: #{options[:domain]}, Token: #{options[:token]}"
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [domain: :string, token: :string]
    )
    options
  end
end
