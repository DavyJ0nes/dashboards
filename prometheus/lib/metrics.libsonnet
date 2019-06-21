local grafana = import '../../lib/grafonnet/grafana.libsonnet';
local funcs = import './functions.libsonnet';

local prometheus = grafana.prometheus;

{
    GoVersion: funcs.SingleStat(
       'Go Version',
       prometheus.target(
           expr='topk(1, go_info{service="$service",pod=~"^($pod)$"})',
           legendFormat='{{ version }}'
       ),
       valueName='name',
       fmt='none',
    ),
    
    AppVersion: funcs.SingleStat(
       'App Version',
       prometheus.target(
           expr='topk(1, kube_deployment_labels{label_release="$service"})',
           legendFormat='{{ label_image_tag }}'
       ),
       valueName='name',
       fmt='none',
    ),
    
    ChartVersion: funcs.SingleStat(
       'Chart Version',
       prometheus.target(
           expr='topk(1, kube_deployment_labels{label_release="$service"})',
           legendFormat='{{ label_chart }}'
       ),
       valueName='name',
       fmt='none',
    ),
    
    DesriredReplicas: funcs.SingleStat(
       'Desired Replicas',
        prometheus.target(
            expr='sum(kube_deployment_status_replicas{deployment=~"$service.*"})',
        )
    ),
    
    AvailableReplicas: funcs.SingleStat(
       'Available Replicas',
        prometheus.target(
            expr='sum(kube_deployment_status_replicas_available{deployment=~"$service.*"})',
        )
    ),
    
    UnavailableReplicas: funcs.SingleStat(
       'Unavailable Replicas',
        prometheus.target(
            expr='sum(kube_deployment_status_replicas_unavailable{deployment=~"$service.*"})',
        )
    ),
    
    ProcessMemory: funcs.Graph(
        'Process Memory',
        [
            prometheus.target(
                expr='process_resident_memory_bytes{service="$service",pod=~"^($pod)$"}',
                legendFormat='{{ pod }}-resident'
            ),
            prometheus.target(
                expr='process_virtual_memory_bytes{service="$service",pod=~"^($pod)$"}',
                legendFormat='{{ pod }}-virtual'
            )
        ]
    ),

    MemStats: funcs.Graph(
        'Memory Stats',
        [
            prometheus.target(
                expr='go_memstats_alloc_bytes{service="$service",pod=~"^($pod)$"}',
                legendFormat='{{ pod }} bytes allocated'
            ),
            prometheus.target(
                expr='rate(go_memstats_alloc_bytes_total{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }} alloc rate'
            ),
            prometheus.target(
                expr='go_memstats_stack_inuse_bytes{service="$service",pod=~"^($pod)$"}',
                legendFormat='{{ pod }} stack inuse'
            ),
            prometheus.target(
                expr='go_memstats_heap_inuse_bytes{service="$service",pod=~"^($pod)$"}',
                legendFormat='{{ pod }} heap inuse'
            ),
        ]
    ),

    MemStatsDeriv: funcs.Graph(
        'Memory Stats Derivitive',
        [
            prometheus.target(
                expr='deriv(go_memstats_alloc_bytes{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }} bytes allocated'
            ),
            prometheus.target(
                expr='rate(go_memstats_alloc_bytes_total{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }} alloc rate'
            ),
            prometheus.target(
                expr='deriv(go_memstats_stack_inuse_bytes{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }} stack inuse'
            ),
            prometheus.target(
                expr='deriv(go_memstats_heap_inuse_bytes{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }} heap inuse'
            ),
        ]
    ),

    MemoryFrees: funcs.Graph(
        'Rate of Memory Frees',
        [
            prometheus.target(
                expr='rate(go_memstats_frees_total{service="$service",pod=~"^($pod)$"}[$interval])',
                legendFormat='{{ pod }}-rate-of-frees'
            ),
        ],
        fmt='short',
    ),
    
    OpenFDS: funcs.Graph(
        'Open File Descriptors',
        [
            prometheus.target(
                expr='process_open_fds{service="$service"}',
                legendFormat='{{ pod }}'
            )
        ],
        fmt='short',
    ),
    
    OpenFDSDeriv: funcs.Graph(
        'Open File Descriptors Derivitive',
        [
            prometheus.target(
                expr='deriv(process_open_fds{service="$service"}[$interval])',
                legendFormat='{{ pod }}'
            )
        ],
        fmt='short',
    ),
    
    GoRoutineCount: funcs.Graph(
        'Go Routine Count',
        [
            prometheus.target(
                expr='go_goroutines{service="$service"}',
                legendFormat='{{ pod }}'
            )
        ],
        fmt='short',
    ),

    GoThreadCount: funcs.Graph(
        'Go Thread Count',
        [
            prometheus.target(
                expr='go_threads{service="$service"}',
                legendFormat='{{ pod }}'
            )
        ],
        fmt='short',
    ),

    GCDuration: funcs.Graph(
        'GC Durations (s)',
        [
            prometheus.target(
                expr='go_gc_duration_seconds{service="$service"}',
                legendFormat='q {{ quantile }}: {{ pod }}'
            ),
            prometheus.target(
                expr='rate(go_gc_duration_seconds_sum{pod="$pod"}[$interval])',
                legendFormat='{{ pod }} gc rate'
            ),
            prometheus.target(
                expr='go_memstats_last_gc_time_seconds{service="$service"}',
                legendFormat='{{ pod }} last gc time'
            ),
        ],
        fmt='seconds',
        span=12,
    ),
}