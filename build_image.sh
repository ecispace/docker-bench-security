
zip -x "*\.DS_Store" -x "__MACOSX" -r -q trans.zip trans 

docker build -t registry.cn-qingdao.aliyuncs.com/diss/docker-bench-security .
