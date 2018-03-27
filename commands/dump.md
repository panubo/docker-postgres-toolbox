# Dump database

Command to dump databases.

## Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_PORT` = TCP Port of PostgreSQL service.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.

### Environment Options

- `DUMP_DIR` dump databases to this location

### Options

- `<databases>...` name of database(s) to dump. If not specified all databases will be dumped.

## Usage Example

```docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo docker.io/panubo/postgres-toolbox dump```
