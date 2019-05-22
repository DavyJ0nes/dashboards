local grafana = import '../lib/grafonnet/grafana.libsonnet';

local cloudwatch = grafana.cloudwatch;
local dashboard = grafana.dashboard;
local graph = grafana.graphPanel;
local row = grafana.row;
local singlestat = grafana.singlestat;
local template = grafana.template;

// ***** Variables ***** //

local regionVar = template.new(
  'region',
  'CloudWatch Prod',
  'regions()',
  'Region',
  current='eu-west-1',
  refresh='load'
);

local dbNameVar = template.new(
  'dbName',
  'CloudWatch Prod',
  'dimension_values($region,AWS/RDS,CPUUtilization,DBInstanceIdentifier)',
  'DB Name',
  refresh='load'
);

// ***** Functions ***** //

local RDSTarget(metric, stat='Average') = cloudwatch.target(
  '$region',
  'AWS/RDS',
  metric,
  statistic=stat,
  alias='{{ stat }} {{ metric }}',
  dimensions={ DBInstanceIdentifier: '$dbName' }
);

local SingleStat(name, fmt, target) = singlestat.new(
  name,
  format=fmt,
  span=2,
  valueName='current',
  sparklineShow=true
).addTarget(target);

local SimpleGraph(name, targets) = graph.new(
  name,
  span=6,
).addTargets(targets);

// ***** Rows ***** //

local topRow = row.new(
  height='100px'
).addPanels(
  [
    SingleStat('Current Replica Lag', 's', RDSTarget('ReplicaLag')),
    SingleStat('Current Avg CPU', 'percent', RDSTarget('CPUUtilization')),
    SingleStat('Current Write Latency', 's', RDSTarget('WriteLatency')),
    SingleStat('Current Read Latency', 's', RDSTarget('ReadLatency')),
    SingleStat('Current Write Throughput', 'Bps', RDSTarget('WriteThroughput')),
    SingleStat('Current Read Throughput', 'Bps', RDSTarget('ReadThroughput')),
  ]
);

local graphRow = row.new(
).addPanels(
  [
    SimpleGraph('Replica Lag', [RDSTarget('ReplicaLag')]),
    SimpleGraph('Queue Depth', [RDSTarget('DiskQueueDepth')]),
    SimpleGraph('Read Latency', [RDSTarget('ReadLatency')]),
    SimpleGraph('Write Latency', [RDSTarget('WriteLatency')]),
    SimpleGraph('Read Throughput', [RDSTarget('ReadThroughput')]),
    SimpleGraph('Write Throughput', [RDSTarget('WriteThroughput')]),
    SimpleGraph(
      'Avg CPU',
      [
        RDSTarget('CPUUtilization'),
        RDSTarget('CPUUtilization', 'Maximum'),
        RDSTarget('CPUUtilization', 'Minimum'),
      ]
    ),
  ]
);

// ***** Dashboard ***** //

dashboard.new(
  'RDS',
  refresh='30s',
  time_from='now-30m',
  tags=['cloudwatch', 'databases']
)
.addTemplate(regionVar)
.addTemplate(dbNameVar)
.addRows(
  [
    topRow,
    graphRow,
  ]
)
