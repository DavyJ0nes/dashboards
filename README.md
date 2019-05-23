# Dashboards

<!-- vim-markdown-toc Redcarpet -->

- [Dashboards](#dashboards)
  - [Overview](#overview)
    - [Dashboard List](#dashboard-list)
  - [Usage](#usage)
  - [License](#license)

<!-- vim-markdown-toc -->

## Overview

Selection of useful grafana dashboards written with jsonnet

Uses the [Grafonnnet](https://github.com/grafana/grafonnet-lib) library

### Dashboard List

- Cloudwatch
  - [RDS](./cloudwatch/rds.jsonnet)
  - [SQS](./cloudwatch/sqs.jsonnet)

## Usage

```shell
# Compile single dashboard

jsonnet -J lib cloudwatch/rds.jsonnet >> rds.json
```

## License

MIT
