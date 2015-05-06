defmodule Mix.Tasks.Myswt.Reset do
	use     Mix.Task
	def run(_) do
		case File.exists?("./priv") do
			true -> 
				IO.puts "FAIL, priv dir is already exist!"
			false ->
				File.cp!(Exutils.priv_dir(:myswt), "./priv")
				IO.puts "SUCCESS, priv dir with MYSWT template created!"
		end
	end
end