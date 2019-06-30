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
    },
};

// ***** Rows ***** //

local infoRow = row.new(
    title='Info',
    height='60px'
)
.addPanels(
    [
        metrics.SingleStat.GoVersion,
        metrics.SingleStat.AppVersion,
        metrics.SingleStat.ChartVersion,
        metrics.PieChart.DesriredReplicas,
        metrics.PieChart.AvailableReplicas,
        metrics.PieChart.UnavailableReplicas,
    ],
);

local memoryRow = row.new(
    title='Memory Stats and File Descriptors'
)
.addPanels(
    [
        metrics.Graph.ProcessMemory,
        metrics.Graph.MemoryFrees,
        metrics.Graph.MemStats,
        metrics.Graph.OpenFDS,
    ],
);

local goRoutineRow = row.new(
    title='Goroutines and GC'
)
.addPanels(
    [
        metrics.Graph.GoRoutineCount,
        metrics.Graph.GCDuration,
    ],
);

// ***** Dashboard ***** //

dashboard.new(
  'Go Process',
  refresh='30s',
  time_from='now-30m',
  tags=['prometheus', 'kubernetes', 'go']
)
.addTemplate(vars.Datasource)
.addTemplate(vars.Go_Service)
.addTemplate(vars.Go_Pod)
.addTemplate(vars.Interval)
.addAnnotation(annotations.PodStarted)
.addLink(links.RelatedDashboards)
.addRows(
    [
        infoRow,
        memoryRow,
        goRoutineRow,
    ]
)