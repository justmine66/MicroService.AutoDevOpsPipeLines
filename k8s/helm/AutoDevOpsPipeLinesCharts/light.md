## 为我们的项目创建chart目录
helm create AutoDevOpsPipeLinesCharts

## 安装
## 渲染模板(调试)
```shell
helm install --debug --dry-run /root/AutoDevOpsPipeLinesCharts \
--set environment.upper=Production \
--set environment.lower=production \
--set namespace=geekbuying-light-v2  \
--set image.version=2.0.0 
```

## 发布版本
```shell
helm install /root/AutoDevOpsPipeLinesCharts \
--name=geekbuying-light-v2 \
--set environment.upper=Production \
--set environment.lower=production \
--set namespace=geekbuying-light-v3  \
--set image.version=2.0.0 
```



## 检视发布

helm get manifest [release name]

## 删除发布

helm delete [release name]

## 其他
helm ls
helm ls --deleted -d
helm del --purge $releaseName