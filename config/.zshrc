# --- export path ---
export PATH=$PATH:$HOME/.local/bin:/usr/bin/ruby3.0:$HOME.go/bin
export PATH=$PATH:$HOME/.rvm/bin
export DEBIAN_FRONTEND=noninteractive
export GOPATH=$HOME/.go
# --- fix the java problem ---
export _JAVA_AWT_WM_NONREPARENTING=1
# --- interactive shells ---
# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples
setopt autocd              # change directory just by typing its name
setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# --- hide eol sign ('%') ---
PROMPT_EOL_MARK=""
# --- keybindings ---
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# --- completion features ---
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# --- history ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# --- complete history ---
alias history="history 0"

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# --- override default virtualenv indicator ---
VIRTUAL_ENV_DISABLE_PROMPT=1
venv_info() {
    [ $VIRTUAL_ENV ] && echo "(%B%F{reset}$(basename $VIRTUAL_ENV)%b%F{%(#.blue.green)})"
}

# --- set a fancy prompt (non-color, unless we know we "want" color) ---
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then

# --- prompt  ---
# Define ANSI color codes using tput (keep these)
reset_color="$(tput sgr0)"
black="$(tput setaf 0)"
dark_grey="$(tput setaf 242)"
light_grey="$(tput setaf 253)"
red="$(tput setaf 160)"
bright_red="$(tput setaf 9)"
dark_red="$(tput setaf 124)"

n=$'\n'
exit_status='%(!.#.%?)'

update_prompt() {
  local ipaddr
  grepnet="grep -oP 'inet \\K\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}'"

  # Define an array of interfaces to check
  interfaces=("tun0" "tap0" "eth0" "wlan0" "wlan1")

  for iface in "${interfaces[@]}"; do
    if ifconfig "$iface" > /dev/null 2>&1; then
      ipaddr=$(ifconfig "$iface" 2>/dev/null | eval $grepnet)
      # Break only if a valid IP address is found
      if [[ -n $ipaddr ]]; then
        break
      fi
    fi
  done
  # Default to "offline" if no interface is active
  ipaddr=${ipaddr:-"offline"}
  
  local last_exit_status=$?
  # Set the exit_status based on the last command's exit status
  if [[ $last_exit_status -ne 0 ]]; then
    exit_status="%{$fg[red]%}$last_exit_status%{$reset_color%} " # Red for non-zero
  else
    exit_status="" # Blank for zero
  fi
  PROMPT="%{$red%}[%n%m]-[$ipaddr]-[%{$light_grey%}%~%{$red%}]${exit_status}$ "
  #RPROMPT=''
}

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Disable unnecessary newlines before the prompt
    if [ "$new_line_before_prompt" = yes ] && [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
        _NEW_LINE_BEFORE_PROMPT=1
    fi
}

# Initial prompt update
update_prompt
# ---  colors  ---

greencolor="\e[0;32m\033[1m"
endcolor="\033[0m\e[0m"
redcolor="\e[0;31m\033[1m"
bluecolor="\e[0;34m\033[1m"
yellowcolor="\e[0;33m\033[1m"
purplecolor="\e[0;35m\033[1m"
turquoisecolor="\e[0;36m\033[1m"
graycolor="\e[0;37m\033[1m"

# --- syntax ---
    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && [ "$color_prompt" = yes ]; then
	. /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
	ZSH_HIGHLIGHT_STYLES[default]=none
	ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
	ZSH_HIGHLIGHT_STYLES[path]=underline
	ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
	ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[command-substitution]=none
	ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[process-substitution]=none
	ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
	ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
	ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
	ZSH_HIGHLIGHT_STYLES[assign]=none
	ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[comment]=fg=8,bold
	ZSH_HIGHLIGHT_STYLES[named-fd]=none
	ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
	ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
	ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
	ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
	ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# --- if this is an xterm set the title to user@host:dir ---
case "$TERM" in
xterm*|rxvt*)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a'
    ;;
*)
    ;;
esac

new_line_before_prompt=no
precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$new_line_before_prompt" = yes ]; then
	if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
	    _NEW_LINE_BEFORE_PROMPT=1
	else
	    print ""
	fi
    fi
}

# --- color support of ls ---
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto --unified=0'
    alias ip='ip --color=auto'
    alias krita='krita --nosplash $1&'
    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# --- more aliases ---
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='batcat --paging=never --style=plain'
alias trans='trans --brief'
alias ris="ristretto"
alias kp="kolourpaint"
alias torwho="whois -h torwhois.com"
alias cls="clear"
alias img="w3m -o ext_image_viewer=0"
alias bspwmrc=". ~/.config/bspwm/bspwmrc"
alias virtualbox="virtualbox -style fusion %U"
alias less="batcat -p --color=always"
alias cal="ncal -C"
alias acs="apt-cache search"
alias del="/bin/rm -rfi"
alias 'which'="which -a"
alias yp3="youtube-dl -x --audio-format mp3 --audio-quality 128K  --output '%(title)s.%(ext)s'"
alias yp4="youtube-dl --format mp4  --output '%(title)s.%(ext)s'"
alias ydl="youtube-dl"
alias ct="cherrytree"
alias picom="picom -b >/dev/null 2>&1 &;disown" # --experimental-backends --backend glx >/dev/null 2>&1 & ;  disown"
alias python='python -W "ignore"'
alias smbmap='smbmap --no-banner'
alias verse="verse | tr -s ' '| tr -d '\n' | sed 's/^ //'"

