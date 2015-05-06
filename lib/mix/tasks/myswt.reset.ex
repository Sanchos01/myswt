defmodule Mix.Tasks.Myswt.Reset do
	use     Mix.Task
	def run(_) do
		case File.exists?("./priv") do
			true -> 
				File.cp!(Exutils.priv_dir(:myswt), "./priv")
				IO.puts "SUCCESS, priv dir with MYSWT template created!"
			false ->
				IO.puts "FAIL, priv dir is already exist!"
		end
	end
end