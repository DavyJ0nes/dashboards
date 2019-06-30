local grafana = import '../lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local prometheus = grafana.prometheus;
local row = grafana.row;

local annotations = import './lib/annotations.libsonnet';
local funcs = import './lib/functions.libsonnet';
local links = import './lib/links.libsonnet';
local vars = import './lib/variables.libsonnet';

// ***** Metrics ***** //

local metrics = {
    SingleStat: {
        AppVersion: funcs.SingleStat(
           'App Version',
           prometheus.target(
               expr='topk(1, kube_deployment_labels{label_release="$selector"})',
               legendFormat='{{ label_image_tag }}',
               instant=true,
           ),
           valueName='name',
           fmt='none',
        ),

        ChartVersion: funcs.SingleStat(
           'Chart Version',
           prometheus.target(
               expr='topk(1, kube_deployment_labels{label_release="$selector"})',
               legendFormat='{{ label_chart }}',
               instant=true,
           ),
           valueName='name',
           fmt='none',
        ),
    },

    PieChart: {
        DesriredReplicas: funcs.PieChart(
           'Desired Replicas',
            prometheus.target(
               expr='kube_deployment_status_replicas{deployment=~"$selector.*"}',
               legendFormat='{{ deployment }}',
            )
        ),

        AvailableReplicas: funcs.PieChart(
           'Available Replicas',
            prometheus.target(
               expr='kube_deployment_status_replicas_available{deployment=~"$selector.*"}',
               legendFormat='{{ deployment }}',
            )
        ),

        UnavailableReplicas: funcs.PieChart(
           'Unavailable Replicas',
            prometheus.target(
               expr='kube_deployment_status_replicas_unavailable{deployment=~"$selector.*"}',
               legendFormat='{{ deployment }}',
            )
        ),
    },

    Graph: {
        CPUUtilisation: funcs.Graph(
            'Container CPU Utilisation',
            [
                prometheus.target(
                    expr='avg(irate(container_cpu_usage_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval])) by (container_name)',
                    legendFormat='{{ container_name }} - total time'
                ),
                prometheus.target(
                    expr='avg(irate(container_cpu_user_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval])) by (container_name)',
                    legendFormat='{{ container_name }} - user time'
                ),
                prometheus.target(
                    expr='avg(irate(container_cpu_system_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval])) by (container_name)',
                    legendFormat='{{ container_name }} - system time'
                ),
            ],
            fmt='s',
        ),

        ThrottledCPU: funcs.Graph(
            'Container CPU Throttled Time',
            [
                prometheus.target(
                    expr='avg(rate(container_cpu_cfs_throttled_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval])) by (container_name)',
                    legendFormat='{{ container_name }}'
                ),
                prometheus.target(
                    expr='max_over_time((rate(container_cpu_cfs_throttled_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval]))[1h:])',
                    legendFormat='{{ container_name }} - max (1h)'
                ),
                prometheus.target(
                    expr='avg_over_time((rate(container_cpu_cfs_throttled_seconds_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[$interval]))[1h:])',
                    legendFormat='{{ container_name }} - avg (1h)'
                ),
            ],
            fmt='s',
        ),

        MemoryUtilisation: funcs.Graph(
            'Container Memory Utilisation',
            [
                prometheus.target(
                    expr='max_over_time(container_memory_working_set_bytes{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[1h])',
                    legendFormat='{{ container_name }} - max (1h)'
                ),
                prometheus.target(
                    expr='avg_over_time(container_memory_working_set_bytes{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}[1h])',
                    legendFormat='{{ container_name }} - avg (1h)'
                ),
                prometheus.target(
                    expr='container_memory_working_set_bytes{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}',
                    legendFormat='{{ container_name }} - current'
                ),
            ],
            span=4,
            fill=0,
        ),

        MemorySaturation: funcs.Graph(
            'Container Memory Saturation',
            [
                prometheus.target(
                    expr='sum(container_memory_working_set_bytes{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name=~".+", container_name!~"POD"}) by (container_name) / sum(label_join(kube_pod_container_resource_limits_memory_bytes, "container_name", "", "container")) by (container_name)',
                    legendFormat='{{ container_name }}'
                ),
            ],
            fmt='percentunit',
            span=4,
            min=0,
            max=1,
        ),

        MemoryErrors: funcs.Graph(
            'Container Memory Errors',
            [
                prometheus.target(
                    expr='rate(container_memory_failures_total{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name!~"POD", container_name=~".+", scope="container"}[$interval])',
                    legendFormat='{{ container_name }} - total failures ({{ type }})'
                ),
                prometheus.target(
                    expr='rate(container_memory_failcnt{pod_name=~"$selector.*", pod_name=~"^($pod)$", container_name!~"POD", container_name=~".+"}[$interval])',
                    legendFormat='{{ container_name }} - memory usage limit reached'
                ),
            ],
            fmt='short',
            span=4,
        ),

        NetUtilisation: funcs.Graph(
            'Container Network Utilisation',
            [
                prometheus.target(
                    expr='sum(irate(container_network_receive_bytes_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - receive'
                ),
                prometheus.target(
                    expr='sum(irate(container_network_transmit_bytes_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - transmit'
                ),
            ],
            span=4,
        ),

        NetPacketDrops: funcs.Graph(
            'Container Network Packet Drops',
            [
                prometheus.target(
                    expr='sum(irate(container_network_receive_packets_dropped_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - receive'
                ),
                prometheus.target(
                    expr='sum(irate(container_network_transmit_packets_dropped_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - transmit'
                ),
            ],
            fmt='short',
            span=4,
        ),

        NetErrors: funcs.Graph(
            'Container Network Errors',
            [
                prometheus.target(
                    expr='sum(irate(container_network_receive_errors_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - receive'
                ),
                prometheus.target(
                    expr='sum(irate(container_network_transmit_errors_total{pod_name=~"$selector.*", pod_name=~"^($pod)$"}[$interval])) by (pod_name)',
                    legendFormat='{{ pod_name }} - transmit'
                ),
            ],
            fmt='short',
            span=4,
        ),
    }
};

