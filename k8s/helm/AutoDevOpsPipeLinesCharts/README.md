## 为我们的项目创建chart目录
helm create AutoDevOpsPipeLinesCharts

## 安装
## 渲染模板(调试)
```shell
helm install --debug --dry-run /root/AutoDevOpsPipeLinesCharts \
--name=v1 \
--set environment.upper=Production \
--set environment.lower=production \
--set namespace=microservice-autodevopspipeline-v1 \
--set image.registryhost=registry.prod.com:8100 \
--set image.username=devopspipelines \
--set image.version=1.0.0 \
--set replicas=1
```

## 发布版本
```shell
helm install /root/AutoDevOpsPipeLinesCharts \
--name=v1 \
--set environment.upper=Production \
--set environment.lower=production \
--set namespace=microservice-autodevopspipeline-v1 \
--set image.registryhost=registry.prod.com:8100 \
--set image.username=devopspipelines \
--set image.version=1.0.0 \
--set replicas=1
```

## 检视发布

helm get manifest [release name]

## 删除发布

helm delete [release name]

## 其他
helm ls
helm ls --deleted -d
helm del --purge $releaseName