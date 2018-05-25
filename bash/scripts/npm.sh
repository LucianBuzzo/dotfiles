function npm-which() {
  npm_bin=$(npm bin)
  bin_name=$1
  local_path="${npm_bin}/${bin_name}"

  if [[ -f $local_path ]]; then
    echo "$local_path"
  else
    which "$bin_name"
  fi
}
