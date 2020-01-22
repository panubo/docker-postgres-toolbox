# Development guide

* Any additional echos must be to stderr so the output can be piped directly into another command

```
# Start a postgres server
docker run -d --name myapp-db -e POSTGRES_PASSWORD=password -e POSTGRES_USER=myapp -e POSTGRES_DB=myapp postgres:9.6

# Connect with psql
make shellcheck build-quick
docker run --rm -it panubo/postgres-toolbox:latest psql -h 172.18.0.2 -W password -U myapp -d myapp
```
