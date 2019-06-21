local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local singlestat = grafana.singlestat;

{
    Graph(name, targets, fmt='bytes', span=6):: graph.new(
        name,
        datasource='$PROMETHEUS_DS',
        format=fmt,
        span=span,
        legend_values=true,
        legend_min=true,
        legend_max=true,
        legend_current=true,
        legend_total=false,
        legend_avg=true,
        legend_alignAsTable=true,
    ).addTargets(targets),

    SingleStat(name, target, fmt='short', valueName='current', span=2):: singlestat.new(
        name,
        datasource='$PROMETHEUS_DS',
        format=fmt,
        valueName=valueName,
        span=span,
    ).addTarget(target),
}