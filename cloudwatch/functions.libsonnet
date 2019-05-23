local grafana = import '../lib/grafonnet/grafana.libsonnet';

local cloudwatch = grafana.cloudwatch;
local graph = grafana.graphPanel;
local singlestat = grafana.singlestat;

{
    RDSTarget(metric, stat='Average'):: cloudwatch.target(
      '$region',
      'AWS/RDS',
      metric,
      datasource='$env',
      statistic=stat,
      alias='{{ stat }} {{ metric }}',
      dimensions={ DBInstanceIdentifier: '$dbName' }
    ),

    SQSTarget(metric, stat='Average'):: cloudwatch.target(
      '$region',
      'AWS/SQS',
      metric,
      datasource='$env',
      statistic=stat,
      alias='{{ stat }} {{ metric }}',
      dimensions={ QueueName: '$queueName' }
    ),

    RDSSingleStat(name, fmt, target):: singlestat.new(
      name,
      datasource='$env',
      format=fmt,
      span=2,
      valueName='current',
      sparklineShow=true
    ).addTarget(target),

    RDSSimpleGraph(name, targets):: graph.new(
      name,
      datasource='$env',
      span=6,
    ).addTargets(targets),

    SQSSingleStat(name, target, fmt='short', span=3):: singlestat.new(
      name,
      datasource='$env',
      format=fmt,
      span=span,
      valueName='current',
      sparklineShow=true
    ).addTarget(target),

    SQSSimpleGraph(name, targets, fmt='short', span=6):: graph.new(
      name,
      datasource='$env',
      format=fmt,
      span=span,
      nullPointMode='connected',
    ).addTargets(targets)
}