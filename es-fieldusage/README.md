# es-fieldusage

[![PyPI - Version](https://img.shields.io/pypi/v/es-fieldusage.svg)](https://pypi.org/project/es-fieldusage)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/es-fieldusage.svg)](https://pypi.org/project/es-fieldusage)

-----

**Table of Contents**

- [Installation](#installation)
- [Description](#description)
- [License](#license)

## Installation

```console
pip install es-fieldusage
```

## Description

Determine which fields are being used, how much, for a given index.

### Top-level help output
```
$ es-fieldusage --help

Usage: es-fieldusage [OPTIONS] COMMAND [ARGS]...

  Elasticsearch Index Field Usage Reporting Tool

  Sum all field query/request access for one or more indices using the Elastic Field Usage API (https://ela.st/usagestats)

  Generate a report at the command-line with the stdout command for all indices in INDEX_PATTERN:

  $ es-fieldusage stdout INDEX_PATTERN

  To avoid errors, be sure to encapsulate wildcards in single-quotes:

  $ es-fieldusage stdout 'index-*'

Options:
  --config PATH                   Path to configuration file.
  --hosts TEXT                    Elasticsearch URL to connect to.
  --cloud_id TEXT                 Elastic Cloud instance id
  --api_token TEXT                The base64 encoded API Key token
  --id TEXT                       API Key "id" value
  --api_key TEXT                  API Key "api_key" value
  --username TEXT                 Elasticsearch username
  --password TEXT                 Elasticsearch password
  --request_timeout FLOAT         Request timeout in seconds
  --verify_certs / --no-verify_certs
                                  Verify SSL/TLS certificate(s)  [default: verify_certs]
  --ca_certs TEXT                 Path to CA certificate file or directory
  --client_cert TEXT              Path to client certificate file
  --client_key TEXT               Path to client key file
  --loglevel [DEBUG|INFO|WARNING|ERROR|CRITICAL]
                                  Log level
  --logfile TEXT                  Log file
  --logformat [default|ecs]       Log output format
  -v, --version                   Show the version and exit.
  -h, --help                      Show this message and exit.

Commands:
  show-all-options  Show all configuration options
  stdout            Output field usage information to the console

  Learn more at https://github.com/untergeek/elastic-grab-bag/es_fieldusage
```

### Command `stdout` help output

```
$ es-fieldusage stdout --help
Usage: es-fieldusage stdout [OPTIONS] SEARCH_PATTERN

  Display field usage information on the console for SEARCH_PATTERN

  $ es-fieldusage stdout [OPTIONS] SEARCH_PATTERN

Options:
  --show-report / --hide-report   Show a summary report  [default: show-report]
  --show-headers / --hide-headers
                                  Show block headers for un|accessed fields  [default: show-headers]
  --show-accessed / --hide-accessed
                                  Show accessed fields  [default: hide-accessed]
  --show-unaccessed / --hide-unaccessed
                                  Show unaccessed fields  [default: hide-unaccessed]
  --show-counts / --hide-counts   Show field access counts  [default: hide-counts]
  --delimiter TEXT                Value delimiter if access counts are shown  [default: :]
  -h, --help                      Show this message and exit.

  Learn more at https://github.com/untergeek/elastic-grab-bag/es_fieldusage
  ```

### Command `file` help output

```
$ es-fieldusage file --help
Usage: es-fieldusage file [OPTIONS] SEARCH_PATTERN

  Write field usage information to file for SEARCH_PATTERN

  $ es-fieldusage file [OPTIONS] SEARCH_PATTERN

Options:
  --show-report / --hide-report   Show a summary report  [default: show-report]
  --show-headers / --hide-headers
                                  Show block headers for un|accessed fields  [default: show-headers]
  --show-accessed / --hide-accessed
                                  Show accessed fields  [default: hide-accessed]
  --show-unaccessed / --hide-unaccessed
                                  Show unaccessed fields  [default: hide-unaccessed]
  --show-counts / --hide-counts   Show field access counts  [default: hide-counts]
  --per_index                     Create one file per index found
  --delimiter TEXT                Value delimiter if access counts are shown  [default: ,]
  -h, --help                      Show this message and exit.

  Learn more at https://github.com/untergeek/elastic-grab-bag/es_fieldusage
```

## License

`es-fieldusage` is distributed under the terms of the [Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0) license.
