#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export VISUAL=nvim
export EDITOR=nvim

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

alias ls='exa --icons -F -H --group-directories-first --git -1'
alias grep='grep --color=auto'
alias cd='z'

neofetch
eval "$(starship init bash)"
eval "$(zoxide init bash)"