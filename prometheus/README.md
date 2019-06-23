# Prometheus Dashboards

To aid in speedy creation of dashboards and to allow reusability of metrics,
annotations etc across dashboards the following libsonnet libs have been
created:

- [annotations](./lib/annotations.libsonnet)
- [functions](./lib/functions.libsonnet)
- [links](./lib/links.libsonnet)
- [metrics](./lib/metrics.libsonnet)
- [variables](./lib/variables.libsonnet)

With these then one is able to easily compose dashboards with less boilerplate.

There are currently two dashboards built:

- **Go Process** is intended to give low leve process information about a go service.
  This is useful when digging further into a specific issue and not intended as
  an overview
- **K8s Container USE** makes use of the [cadvisor metrics](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md)
  and the [USE method](http://www.brendangregg.com/usemethod.html) to help
  allow viewers understand what the Utilisation, Saturation and Errors are of a
  container.
  This is useful when digging further into a specific issue and not intended as
  an overview
  