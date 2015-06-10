defmodule Mix.Tasks.Myswt.Init do
	use Mix.Task
	def run(_) do
		case File.exists?("./priv") do
			true -> 
				ReleaseManager.Utils.error "FAIL, priv dir is already exist!"
			false ->
				:os.cmd('cd ./deps/myswt && git submodule init && git submodule update') |> ReleaseManager.Utils.warn
				File.cp_r!(Exutils.priv_dir(:myswt)<>"/priv", "./priv")
				:os.cmd('cd ./priv/megaweb && rm -rf ./.git*') |> ReleaseManager.Utils.warn
				:os.cmd('cd ./priv/megaweb/app/scripts/ && sed -i -e \'s/:8081/:#{:application.get(:myswt, :server_port, nil)}/\' ./app.coffee') |> ReleaseManager.Utils.warn
				ReleaseManager.Utils.info "SUCCESS, priv dir with MYSWT template created!"
		end
	end
end