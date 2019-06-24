local grafana = import '../../lib/grafonnet/grafana.libsonnet';
local funcs = import './functions.libsonnet';

local prometheus = grafana.prometheus;

{
    SingleStat: {
        GoVersion: funcs.SingleStat(
           'Go Version',
           prometheus.target(
               expr='topk(1, go_info{service="$selector"})',
               legendFormat='{{ version }}',
               instant=true,
           ),
           valueName='name',
           fmt='none',
        ),

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

        DesriredReplicas: funcs.SingleStat(
           'Desired Replicas',
            prometheus.target(
               expr='sum(kube_deployment_status_replicas{deployment=~"$selector.*"})',
               instant=true,
            )
        ),

        AvailableReplicas: funcs.SingleStat(
           'Available Replicas',
            prometheus.target(
                expr='sum(kube_deployment_status_replicas_available{deployment=~"$selector.*"})',
                instant=true,
            )
        ),

        UnavailableReplicas: funcs.SingleStat(
           'Unavailable Replicas',
            prometheus.target(
                expr='sum(kube_deployment_status_replicas_unavailable{deployment=~"$selector.*"})',
                instant=true,
            )
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
        ProcessMemory: funcs.Graph(
            'Process Memory',
            [
                prometheus.target(
                    expr='process_resident_memory_bytes{service="$selector",pod=~"^($pod)$"}',
                    legendFormat='{{ pod }}-resident'
                ),
                prometheus.target(
                    expr='process_virtual_memory_bytes{service="$selector",pod=~"^($pod)$"}',
                    legendFormat='{{ pod }}-virtual'
                )
            ]
        ),

        MemStats: funcs.Graph(
            'Memory Stats',
            [
                prometheus.target(
                    expr='go_memstats_alloc_bytes{service="$selector",pod=~"^($pod)$"}',
                    legendFormat='{{ pod }} bytes allocated'
                ),
                prometheus.target(
                    expr='rate(go_memstats_alloc_bytes_total{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }} alloc rate'
                ),
                prometheus.target(
                    expr='go_memstats_stack_inuse_bytes{service="$selector",pod=~"^($pod)$"}',
                    legendFormat='{{ pod }} stack inuse'
                ),
                prometheus.target(
                    expr='go_memstats_heap_inuse_bytes{service="$selector",pod=~"^($pod)$"}',
                    legendFormat='{{ pod }} heap inuse'
                ),
            ]
        ),

        MemStatsDeriv: funcs.Graph(
            'Memory Stats Derivitive',
            [
                prometheus.target(
                    expr='deriv(go_memstats_alloc_bytes{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }} bytes allocated'
                ),
                prometheus.target(
                    expr='rate(go_memstats_alloc_bytes_total{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }} alloc rate'
                ),
                prometheus.target(
                    expr='deriv(go_memstats_stack_inuse_bytes{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }} stack inuse'
                ),
                prometheus.target(
                    expr='deriv(go_memstats_heap_inuse_bytes{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }} heap inuse'
                ),
            ]
        ),

        MemoryFrees: funcs.Graph(
            'Rate of Memory Frees',
            [
                prometheus.target(
                    expr='rate(go_memstats_frees_total{service="$selector",pod=~"^($pod)$"}[$interval])',
                    legendFormat='{{ pod }}-rate-of-frees'
                ),
            ],
            fmt='short',
        ),

        OpenFDS: funcs.Graph(
            'Open File Descriptors',
            [
                prometheus.target(
                    expr='process_open_fds{service="$selector"}',
                    legendFormat='{{ pod }}'
                )
            ],
            fmt='short',
        ),

        OpenFDSDeriv: funcs.Graph(
            'Open File Descriptors Derivitive',
            [
                prometheus.target(
                    expr='deriv(process_open_fds{service="$selector"}[$interval])',
                    legendFormat='{{ pod }}'
                )
            ],
            fmt='short',
        ),

        GoRoutineCount: funcs.Graph(
            'Go Routine Count',
            [
                prometheus.target(
                    expr='go_goroutines{service="$selector"}',
                    legendFormat='{{ pod }}'
                )
            ],
            fmt='short',
        ),

        GoThreadCount: funcs.Graph(
            'Go Thread Count',
            [
                prometheus.target(
                    expr='go_threads{service="$selector"}',
                    legendFormat='{{ pod }}'
                )
            ],
            fmt='short',
        ),

        GCDuration: funcs.Graph(
            'GC Durations (s)',
            [
                prometheus.target(
                    expr='go_gc_duration_seconds{service="$selector"}',
                    legendFormat='q {{ quantile }}: {{ pod }}'
                ),
            ],
            fmt='s',
        ),

        ScrapeDuration: funcs.Graph(
            'Metric Scrape Duration (s)',
            [
                prometheus.target(
                    expr='scrape_duration_seconds{service="$selector"}',
                    legendFormat='{{ pod }}'
                ),
            ],
            fmt='s',
        ),

        QueryPerSecond: funcs.Graph(
            'QPS',
            [

                prometheus.target(
                    expr='sum by (status) (label_replace(label_replace(rate(http_requests_total[$interval]), "status", "${1}xx", "code", "([0-9]).."), "status", "${1}", "code", "([a-z]+)"))',
                    legendFormat='{{ status }}'
                ),
            ],
            fmt='short',
        ),

        Latency: funcs.Graph(
            'Latency',
            [

                prometheus.target(
                    expr='histogram_quantile(0.99, sum(rate(%s_bucket%s[$interval])) by (le)) * 1000',
                    legendFormat='99th Percentile'
                ),
            ],
            fmt='ms',
        ),

        ContainerCPUUtilisation: funcs.Graph(
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
        ContainerThrottledCPU: funcs.Graph(
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

        ContainerMemoryUtilisation: funcs.Graph(
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

        ContainerMemorySaturation: funcs.Graph(
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

        ContainerMemoryErrors: funcs.Graph(
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

        ContainerNetUtilisation: funcs.Graph(
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
        
        ContainerNetPacketDrops: funcs.Graph(
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

        ContainerNetErrors: funcs.Graph(
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
}