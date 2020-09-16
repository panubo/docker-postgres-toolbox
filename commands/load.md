# Load database

Command to load database saves.

NB. This does not preserve ownership or ACLs. This command is used to reload
or migrate databases with the presumption that the database is owned by a user
with the same name. When loading an empty database must already exist.

## Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_PORT` = TCP Port of PostgreSQL service.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.

### Environment Options

- `DUMP_DIR` load databases from this location (expects sql.gz)

### Options

- `<databases>...` name of database(s) to load. If not specified all databases will be loaded.

## Usage Example

```docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo -e DUMP_DIR=/srv docker.io/panubo/postgres-toolbox:1.0.0 load```
