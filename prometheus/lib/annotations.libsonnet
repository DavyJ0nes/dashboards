local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local annotation = grafana.annotation;

local newAnnotation(name, expr, color, tags, textFormat='Pod: {{ pod }}') = {
  "datasource": "$PROMETHEUS_DS",
  "enable": true,
  "expr": expr,
  "hide": false,
  "iconColor": color,
  "name": name,
  "showIn": 0,
  "tags": tags,
  "textFormat": textFormat,
  "titleFormat": name,
  "type": "tags",
  "useValueForTime": true
};

{
    PodStarted: newAnnotation(
        'Pod Started',
        'kube_pod_start_time{pod=~"$selector.*"} * on (namespace, pod) group_left(label_image_tag, label_chart) kube_pod_labels * 1000',
        'rgba(99, 221, 126, 1)',
        tags=["pod_started"],
        textFormat='image:{{ label_image_tag }}, chart:{{ label_chart }}'
    ),

    ContainerStarted: newAnnotation(
        'Container Started',
        'container_start_time_seconds{container_name!~"POD", container_name=~"$selector.*"} * 1000',
        'rgba(99, 221, 126, 1)',
        tags=["container_started"],
        textFormat='{{ container_name }}'
    ),
}