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
