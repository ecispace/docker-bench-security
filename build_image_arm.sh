
zip -x "*\.DS_Store" -x "__MACOSX" -r -q trans.zip trans 

docker buildx build -t registry.cn-qingdao.aliyuncs.com/diss/docker-bench-security:v.1.3.5 . --platform=linux/arm64 -o type=docker -f Dockerfile.arm