local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local template = grafana.template;

{
    Datasource: grafana.template.datasource(
        'PROMETHEUS_DS',
        'prometheus',
        'Pfh-metrics',
        hide='label',
    ),

    Service: template.new(
        'service',
        '$PROMETHEUS_DS',
        'label_values(go_info, service)',
        'Service',
        refresh='load'
    ),

    Deployment: template.new(
        'deployment',
        '$PROMETHEUS_DS',
        'label_values(kube_deployment_status_replicas, deployment)',
        'Deployment',
        refresh='load'
    ),

    Pod: template.new(
        'pod',
        '$PROMETHEUS_DS',
        'label_values(go_info{service="$service"}, pod)',
        'Pod',
        includeAll=true,
        multi=true,
        refresh='load'
    ),

    Interval: {
        "auto": false,
        "auto_count": 30,
        "auto_min": "10s",
        "current": {
          "text": "5m",
          "value": "5m"
        },
        "datasource": null,
        "hide": 0,
        "includeAll": false,
        "label": "",
        "multi": false,
        "name": "interval",
        "options": [
          {
            "selected": false,
            "text": "1m",
            "value": "1m"
          },
          {
            "selected": true,
            "text": "5m",
            "value": "5m"
          },
          {
            "selected": false,
            "text": "10m",
            "value": "10m"
          },
          {
            "selected": false,
            "text": "30m",
            "value": "30m"
          },
          {
            "selected": false,
            "text": "1h",
            "value": "1h"
          }
        ],
        "query": "1m,5m,10m,30m,1h",
        "refresh": 2,
        "skipUrlSync": false,
        "type": "interval"
      },

}