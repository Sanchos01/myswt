defmodule Mix.Tasks.Myswt.Build do
	use Mix.Task
	def run(_) do
		case File.exists?("./priv/megaweb") do
			false -> 
				ReleaseManager.Utils.error "FAIL! First, do 'mix myswt.init'"
			true ->
				:os.cmd('cd ./priv/megaweb && npm install') |> to_string |> ReleaseManager.Utils.warn
				:os.cmd('cd ./priv/megaweb && bower install') |> to_string |> ReleaseManager.Utils.warn
				:os.cmd('cd ./priv/megaweb && brunch build') |> to_string |> ReleaseManager.Utils.warn
				:os.cmd('cd ./priv/megaweb/public && cp -R ./* ../../') |> to_string |> ReleaseManager.Utils.warn
				[_, version] = Regex.run(~r/^{\"versionExt\":\"([\d\.]+)\"}$/, File.read!("./priv/version.json") |> String.replace(" ", "") |> String.replace("\n", ""))
				ReleaseManager.Utils.info "got version #{version}"
				File.write!("./priv/js/app.js", File.read!("./priv/js/app.js") |> String.replace("__VERSION__", version))
				ReleaseManager.Utils.info "SUCCESS, attempt to build brunch was executed"
		end
	end
end