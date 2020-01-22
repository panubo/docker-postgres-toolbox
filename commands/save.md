# Save database

Command to save databases.

## Features

* Support for plain and custom formats (see https://www.postgresql.org/docs/11/app-pgdump.html)
* Support for various compressions types (gzip, lz4, bzip2, none)
* Support for sha256 checksums during pg_dump operation
* Saves postgres globals
* Support to upload dumps to S3 or Google Cloud Storage

## Configuration

See [common usage](common.md)

Additionally this command supports

```
Usage: save [GLOBAL_OPTIONS] [OPTIONS] [DATABASE...] DESTINATION
Options:
    --pgdump-args    NOT IMPLEMENTED
    --format    plain|custom
    --compression    gzip|lz4|bz2|none
    --date-format    %Y%m%d%H%M%S
    --checksum    sha256
    --umask    0077
    --skip-globals    skip dumping postgres globals

    DATABASE    database(s) to dump. Will dump all if no databases are specified.
    DESTINATION    Destination to save database dumps to. s3://, gs:// and files are supported.
```

## Usage Example

```
docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASSWORD=foo docker.io/panubo/postgres-toolbox save /srv
```
