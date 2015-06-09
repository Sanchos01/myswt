defmodule Mix.Tasks.Myswt.Build do
	use Mix.Task
	def run(_) do
		case File.exists?("./priv/megaweb") do
			true -> 
				ReleaseManager.Utils.error "FAIL! First, do 'mix myswt.init'"
			false ->
				:os.cmd('cd ./priv/megaweb && npm install') |> to_string |> IO.puts 
				:os.cmd('cd ./priv/megaweb && bower install') |> to_string |> IO.puts 
				:os.cmd('cd ./priv/megaweb && brunch build') |> to_string |> IO.puts 
				:os.cmd('cd ./priv/megaweb/public && mv ./* ../../') |> to_string |> IO.puts 
				ReleaseManager.Utils.info "SUCCESS, attempt to build brunch was executed"
		end
	end
end