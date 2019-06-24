local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local piechart = grafana.pieChartPanel;
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

    PieChart(name, target, span=2):: {
        "datasource": "$PROMETHEUS_DS",
        "pieType": "pie",
        "targets": [
          {
            "expr": target.expr,
            "format": "time_series",
            "instant": true,
            "intervalFactor": 2,
            "legendFormat": target.legendFormat,
          }
        ],
        "title": name,
        "type": "grafana-piechart-panel",
        "legend": {
          "show": true,
          "values": true
        },
        "nullPointMode": "connected",
        "legendType": "Right side",
        "breakPoint": "30%",
        "format": "short",
        "valueName": "current",
        "strokeWidth": "1",
        "fontSize": "80%",
        "span": span,
        "combine": {
          "threshold": 0,
          "label": "Others"
        }
    },
}