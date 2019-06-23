local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local singlestat = grafana.singlestat;

{
    Graph(name, targets, fill=1, fmt='bytes', min=null, max=null, span=6):: graph.new(
        name,
        datasource='$PROMETHEUS_DS',
        fill=fill,
        format=fmt,
        min=min,
        max=min,
        span=span,
        legend_values=true,
        legend_min=true,
        legend_max=true,
        legend_current=true,
        legend_total=false,
        legend_avg=true,
        legend_alignAsTable=true,
        sort='descreasing',
    ).addTargets(targets),

    SingleStat(name, target, fmt='short', valueName='current', span=2):: singlestat.new(
        name,
        datasource='$PROMETHEUS_DS',
        format=fmt,
        valueName=valueName,
        span=span,
    ).addTarget(target),
}