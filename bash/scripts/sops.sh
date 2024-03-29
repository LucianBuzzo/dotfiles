sops_decrypt() {
  if [ -z "$1" ]; then
    echo "Usage: decrypt_sops <path/to/sops.filename.yml>"
    return 1
  fi

  encrypted_file="$1"

  if [ ! -f "${encrypted_file}" ]; then
    echo "Error: Encrypted file '${encrypted_file}' not found."
    return 1
  fi

  decrypted_file="${encrypted_file%.*}.yml"
  decrypted_file="${decrypted_file/sops./}"

  sops -d "${encrypted_file}" > "${decrypted_file}"
  echo "Decrypted '${encrypted_file}' to '${decrypted_file}'"
}

sops_encrypt() {
  if [ -z "$1" ]; then
    echo "Usage: encrypt_sops <path/to/filename.yml>"
    return 1
  fi

  decrypted_file="$1"
  encrypted_file="${decrypted_file%.*}.yml"
  encrypted_file="sops.${decrypted_file##*/}"

  if [ ! -f "${decrypted_file}" ]; then
    echo "Error: Decrypted file '${decrypted_file}' not found."
    return 1
  fi

  kms_file="$HOME/.sops_kms_arns"

  if [ ! -f "${kms_file}" ]; then
    touch "${kms_file}"
  fi

  use_existing_key=""
  while [[ "$use_existing_key" != "y" && "$use_existing_key" != "n" ]]; do
    echo -n "Do you want to use a pre-existing KMS key? (y/n): "
    read -r use_existing_key
  done

  if [ "$use_existing_key" = "y" ]; then
    options=($(awk -F'\t' '{print $1 "\t" $2 "\t" $3}' "${kms_file}"))
    echo "Select a KMS ARN:"
    printf "%-4s | %-12s | %-50s | %-20s\n" "No." "Date" "ARN" "Label"
    echo "--------------------------------------------------------------------------------------------"
    index=1
    for ((i = 0; i < ${#options[@]}; i += 3)); do
      printf "%-4d | %-12s | %-50s | %-20s\n" "${index}" "${options[i]}" "${options[i+1]}" "${options[i+2]}"
      index=$((index + 1))
    done
    echo -n "Enter the number of the KMS ARN: "
    read -r choice
    kms_arn="${options[((choice - 1) * 3 + 1)]}"
  else
    echo -n "Enter new KMS ARN: "
    read -r new_kms_arn
    if [ -z "${new_kms_arn}" ]; then
      echo "Invalid KMS ARN. Aborting."
      return 1
    fi
    echo -n "Enter a label for the new KMS ARN: "
    read -r new_label
    if [ -z "${new_label}" ]; then
      echo "Invalid label. Aborting."
      return 1
    fi
    current_date=$(date "+%Y-%m-%d")
    echo -e "${current_date}\t${new_kms_arn}\t${new_label}" >> "${kms_file}"
    kms_arn="${new_kms_arn}"
  fi

  sops -e --kms "${kms_arn}" --encrypted-regex '^(data|stringData)$' "${decrypted_file}" > "${encrypted_file}"
  echo "Encrypted '${decrypted_file}' to '${encrypted_file}' using KMS ARN '${kms_arn}'"
}
