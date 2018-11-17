# Defined in /home/santtu/.config/fish/functions/fish_user_key_bindings.fish @ line 2
function fish_user_key_bindings
	for mode in insert default visual
		bind -M $mode \cF forward-char
	end
end
