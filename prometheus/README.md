# Prometheus Dashboards

## Queries List

```
process_resident_memory_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
process_virtual_memory_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
rate(process_resident_memory_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
deriv(process_virtual_memory_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
go_memstats_alloc_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
rate(go_memstats_alloc_bytes_total{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[30s])
go_memstats_stack_inuse_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
go_memstats_heap_inuse_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
deriv(go_memstats_alloc_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
rate(go_memstats_alloc_bytes_total{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
deriv(go_memstats_stack_inuse_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
deriv(go_memstats_heap_inuse_bytes{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
process_open_fds{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
deriv(process_open_fds{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}[$interval])
go_goroutines{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}
go_gc_duration_seconds{namespace=~\"^($namespace)$\",pod=~\"^($pod)$\"}

```
