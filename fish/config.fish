fish_vi_key_bindings
set -x fish_escape_delay_ms 10
set -x fish_greeting ''

if status is-interactive
and not set -q TMUX
	exec tmux
end
