# PostgreSQL Toolbox

A collection of PostgreSQL scripts for automating common DBA tasks in a Docker-centric way.

## Documentation

Documentation for each subcommand:

- [create-user-db](commands/create-user-db.md)
- [drop-user-db](commands/drop-user-db.md)
- [pg-ping](commands/pg-ping.md)
- [pganalyze](commands/pganalyze.md)
- [psql](commands/psql.md)
- [report](commands/report.md)
- [save](commands/save.md)
- [vacuum](commands/vacuum.md)

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

## Testing

[bats](https://bats-core.readthedocs.io/en/stable/index.html) is used for testing. To test the image and commands bats and docker are required. Use the following commands to run all of the tests.

```
make build-with-cache # or make build
make test
```

All tests are kept in `tests/` and all of the extension `.bats`. `test_functions.bash` is also loaded by each test. The functions include a setup and teardown (see bats docs) which creates and destroys a postgres target server.

Using bats setup and teardown and avoiding exposing postgres ports etc should allow tests to be run in parallel.

## Status

Feature incomplete. Work in progress.
