# Fix Owner

Command to fix schema ownership.

This changes the schema ownership to match the database name.

## Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_PORT` = TCP Port of PostgreSQL service.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.

### Options

- `<databases>...` name of database(s) to fix.

## Usage Example

```docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo  docker.io/panubo/postgres-toolbox:1.0.0 acme_prod```
