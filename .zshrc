#  _  ___      _        _             _             _
# | |/ (_) ___| | _____| |_ __ _ _ __| |_   _______| |__
# | ' /| |/ __| |/ / __| __/ _` | '__| __| |_  / __| '_ \
# | . \| | (__|   <\__ \ || (_| | |  | |_ _ / /\__ \ | | |
# |_|\_\_|\___|_|\_\___/\__\__,_|_|   \__(_)___|___/_| |_|
#
# About:
#   Kickstart.zsh is meant to be used as a starting point for a user's own configuration.
#   Remove the things you don't use and add what you miss.
#
# URL: https://github.com/NNBnh/kickstart.zsh


# Plugins ------------------------------------------------------------------------------------------

# Install Zinit if it haven't already.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
test -f "${ZINIT_HOME}/zinit.zsh" \
|| git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
source "${ZINIT_HOME}/zinit.zsh"

# You can find more plugins on https://github.com/unixorn/awesome-zsh-plugins#plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light marlonrichert/zsh-autocomplete

# Install Starship if it haven't already.
command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh
eval "$(starship init zsh)"

# Install Mise if it haven't already.
#command -v ~/.local/bin/mise >/dev/null || curl -sS https://mise.run | sh
#eval "$(~/.local/bin/mise activate zsh)"

eval "$(zoxide init zsh)"

# Environment variables ----------------------------------------------------------------------------

# Support XDG Base Directory.
mkdir -p "${XDG_STATE_HOME:-${HOME}/.local/state}/zsh"
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/history"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompcache" \
&& zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompcache"

# History settings.
export HISTSIZE=50000
export SAVEHIST=10000

# Set default editor/pager.
export EDITOR='nvim'
export VISUAL="${EDITOR}"


# Options ------------------------------------------------------------------------------------------
# You can find all available options on https://zsh.sourceforge.io/Doc/Release/Options.html

# Changing Directories.
setopt auto_cd                   # Cd by enter a directory's path.
setopt auto_pushd                # Make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups         # Don't push multiple copies of the same directory onto the directory stack.
setopt pushd_minus               # Exchanges the meanings of '+' and '-' when used with a number to specify a directory in the stack.

# History.
setopt extended_history          # Record timestamp of command in HISTFILE.
setopt hist_expire_dups_first    # Delete duplicates first when HISTFILE size exceeds HISTSIZE.
setopt hist_ignore_dups          # Ignore duplicated commands history list.
setopt hist_ignore_space         # Ignore commands that start with space.
setopt hist_verify               # Show command with history expansion to user before running it.
setopt share_history             # Share command history data.

# Completion.
setopt always_to_end             # If a completion is performed and a full completion is inserted, the cursor is moved to the end of the word.
setopt auto_menu                 # Show completion menu on successive tab press.
setopt complete_in_word          # The cursor isn't set to the end of the word if completion is started.

# Expansion and Globbing.
setopt extended_glob             # Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc.
setopt glob_dots                 # Do not require a leading '.' in a filename to be matched explicitly.

# Misc.
setopt long_list_jobs            # Print job notifications in the long format by default.
setopt interactive_comments      # Allow comments even in interactive shells.
#setopt vi                       # Enable Vi keybindings.


# Aliases ------------------------------------------------------------------------------------------

alias l='ls -Ah --group-directories-first'
alias md='mkdir -p'
#alias dl='trash-put'
alias a='7z'
alias g='git'
alias slssteam='LD_AUDIT="/home/vee/Downloads/SLSsteam/bin/SLSsteam.so" nohup steam >/dev/null 2>&1 &'

# Functions ----------------------------------------------------------------------------------------

# Convenient selection for files management.
s() { selection=(); for item in "$@"; do selection+=("$(readlink -f "${item}")"); done }
mv() { if [ "$#" -eq 0 ]; then command mv -i  "${selection[@]}" .; else command mv -i  "$@"; fi }
cp() { if [ "$#" -eq 0 ]; then command cp -ir "${selection[@]}" .; else command cp -ir "$@"; fi }
ln() { if [ "$#" -eq 0 ]; then command ln -s  "${selection[@]}" .; else command ln -s  "$@"; fi }

# Ls whenever the current working directory is changed.
chpwd() { l; }


# Startup ------------------------------------------------------------------------------------------

#fastfetch
