# Dashboards

<!-- vim-markdown-toc Redcarpet -->

- [Dashboards](#Dashboards)
  - [Overview](#Overview)
    - [Dashboard List](#Dashboard-List)
  - [Usage](#Usage)
  - [License](#License)

<!-- vim-markdown-toc -->

## Overview

Selection of useful grafana dashboards written with jsonnet

Uses the [Grafonnet](https://github.com/grafana/grafonnet-lib) library

### Dashboard List

- Cloudwatch
  - [RDS](./cloudwatch/rds.jsonnet)
  - [SQS](./cloudwatch/sqs.jsonnet)

- Prometheus
  - [Go Service Running on Kubernetes](./prometheus/go_service.jsonnet)

## Usage

```shell
# Compile single dashboard

jsonnet -J lib cloudwatch/rds.jsonnet >> rds.json
```

## License

MIT
