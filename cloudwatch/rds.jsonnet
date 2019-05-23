local grafana = import '../lib/grafonnet/grafana.libsonnet';
local vars = import './variables.libsonnet';
local funcs = import './functions.libsonnet';

local cloudwatch = grafana.cloudwatch;
local dashboard = grafana.dashboard;
local graph = grafana.graphPanel;
local row = grafana.row;
local singlestat = grafana.singlestat;
local template = grafana.template;

// ***** Rows ***** //

local topRow = row.new(
  height='100px'
).addPanels(
  [
    funcs.RDSSingleStat('Current Replica Lag', 's', funcs.RDSTarget('ReplicaLag')),
    funcs.RDSSingleStat('Current Avg CPU', 'percent', funcs.RDSTarget('CPUUtilization')),
    funcs.RDSSingleStat('Current Write Latency', 's', funcs.RDSTarget('WriteLatency')),
    funcs.RDSSingleStat('Current Read Latency', 's', funcs.RDSTarget('ReadLatency')),
    funcs.RDSSingleStat('Current Write Throughput', 'Bps', funcs.RDSTarget('WriteThroughput')),
    funcs.RDSSingleStat('Current Read Throughput', 'Bps', funcs.RDSTarget('ReadThroughput')),
  ]
);

local graphRow = row.new(
).addPanels(
  [
    funcs.RDSSimpleGraph('Replica Lag', [funcs.RDSTarget('ReplicaLag')]),
    funcs.RDSSimpleGraph('Queue Depth', [funcs.RDSTarget('DiskQueueDepth')]),
    funcs.RDSSimpleGraph('Read Latency', [funcs.RDSTarget('ReadLatency')]),
    funcs.RDSSimpleGraph('Write Latency', [funcs.RDSTarget('WriteLatency')]),
    funcs.RDSSimpleGraph('Read Throughput', [funcs.RDSTarget('ReadThroughput')]),
    funcs.RDSSimpleGraph('Write Throughput', [funcs.RDSTarget('WriteThroughput')]),
    funcs.RDSSimpleGraph(
      'Avg CPU',
      [
        funcs.RDSTarget('CPUUtilization'),
        funcs.RDSTarget('CPUUtilization', 'Maximum'),
        funcs.RDSTarget('CPUUtilization', 'Minimum'),
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
.addTemplate(vars.EnvVar)
.addTemplate(vars.RegionVar)
.addTemplate(vars.DbNameVar)
.addRows(
  [
    topRow,
    graphRow,
  ]
)
