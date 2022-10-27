# Python script to ingest specialized `_cat` API output


## Purpose

Charles Davison has been ingesting the output of the `_cat` API in order to visualize ingestion rates in Kibana

This script will allow you to do the same

## Installation

Clone this repository, or copy these files to their own directory on your local filesystem

## Installing pre-requisites

For this to run, you will need a recent Python version (3.9 or 3.10 preferred).

If you are a python dev, make sure the modules in `requirements.txt` will not collide with anything you are working on, otherwise you can install the python requirements with:

```
pip install -U -r requirements.txt
```

## Running the script

### Get the source JSON

Have your customer run this and save the output as a JSON file.

```
GET /_cat/indices?v=true&h=health,index,uuid,pri,rep,docs.count,store.size,pri.store.size,creation.date.string&format=json&pretty&bytes=b
```

This will output a JSON array of documents, each one being a single index, e.g.:

```
  {
    "health": "green",
    "index": ".ds-metrics-system.diskio-default-2022.10.20-000050",
    "uuid": "9cw8JpuARN-0IMVE8axOjw",
    "pri": "1",
    "rep": "1",
    "docs.count": "14371007",
    "store.size": "7140672720",
    "pri.store.size": "3571826412",
    "creation.date.string": "2022-10-20T13:19:14.865Z"
  },
```

### Script execution sample

```
$ ./ingest_cat.py /path/to/filename
Index [myindex]:
Es host [http://127.0.0.1:9200]:
Username [elastic]:
Password:
Repeat for confirmation:
Creating index 'myindex'
  0%|▍                                                                                      | 1/209 [00:00<00:30,  6.82docs/s]Indexed 209/209 documents
100%|███████████████████████████████████████████████████████████████████████████████████| 209/209 [00:00<00:00, 1401.84docs/s]
```

### Script behavior

This script will normalize field names to use underscores instead of spaces so that `docs.count` becomes `docs_count`, and `creation.date.string` is renamed entirely to `@timestamp`.

The script _requires_ a filename to even execute, and will prompt you for the Elasticsearch URL, username, password, and index.

The script will create the index if it does not exist and currently has no logic to fail if the index already exists (feature requests accepted).

The script also uses the `streaming_bulk` helper in the Elasticsearch Python client, so you won't see the progress bar move except in large chunks, or if the count of indices is small enough, only one chunk.

The index will be created with the following mapping:

```
mappings={
            "properties": {
                "health": {"type": "keyword"},
                "index": {"type": "keyword"},
                "uuid": {"type": "keyword"},
                "pri": {"type": "short"},
                "rep": {"type": "short"},
                "docs_count": {"type": "long"},
                "store_size": {"type": "long"},
                "pri_store_size": {"type": "long"},
                "@timestamp": {"type": "date"},
            }
        }
```


