# shellcheck disable=SC2034 shell=bash

# The docker.io/postgres image uses the following env vars
# POSTGRES_PASSWORD
# POSTGRES_USER
# POSTGRES_DB

# Postgres also supports environment variables https://www.postgresql.org/docs/current/libpq-envars.html
# PGPASSWORD
# PGUSER
# PGDATABASE
# PGHOST
# PGPORT
# PGPASSFILE

# Original env vars
# HOST=${DATABASE_HOST-${POSTGRES_PORT_5432_TCP_ADDR-localhost}}
# PORT=${DATABASE_PORT-${POSTGRES_PORT_5432_TCP_PORT-5432}}
# USER=${DATABASE_USER-${POSTGRES_ENV_POSTGRES_USER-postgres}}
# DATABASE=${DATABASE_NAME-${POSTGRES_ENV_POSTGRES_DATABASE-postgres}}
# PASS="${DATABASE_PASS-${POSTGRES_ENV_POSTGRES_PASSWORD}}"
# export PGPASSWORD="${PASS}"
# PGCONN="--username=${USER} --host=${HOST} --port=${PORT}"
# PSQL="psql ${PGCONN} --dbname=${DATABASE}"
# PGDUMP="pg_dump ${PGCONN}"
# GZIP="gzip --fast"

# shellcheck disable=SC1091
. /panubo-functions.sh

global_options() {
    echoerr "Global Options: (where possible these options match psql options)"
    echoerr "    -h|--host    host to connect to"
    echoerr "    -p|--port    post to connect to"
    echoerr "    -U|--username    user to connect with"
    echoerr "    -d|--dbname    database to connect to"
    echoerr "    -W|--password    password to connection to (not recommended. Use password-file)"
    echoerr "    --password-file    password file to read password from"
    echoerr "    --skip-database    databases to skip"
}

parse_options() {
    # Function parses the following options from both the command line and environment variables
    # Command line options take precedence and if neither is set commands should fall back to
    # default postgres environment variables.

    # Connection options
    # h|host
    # p|port
    # U|user
    # d|dbname

    # Password options
    # W|password
    # password-file

    # Create User DB options
    # no-create-database
    # no-revoke-public-create

    # Drop User DB options
    # drop-database

    # We don't want to pass these back to the caller
    local password
    local password_file

    # Pull in environment variables prefixed with DATABASE_
    for item in host port username dbname password password_file no_create_database no_revoke_public_create drop_database; do
        local varname
        varname="DATABASE_${item^^}"
        if [[ -n "${!varname:-}" ]]; then
          eval ${item}="${!varname}"
        fi
    done

    # Pull in environment variables prefixed with TOOLBOX_
    # TOOLBOX_SKIP_DATABASES should be comma separated
    for item in skip_databases format compression umask; do
        local varname
        varname="TOOLBOX_${item^^}"
        if [[ -n "${!varname:-}" ]]; then
          eval ${item}="${!varname}"
        fi
    done

    # Pull in *-args environment variables
    for item in aws_args pgdump_args; do
        local varname
        varname="${item^^}"
        if [[ -n "${!varname:-}" ]]; then
          IFS=$' \n\t' eval read -r -a ${item} <<<"${!varname}"
        fi
    done

    # Options and long options
    local options="h:p:U:d:W:"
    local longopts="host:,port:,username:,dbname:,password:,password-file:,no-create-database,no-revoke-public-create,drop-database,format:,compression:,umask:,skip-globals,skip-database:,skip-analyze,full-count,aws-args:,pgdump-args:"
    local parsed

    # Parse with getopt (not getopts)
    ! parsed=$(getopt --quiet --options=${options} --longoptions=${longopts} --name "${0}" -- "${@}")
    eval set -- "${parsed}"
    while true; do
      case "${1}" in
        -h|--host)
          host="${2}"
          shift 2
          ;;
        -p|--port)
          port="${2}"
          shift 2
          ;;
        -U|--username)
          username="${2}"
          shift 2
          ;;
        -d|--dbname)
          dbname="${2}"
          shift 2
          ;;
        -W|--password)
          password="${2}"
          shift 2
          ;;
        --password-file)
          password_file="${2}"
          shift 2
          ;;
        --skip-database)
          skip_databases+=( "${2}" )
          shift 2
          ;;
        --no-create-database)
          no_create_database="true"
          shift
          ;;
        --no-revoke-public-create)
          no_revoke_public_create="true"
          shift
          ;;
        --drop-database)
          drop_database="true"
          shift
          ;;
        --format)
          format="${2}"
          shift 2
          ;;
        --umask)
          umask="${2}"
          shift 2
          ;;
        --compression)
          compression="${2}"
          shift 2
          ;;
        --skip-globals)
          skip_globals="true"
          shift
          ;;
        --skip-analyze)
          skip_analyze="true"
          shift
          ;;
        --full-count)
          full_count="true"
          shift
          ;;
        --aws-args)
          IFS=$' \n\t' read -r -a aws_args <<<"${2}"
          shift 2
          ;;
        --pgdump-args)
          IFS=$' \n\t' read -r -a pgdump_args <<<"${2}"
          shift 2
          ;;
        --)
          shift
          break
          ;;
        *)
          echo "Unrecognised option"
          exit 3
          ;;
      esac
    done

    # Setup connection string (common)
    connection=()
    for item in host port username dbname; do
        if [[ -n "${!item:-}" ]]; then
          connection+=("--${item}=${!item}")
        fi
    done

    # Setup connection string (analyze, pg_dump, vacuum)
    connection_no_dbname=()
    for item in host port username; do
        if [[ -n "${!item:-}" ]]; then
          connection_no_dbname+=("--${item}=${!item}")
        fi
    done

    # Set remaining command line arguments into an array
    args=( "$@" )

    # Read in the password file if set
    if [[ -n "${password_file:-}" ]]; then
        # Read password file if set on the command line or DATABASE_PASSWORD_FILE
        password="$(cat "${password_file}")"
    fi

    # If the password was set write it to .pgpass (or save a temporary file and set PGPASSFILE)
    if [[ -n "${password:-}" ]]; then
        local old_umask
        old_umask="$(umask)"
        umask 0077
        PGPASSFILE="$(mktemp)"
        export PGPASSFILE
        echo "*:*:*:*:${password}" > "${PGPASSFILE}"
        umask "${old_umask}"
        echoerr ">>> Password written to ${PGPASSFILE}"
    fi

    # If skip_databases was set, split into an array
    if [[ -n "${skip_databases:-}" ]]; then
        # shellcheck disable=SC2128
        IFS=',' read -r -a skip_databases <<< "${skip_databases}"
    fi
}

echoerr() { echo "$@" 1>&2; }

genpasswd() {
  # Ambiguous characters have been been excluded
  CHARS="abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

  export LC_CTYPE=C  # Quiet tr warnings
  local length
  length="${1:-16}"
  set +o pipefail
  strings < /dev/urandom | tr -dc "${CHARS}" | head -c "${length}" | xargs
  set -o pipefail
}

wait_postgres() {
  wait_tcp "${host:-${PGHOST:-127.0.0.1}}" "${port:-${PGPORT:-5432}}"
}
