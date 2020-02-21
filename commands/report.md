# Report

The report script runs a report on common config and object within a database. It is intended to be useful to compare databases during a migration process to ensure migrations are run as intended.

## Included items

* Client and Server versions
* Encoding and Collate
* Database, schema and table owners
* Schemas and ACLs
* Count of objects in schemas
* Estimated rows in tables
* Extensions and versions
* Indexes

## Usage example

```
docker run --rm -it panubo/postgres-toolbox:latest report -h 172.18.0.2 -W password -U myapp mydatabase

# diff
diff -y -W $COLUMNS before.txt after.txt
```
