#!/usr/bin/env bash
set -e
if  [[ -d "./node_modules" && -n "$(ls -A ./node_modules)" ]]; then
    # Control will enter here if $DIRECTORY exists.
    echo "Skipping 'npm install' because 'node_modules already exists'. Delete 'node_modules' and restart the container if you want to reinstall binaries."
else
    echo "Installing dependencies (this will only run the first time your container is created. If 'node_modules' already exists, this will be skipped for subsequent containers)..."
    # npm run cli -- init
    npm install
    cd api && npm i
    npx lerna run build
fi


function bootstrap() {
  local warn=false

  if [ "${KEY}" == "" ] ; then
    export KEY=$(uuidgen)
    warn=true
  fi

  if [ "${SECRET}" == "" ] ; then
    export SECRET=$(node -e 'console.log(require("nanoid").nanoid(32))')
    warn=true
  fi

  if [ "${warn}" == "true" ] ; then
    print --level=warn --stdin <<WARN
>
>                         WARNING!
>
>  The KEY and SECRET environment variables are not set. Some
>  temporary variables were generated to fill the gap, but in
>        production this is going to cause problems.
>
>                        Reference:
> https://docs.directus.io/reference/environment-variables.html
>
>
WARN
  fi

  # Create folder if using sqlite and file doesn't exist
  if [ "${DB_CLIENT}" == "sqlite3" ] ; then
    if [ "${DB_FILENAME}" == "" ] ; then
      print --level=error "Missing DB_FILENAME environment variable"
      exit 1
    fi

    if [ ! -f "${DB_FILENAME}" ] ; then
      mkdir -p $(dirname ${DB_FILENAME})
    fi
  fi

  npx directus bootstrap
}

command=""
if [ $# -eq 0 ] ; then
  command="start"
elif [ "${1}" == "bash" ] || [ "${1}" == "shell" ] ; then
  shift
  exec bash $@
elif [ "${1}" == "command" ] ; then
  shift
  exec $@
else
  command="${1}"
  shift
fi

bootstrap
exec npx directus start $@

