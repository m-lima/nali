setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

function bd {
  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    cd -$1 > /dev/null
  else
    cd - > /dev/null
  fi

}

function bgb {
  if command -v tac &> /dev/null
  then
    local rev=('tac')
  else
    local rev=('tail' '-r')
  fi

  local branches=($(git rev-parse --absolute-git-dir 2> /dev/null | xargs -I{} grep '.*checkout: moving from' "{}/logs/HEAD" | ${rev} | awk 'NR>1{print NR" "$NF}' | sort -t ' ' -k2 -k1n | uniq -f1 | sort -n | head -9 | sed 's/.* //'))

  if [[ -z $branches ]]
  then
    echo 'No git branch history found' 2> /dev/null
    return -1
  fi

  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    git checkout "${branches[$1]}" > /dev/null
  else
    git checkout "${branches[1]}" > /dev/null
  fi
}

function vd {
  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    local it=$1
  else
    local it=1
  fi

  until [ $it -eq 0 ]
  do
    local BACK=../$BACK
    (( it-- ))
  done

  cd $BACK
}

function td {
  if [ "$1" ]
  then

    if [ ! -f ~/.config/m-lima/td/config ]
    then
      echo Entry file not found at "$HOME/.config/m-lima/td/config"
      return -1
    fi

    while read line
    do
      entry="${line%%:*}"
      case $entry in
        $1)
          dir="${line#*:}"
          eval cd $dir/$2
          return
          ;;
      esac
    done < ~/.config/m-lima/td/config
    echo Entry not found
    return -1

  else
    cd ~
  fi
}
