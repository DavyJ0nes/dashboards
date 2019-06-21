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
        metrics.GoVersion,
        metrics.AppVersion,
        metrics.ChartVersion,
        metrics.DesriredReplicas,
        metrics.AvailableReplicas,
        metrics.UnavailableReplicas,
    ],
);

local memoryRow = row.new(
    title='Memory'
).addPanels(
    [
        metrics.ProcessMemory,
        metrics.MemoryFrees,
        metrics.MemStats,
        metrics.MemStatsDeriv,
    ],
);

local fileDescriptorsRow = row.new(
    title='File Descriptors'
).addPanels(
    [
        metrics.OpenFDS,
        metrics.OpenFDSDeriv,
    ],
);

local goRoutineRow = row.new(
    title='Goroutines and Threads'
).addPanels(
    [
        metrics.GoRoutineCount,
        metrics.GoThreadCount,
    ],
);

local gcRow = row.new(
    title='Garbage Collection'
).addPanels(
    [
        metrics.GCDuration,
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
.addTemplate(vars.Service)
.addTemplate(vars.Pod)
.addTemplate(vars.Interval)
.addAnnotation(annotations.PodStart)
.addAnnotation(annotations.PodStop)
.addAnnotation(annotations.DeploymentCreated)
.addRows(
    [
        infoRow,
        memoryRow,
        fileDescriptorsRow,
        goRoutineRow,
    ]
)