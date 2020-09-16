# Delete PostgreSQL users and databases

Command to delete PostgreSQL users and correspondingly named databases.

## Environment Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Or alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_PORT` = TCP Port of PostgreSQL service.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.

### Options

- `--no-delete-database` don't delete database
- `<username>` - required

## Example Usage

Delete `foo` user and database with the same name:

```docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo docker.io/panubo/postgres-toolbox:1.0.0 delete-user-db foo```

Using Docker links to `postgres` container:

```docker run --rm -i -t --link myserver:postgres docker.io/panubo/postgres-toolbox:1.0.0 delete-user-db foo```
