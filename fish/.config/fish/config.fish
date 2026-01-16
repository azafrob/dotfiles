if status is-interactive
# Commands to run in interactive sessions can go here
atuin init fish | source
end

zoxide init fish | source

# opencode
fish_add_path $HOME/.opencode/bin

fish_add_path $HOME/.spicetify
