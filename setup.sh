#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
HOME=$( cd ~ && pwd )
ARG=$1

link_file() {
  local origin="$1"
  local dest="$2"
  local dialogue="\033[38;5;240mSymlinking ${DIR}/${origin} to ${dest}.\n"

  if [ ! -e "$dest" ]; then
    printf "$dialogue"
    ln -s "$DIR"/"$origin" "$dest"
  else
    if [ "$ARG" = "-y" ]; then
      printf "$dialogue"
      ln -sf "$DIR"/"$origin" "$dest"
    else
      printf "\033[38;5;160mA $(basename $dest) file already exists in your home directory.\n"
      printf "\033[38;5;240mWould you like to overwrite it with a symlink to ${dest}?\n"
      #read -n 1 replace
      select replace in "Yes" "No"; do
        case $replace in
          Yes )
            printf "$dialogue"
            ln -sf "$DIR"/"$origin" "$dest";
            break
            ;;
          No )
            printf "\033[38;5;136mNot symlinking and continuing with setup.\n"
            break
            ;;
        esac
      done
      echo
    fi
  fi
}

setuplinklist=(
  "vim/.vimrc ${HOME}/.vimrc"
  "vim/.vimbackups/ ${HOME}/.vimbackups"
  ".inputrc ${HOME}/.inputrc"
  "bash/.bash_profile ${HOME}/.bash_profile"
)

for i in "${setuplinklist[@]}"; do
  link_file $i
done

printf "\033[38;5;64mSetup complete, please reload your shell to see any changes.\033[0m\n"

# TODO: get the reload working correctly
# echo "\033[38;5;64mSetup complete, reloading now...\033[0m"
# 
# exec bash -lis
