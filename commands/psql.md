# PostgreSQL Client

Command to start an interactive PostgreSQL client session.

## Configuration

See [common usage](common.md)

Place any arguments for `psql` after `--`.

```
docker run --rm -it panubo/postgres-toolbox:latest psql -h 172.18.0.2 -W password -U myapp -- -c 'SELECT 1'
```
