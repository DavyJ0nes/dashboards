local grafana = import '../../lib/grafonnet/grafana.libsonnet';

local link = grafana.link;

{
    RelatedDashboards: link.dashboards(
        "Related Dashboards",
        ["prometheus", "kubernetes"],
        includeVars=true,
        keepTime=true,
    ),
}