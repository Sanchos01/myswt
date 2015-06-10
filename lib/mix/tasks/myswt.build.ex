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
				ReleaseManager.Utils.info "SUCCESS, attempt to build brunch was executed"
		end
	end
end