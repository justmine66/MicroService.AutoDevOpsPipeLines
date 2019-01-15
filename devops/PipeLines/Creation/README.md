# ÇĺŔíťˇžł
˛Îżź˝Ĺąž
## k8s
helm delete --purge microservice.autodevopspipeline.v1

kubectl delete namespace microservice-autodevopspipeline-v1

helm delete --purge microservice.autodevopspipeline.v2

kubectl delete namespace microservice-autodevopspipeline-v2

## gateway
select name,host,path FROM services where created_at>'2019-01-10';

select protocols,methods,hosts,paths FROM routes where created_at>'2019-01-10';

delete FROM routes where created_at>'2019-01-10';

delete FROM services where created_at>'2019-01-10';
