#!/bin/sh

check_6() {
  logit "\n"
  id_6="6"
  desc_6="Docker 安全操作"
  check_6="$id_6 - $desc_6"
  info "$check_6"
  startsectionjson "$id_6" "$desc_6"
}

# 6.1
check_6_1() {
  id_6_1="6.1"
  desc_6_1="避免镜像泛滥 (不计评分)"
  check_6_1="$id_6_1  - $desc_6_1"
  starttestjson "$id_6_1" "$desc_6_1"

  infojson "suggest" "保留您实际需要的一组镜像，并建立工作流程以从主机中删除陈旧的镜像。 此外，使用诸如按摘要的功能从镜像仓库中获取特定镜像。 可以按照以下步骤找出系统上未使用的镜像并删除它们。 步骤1通过执行以下命令列出当前实例化的所有镜像ID： docker images --quiet | xargs docker inspect --format'{{.Id}}：Image = {{.Config.Image}}' 步骤2：通过执行以下命令列出系统中存在的所有镜像：docker images 步骤3：比较步骤1和步骤2中填充的镜像ID列表，找出当前未实例化的镜像。 第4步：决定是否要保留当前未使用的镜像。 如果不通过执行以下命令删除它们：docker rmi $ IMAGE_ID。"

  totalChecks=$((totalChecks + 1))
  images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(docker inspect --format "{{.Image}}" $(docker ps -qa) 2>/dev/null); do
    if docker images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

    info "$check_6_1"
    info "     * 目前有容器: $images images"

  if [ "$active_images" -lt "$((images / 2))" ]; then
    info "     * 仅有 $active_images 个镜像是活跃的，总共使用$images 个镜像"
  fi
  resulttestjson "信息" "$active_images 活跃的/$images 使用中的"
  currentScore=$((currentScore + 0))
}

# 6.2
check_6_2() {
  id_6_2="6.2"
  desc_6_2="避免容器泛滥 (不计评分)"
  check_6_2="$id_6_2  - $desc_6_2"
  starttestjson "$id_6_2" "$desc_6_2"

  infojson "suggest" "定期检查每个主机的容器清单，并使用以下命令清理已停止的容器：docker container prune。"
  infojson "notice" "如果你每个主机的容器数量太少，那么你可能没有充分利用你的主机资源。"

  totalChecks=$((totalChecks + 1))
  total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(docker ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  if [ "$diff" -gt 25 ]; then
    info "$check_6_2"
    info "     * 共有 $total_containers 个容器, 只有 $running_containers 个运行中"
    resulttestjson "信息" "$total_containers 容器总数/$running_containers 运行中的"
  else
    info "$check_6_2"
    info "     * 共有 $total_containers 个容器, $running_containers 个运行中"
    resulttestjson "信息" "$total_containers 容器总数/$running_containers 运行中的"
  fi
  currentScore=$((currentScore + 0))
}

check_6_end() {
  endsectionjson
}
