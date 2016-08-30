defmodule Mix.Tasks.Myswt.Build do
	use Mix.Task
	def run(args) do
		Enum.each([:bullet, :conform, :cowboy, :cowlib, :exactor, :exrm, :extask, :exutils, :hashex, :jazz, :logex, :mimetypes, :quickrand, :ranch, :silverb, :tinca, :uuid, :tools], &(:application.start(&1)))
		sudo = 	case args do
					[] -> ""
					["sudo"] -> "sudo"
					err ->
						mess = "FAIL! Incorrect args #{inspect err}. Usage : 'mix myswt.build' | 'mix myswt.build sudo'"
						Myswt.Console.error(mess)
						raise(mess)
				end
		case File.exists?("./priv/megaweb") do
			false ->
				Myswt.Console.error("FAIL! First, do 'mix myswt.init'")
			true ->
				:os.cmd('cd ./priv/megaweb && #{sudo} npm install') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb && bower install') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb && brunch b --production') |> to_string |> Myswt.Console.warn
				:os.cmd('cd ./priv/megaweb/public && cp -R ./* ../../') |> to_string |> Myswt.Console.warn
				:os.cmd('cp ./priv/megaweb/favicon.ico ./priv/favicon.ico') |> to_string |> Myswt.Console.warn
				[_, version] = Regex.run(~r/^{\"versionExt\":\"([\d\.]+)\"}$/, File.read!("./priv/version.json") |> String.replace(" ", "") |> String.replace("\n", ""))
				Myswt.Console.notice("got version #{version}")
				case :application.get_env(:myswt, :server_port, nil) do
					port when (is_integer(port) and (port > 0)) ->
						Myswt.Console.notice("got port #{port}")
						File.write!("./priv/js/app.js", File.read!("./priv/js/app.js") |> String.replace("__VERSION__", version) |> String.replace("__PORT__", to_string(port)))
						Myswt.Console.notice("SUCCESS, attempt to build brunch was executed")
					error ->
						mess = "wrong port #{error}"
						Myswt.Console.error(mess)
						raise(mess)
				end
		end
	end
end
