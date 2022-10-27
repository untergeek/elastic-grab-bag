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

## Script versions

* `ingest_cat_file.py` for running against customer provided output from the `_cat` API
* `ingest_cat8.py` for running in an Elasticsearch 8 cluster and ingesting the `_cat` API output directly into the same cluster in an index with the provided name

## Running the script

### For those using: `ingest_cat8.py`

Help output:

```
$ ./ingest_cat8.py --help
Usage: ingest_cat8.py [OPTIONS]

  Insert documents from filename into index at es_url using provided
  credentials

Options:
  --index TEXT
  --es_url TEXT
  --username TEXT
  --password TEXT
  --exclude_partial  Exclude indices starting with 'partial-'
  --help             Show this message and exit.
```

### For those using: `ingest_cat_file.py`

Help output:

```
$ ./ingest_cat_file.py --help
Usage: ingest_cat_file.py [OPTIONS] FILENAME

  Insert documents from filename into index at es_url using provided
  credentials

Options:
  --index TEXT
  --es_url TEXT
  --username TEXT
  --password TEXT
  --exclude_partial  Exclude indices starting with 'partial-'
  --help             Show this message and exit.
```

#### Get the source JSON

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

### Script execution sample (`ingest_cat_file.py`)

```
$ ./ingest_cat_file.py /path/to/filename
Index [myindex]:
Es host [http://127.0.0.1:9200]:
Username [elastic]:
Password:
Repeat for confirmation:
Creating index 'myindex'
  0%|▍                                                                                      | 1/209 [00:00<00:30,  6.82docs/s]Indexed 209/209 documents
100%|███████████████████████████████████████████████████████████████████████████████████| 209/209 [00:00<00:00, 1401.84docs/s]
```

### Script execution sample (`ingest_cat8.py`)

```
$ ./ingest_cat8.py
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

**NOTE:** If running `ingest_cat_file.py`, the script _requires_ a filename to even execute.

The script will prompt you for the Elasticsearch URL, username, password, and index.

The script will create the index if it does not exist and currently has no logic to fail if the index already exists (feature requests accepted).

**IMPORTANT:** With the frozen tier using fully cached indices using Searchable Snapshots, you will have indices whose names start with `partial-`. These indices should not be counted towards the hot/warm/cold tier sizing, so they need to be excluded. Use the `--exclude_partial` flag on the command-line to do this.

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

The end result, using the sample above, is individual documents like this:

```
      {
        "_index": "myindex",
        "_id": "9cw8JpuARN-0IMVE8axOjw",
        "_score": 1,
        "_source": {
          "health": "green",
          "index": ".ds-metrics-system.diskio-default-2022.10.20-000050",
          "uuid": "9cw8JpuARN-0IMVE8axOjw",
          "pri": "1",
          "rep": "1",
          "docs_count": "14371007",
          "store_size": "7140672720",
          "pri_store_size": "3571826412",
          "@timestamp": "2022-10-20T13:19:14.865Z"
        }
      },
```

