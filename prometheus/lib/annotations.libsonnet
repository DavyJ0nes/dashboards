local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local annotation = grafana.annotation;

local newAnnotation(name, expr, color, textFormat='Pod: {{ pod }}') = {
  "datasource": "$PROMETHEUS_DS",
  "enable": true,
  "expr": expr,
  "hide": false,
  "iconColor": color,
  "name": name,
  "showIn": 0,
  "tags": [],
  "textFormat": textFormat,
  "titleFormat": name,
  "type": "tags",
  "useValueForTime": true
};

{
    PodStart: newAnnotation(
        'Pod Started',
        'kube_pod_start_time{pod=~"^($pod)$"} * 1000',
        'rgba(99, 221, 126, 1)'
    ),
    PodStop: newAnnotation(
        'Pod Stopped',
        'kube_pod_completion_time{pod=~"^($pod)$"} * 1000',
        'rgba(223, 92, 132, 1)',
    ),
    
    DeploymentCreated: newAnnotation(
        'Deployment Created',
        'kube_deployment_created{deployment=~"$service.*"} * 1000',
        'rgba(179, 225, 189, 1)',
        textFormat='Deployment: {{ deployment }}'
    ),
}