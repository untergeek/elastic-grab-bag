#!/usr/bin/env python
import json
import tqdm
import click
from elasticsearch8 import Elasticsearch
from elasticsearch8.helpers import streaming_bulk

def create_index(client, index, shards=1):
    """Creates an index in Elasticsearch if one isn't already there."""
    client.options(ignore_status=400, request_timeout=30).indices.create(
        index=index,
        settings={"number_of_shards": shards},
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
        },
        wait_for_active_shards=shards,
    )

def bulkload(index, doclist):
    for doc in doclist:
        yield {
            "_op_type": "index",
            "_index": index,
            "_id": doc["uuid"],
            "_source": doc,
        }

@click.command()
@click.option("--index", prompt=True, type=str, default="myindex")
@click.option("--es_url", prompt=True, type=str, default="http://127.0.0.1:9200")
@click.option("--username", prompt=True, hide_input=False, default="elastic")
@click.option("--password", prompt=True, hide_input=True, confirmation_prompt=True)
@click.option("--exclude_partial", is_flag=True, help="Exclude indices starting with 'partial-'")
@click.argument("filename", nargs=1, type=click.Path(exists=True))
def ingest_cat_doc(index, es_url, username, password, exclude_partial, filename):
    """
    Read _cat API JSON output stored in filename, ship to es_url using provided credentials
    and insert into the named index
    """

    try:
        client = Elasticsearch(hosts=es_url, basic_auth=(username, password))
    except Exception as exc:
        click.echo("Failed to connect to Elasticsearch: {0}".format(exc))
    
    all_documents = json.load(open(filename,))
    documents = []
    for doc in all_documents:
        if exclude_partial:
            if doc["index"].startswith('partial-'):
                continue
        doc["docs_count"] = doc.pop("docs.count")
        doc["store_size"] = doc.pop("store.size")
        doc["pri_store_size"] = doc.pop("pri.store.size")
        doc["@timestamp"] = doc.pop("creation.date.string")
        documents.append(doc)
            

    click.echo("Creating index '{0}'".format(index))
    create_index(client, index)

    progress = tqdm.tqdm(unit="docs", total=len(documents))
    successes = 0

    for ok, action in streaming_bulk(
        client=client, index=index, actions=bulkload(index, documents),
    ):
        progress.update(1)
        successes += ok
    click.echo("Indexed {0}/{1} documents".format(successes, len(documents)))

if __name__ == '__main__':
    ingest_cat_doc()
