#!/bin/bash

if [ "$1" == "-f" -o "$1" == "--force" ]; then
  force=1
  shift
fi

# ----------------------------------------------------------------------------------------------------------------------

old_dir="$(pwd)"
cd "$(dirname "$0")/../assets/." && ASSETS="$(pwd)" && cd "$old_dir"
[ ! -e "$ASSETS" ] && echo "Failed to determine asset directory." && exit 2

function link {
  t="$2"; [ -z "$t" ] && t="$1"
  printf "Symlink: %s <- %s ... " "$1" "$t"
  s="$HOME/$1"
  t="$ASSETS/$t"
  [ ! -e "$t" ] && echo -e "aborting\nAsset not found: $t" && exit 3

  if [ ! -e "$s" ]; then
    ln -s "$t" "$s" && echo "ok" || echo "failed"
  elif [ -L "$s" ]; then
    rm "$s" && ln -s "$t" "$s" && echo "replaced link, ok" || echo "failed"
  elif [ -f "$s" -a ! -s "$s" ]; then
    rm "$s" && ln -s "$t" "$s" && echo "replaced empty file, ok" || echo "failed"
  elif [ -n "$force" ]; then
    rm -f "$s" && ln -s "$t" "$s" && echo "replaced existing file, ok" || echo "failed"
  else
    echo "already exists, aborting"
  fi
}

function source_script {
  t="$2"; [ -z "$t" ] && t="$1"
  printf "Source: %s <- %s ... " "$1" "$t"
  s="$HOME/$1"
  t="$ASSETS/$t"
  [ ! -e "$t" ] && echo -e "aborting\nAsset not found: $t" && exit 3

  cmd='[ -r "'"$t"'" ] && source "'"$t"'"'
  tmp=/tmp/golly-rc.$$.tmp
  (cat "$s" | fgrep -v "$cmd" && echo "$cmd") > $tmp
  if [ $? -ne 0 ]; then
    echo "failed"
  else
    cat $tmp > "$s" && echo "updated, ok" || echo "failed"
  fi
}

# ----------------------------------------------------------------------------------------------------------------------

link .aprc
link .gitconfig
link .irbrc
link .vimrc
link .tmux.conf
link .XCompose XCompose

mkdir -p ~/.atom
link .atom/keymap.cson
link .atom/styles.less

mkdir -p ~/.config/mpv
link .config/mpv/input.conf

source_script .bashrc shell.rc-bash
source_script .zshrc shell.rc-zsh

