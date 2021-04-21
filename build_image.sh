
zip -x "*\.DS_Store" -x "__MACOSX" -r -q trans.zip trans 

docker buildx build -t registry.cn-qingdao.aliyuncs.com/diss/docker-bench-security .
