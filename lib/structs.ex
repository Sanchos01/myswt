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

	def create_priv do
		main_priv = Exutils.priv_dir(:application.get_env(:myswt, :app, nil))
		File.mkdir(main_priv)
		File.ln_s(Exutils.priv_dir(:myswt), main_priv<>"/myswt")
	end
end