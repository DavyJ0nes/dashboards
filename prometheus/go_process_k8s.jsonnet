local grafana = import '../lib/grafonnet/grafana.libsonnet';
local vars = import './lib/variables.libsonnet';
local annotations = import './lib/annotations.libsonnet';
local metrics = import './lib/metrics.libsonnet';

local dashboard = grafana.dashboard;
local row = grafana.row;

// ***** Rows ***** //

local infoRow = row.new(
    title='Info',
    height='50px'
)
.addPanels(
    [
        metrics.SingleStat.GoVersion,
        metrics.SingleStat.AppVersion,
        metrics.SingleStat.ChartVersion,
        metrics.SingleStat.DesriredReplicas,
        metrics.SingleStat.AvailableReplicas,
        metrics.SingleStat.UnavailableReplicas,
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
  'Go Service',
  refresh='30s',
  time_from='now-30m',
  tags=['prometheus', 'go']
)
.addTemplate(vars.Datasource)
.addTemplate(vars.Go_Service)
.addTemplate(vars.Go_Pod)
.addTemplate(vars.Interval)
.addAnnotation(annotations.PodStarted)
.addRows(
    [
        infoRow,
        memoryRow,
        goRoutineRow,
    ]
)