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

function export_npm_token() {
  echo "Exporting npm token from .npmrc file..."
  if [[ -f ~/.npmrc ]]; then
      token=$(grep -oP '(?<=//registry.npmjs.org/:_authToken=)\S+' ~/.npmrc)
      if [[ -n "$token" ]]; then
          export NPM_TOKEN=$token
          export CEREBRUM_NPM_TOKEN=$token
          echo "NPM_TOKEN exported successfully."
      else
          echo "Could not find a token in the .npmrc file."
      fi
  else
      echo ".npmrc file does not exist."
  fi
}

