function update_aws_env_vars() {
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    node "$DIR/aws-credentials-to-env.js"
}

