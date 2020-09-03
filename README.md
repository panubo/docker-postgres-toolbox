# PostgreSQL Toolbox

[![CircleCI](https://circleci.com/gh/panubo/docker-postgres-toolbox.svg?style=svg)](https://circleci.com/gh/panubo/docker-postgres-toolbox)

A collection of PostgreSQL scripts for automating common DBA tasks in a Docker-centric way.

## Documentation

Documentation for each subcommand:

- [create-user-db](commands/create-user-db.md)
- [delete-user-db](commands/delete-user-db.md)
- [create-readonly-user](commands/create-readonly-user.md)
- [save](commands/save.md)
- [load](commands/load.md)
- [fix-owner](commands/fix-owner.md)
- [vacuum](commands/vacuum.md)
- [psql](commands/psql.md)

## General Usage

Using Docker links to `postgres` container. This will display the usage information:

```docker run --rm -i -t --link myserver:postgres docker.io/panubo/postgres-toolbox```

To run the subcommand:

```docker run --rm -i -t --link myserver:postgres docker.io/panubo/postgres-toolbox <subcommand>```

## Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Or alternatively specify the environment variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_PORT` = TCP Port of PostgreSQL service.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.

Some subcommands require additional environment parameters.

## Status

Feature incomplete. Work in progress.
