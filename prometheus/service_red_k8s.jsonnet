local grafana = import '../lib/grafonnet/grafana.libsonnet';
local vars = import './lib/variables.libsonnet';
local funcs = import './lib/functions.libsonnet';
local annotations = import './lib/annotations.libsonnet';
local links = import './lib/links.libsonnet';

local dashboard = grafana.dashboard;
local prometheus = grafana.prometheus;
local row = grafana.row;

local metrics = {
    SingleStat: {
        Up: funcs.SingleStat(
           'Replicas Up',
           prometheus.target(
               expr='sum by (service) (up{job="auth"})',
               instant=true,
           ),
           fmt='short',
           span=4,
           thresholds='2,1,0',
        ),

        GoVersion: funcs.SingleStat(
           'Go Version',
           prometheus.target(
               expr='topk(1, go_info{service="$selector"})',
               legendFormat='{{ version }}',
               instant=true,
           ),
           valueName='name',
           fmt='none',
           span=4,
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
           span=4,
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
           span=4,
        ),

        RequestRate: funcs.SingleStat(
           'Request Rate Per Second (last 30min)',
            prometheus.target(
                expr='sum without(pod, route, status_code, method, instance, endpoint) (rate(http_requests_total{job="$selector"}[30m]))',
                instant=true,
            ),
            fmt='short',
           span=4,
        ),

        ErrorRate: funcs.SingleStatPercentage(
           'Error Rate (last 30min)',
            prometheus.target(
                expr='sum(rate(http_requests_total{job="$selector", status_code=~"5.."}[30m])) / sum(rate(http_requests_total{job="$selector"}[30m]))',
                instant=true,
            ),
            fmt='percentunit',
           span=4,
        ),

        FourOhOneRate: funcs.SingleStatPercentage(
           '401 Rate (last 30min)',
            prometheus.target(
                expr='sum(rate(http_requests_total{job="$selector", status_code="401"}[30m])) / sum(rate(http_requests_total{job="$selector"}[30m]))',
                instant=true,
            ),
            fmt='percentunit',
           span=4,
        ),

        FourOhThreeRate: funcs.SingleStatPercentage(
           '403 Rate (last 30min)',
            prometheus.target(
                expr='sum(rate(http_requests_total{job="$selector", status_code="403"}[30m])) / sum(rate(http_requests_total{job="$selector"}[30m]))',
                instant=true,
            ),
            fmt='percentunit',
           span=4,
        ),

        MedianLatency: funcs.SingleStat(
           'Median Latency (last 30min)',
            prometheus.target(
                expr='histogram_quantile(0.5, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[30m])) by (le))',
                instant=true,
            ),
            fmt='s',
           span=4,
        ),

        NineNineLatency: funcs.SingleStat(
           '99th %ile Latency (last 30min)',
            prometheus.target(
                expr='histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[30m])) by (le))',
                instant=true,
            ),
            fmt='s',
           span=4,
        ),
    },

    Graph: {
        QueryPerSecond: funcs.Graph(
            'Request Rate Per Second',
            [

                prometheus.target(
                    expr='sum by (status) (label_replace(label_replace(rate(http_requests_total{job="$selector"}[$interval]), "status", "${1}xx", "status_code", "([0-9]).."), "status", "${1}", "status_code", "([a-z]+)"))',
                    legendFormat='{{ status }}'
                ),
            ],
            fmt='rps',
            span=4,
        ),

        QueryPerSecondPath: funcs.Graph(
            'Request Rate Per Second',
            [

                prometheus.target(
                    expr='sum by (status_code, route) (rate(http_requests_total{job="$selector"}[$interval]))',
                    legendFormat='{{ status_code }} - {{ route }}'
                ),
            ],
            fmt='rps',
            span=6,
        ),

        Latency: funcs.Graph(
            'Latency',
            [
                prometheus.target(
                    expr='histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le)) * 1000',
                    legendFormat='50th Percentile'
                ),
                prometheus.target(
                    expr='histogram_quantile(0.90, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le)) * 1000',
                    legendFormat='90th Percentile'
                ),
                prometheus.target(
                    expr='histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le)) * 1000',
                    legendFormat='99th Percentile'
                ),
            ],
            fmt='ms',
            span=4,
        ),

        LatencyPath: funcs.Graph(
            'Latency',
            [
                prometheus.target(
                    expr='histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le, route)) * 1000',
                    legendFormat='50 - {{ route }}'
                ),
                prometheus.target(
                    expr='histogram_quantile(0.90, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le, route)) * 1000',
                    legendFormat='90 - {{ route }}'
                ),
                prometheus.target(
                    expr='histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service="$selector"}[$interval])) by (le, route)) * 1000',
                    legendFormat='99 - {{ route }}'
                ),
            ],
            fmt='ms',
            span=6,
        ),

        ErrorRatePerSecond: funcs.Graph(
            'Error Rate Per Second',
            [

                prometheus.target(
                    expr='sum(rate(http_requests_total{job="$selector", status_code=~"5.."}[$interval]))',
                    legendFormat='Errors'
                ),
            ],
            fmt='short',
            span=4,
        ),

        ErrorRatePerSecondPath: funcs.Graph(
            'Error Rate Per Second',
            [

                prometheus.target(
                    expr='sum by (route) (rate(http_requests_total{job="$selector", status_code=~"5.."}[$interval]))',
                    legendFormat='Errors - {{ route }}'
                ),
            ],
            fmt='short',
            span=6,
        ),
    },
};

// ***** Rows ***** //

local versionRow = row.new(
    title='Version Info',
    height='60px'
)
.addPanels(
    [
        metrics.SingleStat.Up,
        metrics.SingleStat.AppVersion,
        metrics.SingleStat.ChartVersion,
    ],
);

local infoRow = row.new(
    title='Info',
    height='60px'
)
.addPanels(
    [
        metrics.SingleStat.RequestRate,
        metrics.SingleStat.ErrorRate,
        metrics.SingleStat.FourOhOneRate,
        metrics.SingleStat.FourOhThreeRate,
        metrics.SingleStat.MedianLatency,
        metrics.SingleStat.NineNineLatency,
    ],
);

local redRow = row.new(
    title='Overall',
    height='300px',
    collapse=true,
)
.addPanels(
    [
        metrics.Graph.QueryPerSecond,
        metrics.Graph.Latency,
        metrics.Graph.ErrorRatePerSecond,
    ],
);

local redRowByPath = row.new(
    title='By Path',
    height='400px',
    collapse=true,
)
.addPanels(
    [
        metrics.Graph.QueryPerSecondPath,
        metrics.Graph.LatencyPath,
        metrics.Graph.ErrorRatePerSecondPath,
    ],
);

// ***** Dashboard ***** //

dashboard.new(
  'Service RED Metrics',
  refresh='30s',
  time_from='now-30m',
  tags=['prometheus', 'kubernetes', 'RED']
)
.addTemplate(vars.Datasource)
.addTemplate(vars.Go_Service)
.addTemplate(vars.Interval)
.addAnnotation(annotations.PodStarted)
.addLink(links.RelatedDashboards)
.addRows(
    [
        versionRow,
        infoRow,
        redRow,
        redRowByPath,
    ]
)