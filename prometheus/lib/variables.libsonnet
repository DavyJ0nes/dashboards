local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local template = grafana.template;

{
    Datasource: grafana.template.datasource(
        'PROMETHEUS_DS',
        'prometheus',
        'Pfh-metrics',
        hide='all',
    ),

    Go_Service: template.new(
        'selector',
        '$PROMETHEUS_DS',
        'label_values(go_info, service)',
        'Service',
        refresh='load'
    ),

    K8s_Service: template.new(
        'selector',
        '$PROMETHEUS_DS',
        'label_values(kube_service_labels, service)',
        'Service',
        refresh='load'
    ),

    Release_Name: template.new(
        'selector',
        '$PROMETHEUS_DS',
        'label_values(kube_deployment_labels, label_release)',
        'Release Name',
        refresh='load'
    ),

    Go_Pod: template.new(
        'pod',
        '$PROMETHEUS_DS',
        'label_values(go_info{service="$selector"}, pod)',
        'Pod',
        includeAll=true,
        multi=true,
        refresh='load'
    ),

    K8s_Pod: template.new(
        'pod',
        '$PROMETHEUS_DS',
        'label_values(kube_pod_labels{label_release="$selector"}, pod)',
        'Pod',
        allValues=".*",
        includeAll=true,
        multi=true,
        refresh='load'
    ),

    K8s_Container: template.new(
        'container',
        '$PROMETHEUS_DS',
        'label_values(kube_pod_container_info{pod="$pod"}, container_name)',
        'Container',
        allValues=".*",
        includeAll=true,
        multi=true,
        refresh='load'
    ),

    Interval: {
        "auto": false,
        "auto_count": 30,
        "auto_min": "10s",
        "current": {
          "text": "1m",
          "value": "1m"
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