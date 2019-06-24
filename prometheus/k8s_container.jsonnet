local grafana = import '../lib/grafonnet/grafana.libsonnet';
local vars = import './lib/variables.libsonnet';
local annotations = import './lib/annotations.libsonnet';
local metrics = import './lib/metrics.libsonnet';
local links = import './lib/links.libsonnet';

local dashboard = grafana.dashboard;
local row = grafana.row;

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
        metrics.Graph.ContainerCPUUtilisation,
        metrics.Graph.ContainerThrottledCPU,
    ],
);

local memoryRow = row.new(
    title='Memory',
    height='300px'
)
.addPanels(
    [
        metrics.Graph.ContainerMemoryUtilisation,
        metrics.Graph.ContainerMemorySaturation,
        metrics.Graph.ContainerMemoryErrors,
    ],
);

local networkRow = row.new(
    title='Network',
    height='300px'
)
.addPanels(
    [
        metrics.Graph.ContainerNetUtilisation,
        metrics.Graph.ContainerNetPacketDrops,
        metrics.Graph.ContainerNetErrors,
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