// ***** Rows ***** //

local infoRow = row.new(
    title='Info',
    height='60px'
)
.addPanels(
    [
        metrics.SingleStat.AppVersion,
        metrics.SingleStat.ChartVersion,
        metrics.PieChart.DesriredReplicas,
        metrics.PieChart.AvailableReplicas,
        metrics.PieChart.UnavailableReplicas,
    ],
);

local cpuRow = row.new(
    title='CPU',
    height='300px'
)
.addPanels(
    [
        metrics.Graph.CPUUtilisation,
        metrics.Graph.ThrottledCPU,
    ],
);

local memoryRow = row.new(
    title='Memory',
    height='300px'
)
.addPanels(
    [
        metrics.Graph.MemoryUtilisation,
        metrics.Graph.MemorySaturation,
        metrics.Graph.MemoryErrors,
    ],
);

local networkRow = row.new(
    title='Network',
    height='300px'
)
.addPanels(
    [
        metrics.Graph.NetUtilisation,
        metrics.Graph.NetPacketDrops,
        metrics.Graph.NetErrors,
    ],
);

// ***** Dashboard ***** //

dashboard.new(
  'K8s Container USE',
  refresh='30s',
  time_from='now-30m',
  tags=['prometheus', 'kubernetes', 'cadvisor', 'use']
)
.addTemplate(vars.Datasource)
.addTemplate(vars.Release_Name)
.addTemplate(vars.K8s_Pod)
.addTemplate(vars.Interval)
.addAnnotation(annotations.ContainerStarted)
.addLink(links.RelatedDashboards)
.addRows(
    [
        infoRow,
        cpuRow,
        memoryRow,
        networkRow,
    ]
)