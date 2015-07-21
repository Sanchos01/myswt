defmodule Mix.Tasks.Myswt.Build do
	use Silverb
	use Mix.Task
	def run(_) do
		case File.exists?("./priv/megaweb") do
			false -> 
				Myswt.Console.error "FAIL! First, do 'mix myswt.init'"
			true ->
				:os.cmd('cd ./priv/megaweb && npm install') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb && bower install') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb && brunch build') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb/public && cp -R ./* ../../') |> to_string |> Myswt.Console.warn
				[_, version] = Regex.run(~r/^{\"versionExt\":\"([\d\.]+)\"}$/, File.read!("./priv/version.json") |> String.replace(" ", "") |> String.replace("\n", ""))
				Myswt.Console.notice "got version #{version}"
				File.write!("./priv/js/app.js", File.read!("./priv/js/app.js") |> String.replace("__VERSION__", version))
				Myswt.Console.notice "SUCCESS, attempt to build brunch was executed"
		end
	end
end