# --- autosugestions ---
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# --- command-not-found ---
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# --- plugins ---
#source $HOME/.zsh_plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh


# --- functions ---

function zat(){
  zathura $1 >/dev/null 2>&1 &; disown  
}

function java11(){
echo "switching to java 11..."
sudo update-java-alternatives -s java-1.11.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME
java --version

}

function java17(){
echo "switching to java 17..."
sudo update-java-alternatives -s java-1.17.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME
java --version
}

function w32(){
	export WINEARCH=win32
	export WINEPREFIX=~/.wine32

}

function w64(){
	export WINEARCH=win64
	export WINEPREFIX=~/.wine
}

function wttr(){
	curl wttr.in
}

function mkt(){
if [ -z "$1" ]
then
  echo "Provide a Folder name\nusage: mkt <foldername>" 
else
  echo "\n[ Creating folder $1 @ $PWD ]\n"
  mkdir -p $1/{content,exploits,nmap} 
  cd $1
  ls -lha
fi
}
 
function xps(){
if [ -z "$1" ]
then
  echo "Provide a file\nusage: xps <filename>"
else
  ip_Oaddress=$( grep --color=never -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' $1 | sort -u  )
  ports_Ofile=$( grep --color=never -oP '\d{1,5}/open' $1 | awk '{print $1}' FS="/" | xargs | tr " " "," )
  echo -e "${graycolor}[${greencolor}+${graycolor}]${endcolor} command copied to clipboard, run:\nsudo nmap -sVC -p$ports_Ofile --min-rate=5000 -n -Pn $ip_Oaddress -oN targeted"
  echo -e "sudo nmap -sVC -p$ports_Ofile --min-rate=5000 -n -Pn $ip_Oaddress -oN targeted" | tr -d '\n' | xclip -sel clip
fi
}

function mac(){
 find /sys/class/net -mindepth 1 -maxdepth 1 ! -name lo -printf "%P: " -execdir cat {}/address \; \
| sort -n -r \
| awk '{printf "\033[01;32m%s\033[0m - \033[01;31m%s\033[0m\n",$1,$2 }'
}

function macc(){
  sudo ifconfig $1 down
  sudo macchanger -A $1
  sudo ifconfig $1 up
}

function wow(){
  sudo ifconfig wlan0 down
  sudo macchanger -m 14:3e:60:32:1d:21 wlan0
  sudo ifconfig wlan0 up
}

function rmk() {
  for item in "$@"; do
    if [[ -d "$item" ]]; then
      # If the item is a directory, remove it and all its contents securely
      find "$item" -type f -exec scrub -p dod {} \; -exec shred -zvun 9 -v {} \;
      find "$item" -depth -type d -exec rmdir {} \;
      if [[ $? -eq 0 ]]; then
        echo "Directory $item and its contents have been securely removed."
      else
        echo "Failed to remove directory $item or some of its contents."
      fi
    elif [[ -f "$item" ]]; then
      # If the item is a file, use the existing method
      scrub -p dod "$item"
      shred -zvun 9 -v "$item"
    else
      echo "Item $item does not exist or is neither a file nor a directory."
    fi
  done
}

function afu()
{
sudo apt update -y
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" dist-upgrade -q -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
}

get_resolution() {
  xrandr | grep '*' | awk '{print $1}'
}

function lock_screen() {
  local resolution=$(get_resolution)
  convert ~/.config/i3lock/stop.png -gravity center -background black -extent "$resolution" ~/.config/i3lock/centered_stop.png
  i3lock -c 000000 -i ~/.config/i3lock/centered_stop.png
}

function rm() {
  # Prompt for confirmation before removing anything
  echo -n "Are you sure you want to delete $@? [y/N] "
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    command rm "$@"
  else
    echo "Deletion canceled."
  fi
}

# --- misc ---

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export TERM=xterm-256color

# --- transient  prompt ---

#: << 'com'
zle-line-init() {
  emulate -L zsh  # Use a local zsh emulation scope for safety

  # Return early if not at the start of a new line/context
  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local ret=$?
    # Exit loop if Ctrl-D is pressed (`$'\4'`) or return status isn't zero
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0  # Exit shell if EOF is not ignored
  done

  # Save the current prompt settings
  local saved_prompt=$PROMPT
  #local saved_rprompt=$RPROMPT

  # Set a simplified transient prompt and refresh display
  PROMPT='${red}\$ '  # Use $ as a transient prompt
  RPROMPT=''          # Clear the right prompt
  zle .reset-prompt

  # Restore the original prompt settings
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  # Handle the return behavior
  if (( ret )); then
    zle .send-break  # Send a break signal for non-zero return
  else
    zle .accept-line  # Accept the input line for successful execution
  fi
  return $ret  # Return the original status
}

# Bind the custom zle-line-init function
zle -N zle-line-init
#com
