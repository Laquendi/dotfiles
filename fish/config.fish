fish_vi_key_bindings
set -x fish_escape_delay_ms 10
set -x fish_greeting ''
set -x EDITOR nvim 

# alt-v to enter editor in insert mode
bind -M insert \ev edit_command_buffer

# visual mode movement
bind -M visual f forward-jump
bind -M visual F backward-jump
bind -M visual t forward-jump-till
bind -M visual T backward-jump-till
bind -M visual ';' repeat-jump
bind -M visual , repeat-jump-reverse
