if status is-interactive
    # Commands to run in interactive sessions can go here
end

zoxide init fish | source
set -g fish_greeting
abbr -a -- slssteam 'LD_AUDIT="/home/vee/Downloads/SLSsteam/bin/SLSsteam.so" nohup steam &> /dev/null & disown'
