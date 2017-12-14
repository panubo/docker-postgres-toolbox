# PostgreSQL Client

Command to start an interactive PostgreSQL client session.

## Configuration

Use `--link <postgres container name>:postgres` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of PostgreSQL server.
- `DATABASE_USER` = Administrative user eg postgres with SUPERUSER privileges.
- `DATABASE_PASS` = Password of administrative user.
