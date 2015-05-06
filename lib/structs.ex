defmodule Myswt.Srtucts do
	defmacro __using__(_) do
		quote location: :keep do
			use Hashex, [
							__MODULE__.Proto
						]
			defmodule Proto do
				defstruct 	subject: "error",
							content: nil
			end
		end
	end
end

defmodule Myswt.ClientCallbacks do

	defmacro __using__(_) do
		quote location: :keep do
			use unquote(:application.get_env(:myswt, :callback_module, nil))
		end
	end

	def maybe_reset_priv do
		if not(File.exists?("./priv")) do
			File.cp!(Exutils.priv_dir(:myswt), "./priv")
		end
	end
end