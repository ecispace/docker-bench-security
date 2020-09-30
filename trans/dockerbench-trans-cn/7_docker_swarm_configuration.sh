#!/bin/sh

check_7() {
  logit "\n"
  id_7="7"
  desc_7="Docker 集群配置"
  check_7="$id_7 - $desc_7"
  info "$check_7"
  startsectionjson "$id_7" "$desc_7"
}

# 7.1
check_7_1() {
  id_7_1="7.1"
  desc_7_1="必要时不启用群集模式 (计入评分)"
  check_7_1="$id_7_1  - $desc_7_1"
  starttestjson "$id_7_1" "$desc_7_1"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sinactive\s*" >/dev/null 2>&1; then
    pass "$check_7_1"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_7_1"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 7.2
check_7_2() {
  id_7_2="7.2"
  desc_7_2="在群集中最小数量创建管理器节点 (计入评分)"
  check_7_2="$id_7_2  - $desc_7_2"
  starttestjson "$id_7_2" "$desc_7_2"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    managernodes=$(docker node ls | grep -c "Leader")
    if [ "$managernodes" -eq 1 ]; then
      pass "$check_7_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_7_2"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_7_2 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.3
check_7_3() {
  id_7_3="7.3"
  desc_7_3="群集服务绑定到特定的主机接口 (计入评分)"
  check_7_3="$id_7_3  - $desc_7_3"
  starttestjson "$id_7_3" "$desc_7_3"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    $netbin -lnt | grep -e '\[::]:2377 ' -e ':::2377' -e '*:2377 ' -e ' 0\.0\.0\.0:2377 ' >/dev/null 2>&1
    if [ $? -eq 1 ]; then
      pass "$check_7_3"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_7_3"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_7_3 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.4
check_7_4() {
  id_7_4="7.4"
  desc_7_4="数据在的不同节点上进行加密 (计入评分)"
  check_7_4="$id_7_4  - $desc_7_4"
  starttestjson "$id_7_4" "$desc_7_4"

  totalChecks=$((totalChecks + 1))
  fail=0
  unencrypted_networks=""
  for encnet in $(docker network ls --filter driver=overlay --quiet); do
    if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
      grep -v 'encrypted:' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_7_4"
        fail=1
      fi
      warn "     * 未加密的overlay网络: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
      unencrypted_networks="$unencrypted_networks $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
    fi
  done
  # We went through all the networks and found none that are unencrypted
  if [ $fail -eq 0 ]; then
      pass "$check_7_4"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "未加密的overlay网络:" "$unencrypted_networks"
      currentScore=$((currentScore - 1))
  fi
}

# 7.5
check_7_5() {
  id_7_5="7.5"
  desc_7_5="管理 Swarm 集群中的涉密信息 (不计评分)"
  check_7_5="$id_7_5  - $desc_7_5"
  starttestjson "$id_7_5" "$desc_7_5"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
      pass "$check_7_5"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      info "$check_7_5"
      resulttestjson "信息"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check_7_5 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.6
check_7_6() {
  id_7_6="7.6"
  desc_7_6="swarm manager 在自动锁定模式下运行 (计入评分)"
  check_7_6="$id_7_6  - $desc_7_6"
  starttestjson "$id_7_6" "$desc_7_6"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
      warn "$check_7_6"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    else
      pass "$check_7_6"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    fi
  else
    pass "$check_7_6 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.7
check_7_7() {
  id_7_7="7.7"
  desc_7_7="swarm manager 自动锁定秘钥周期性轮换 (不计评分)"
  check_7_7="$id_7_7  - $desc_7_7"
  starttestjson "$id_7_7" "$desc_7_7"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    note "$check_7_7"
    resulttestjson "提示"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_7 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.8
check_7_8() {
  id_7_8="7.8"
  desc_7_8="节点证书适当轮换 (不计评分)"
  check_7_8="$id_7_8  - $desc_7_8"
  starttestjson "$id_7_8" "$desc_7_8"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if docker info 2>/dev/null | grep "Expiry Duration: 2 days"; then
      pass "$check_7_8"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      info "$check_7_8"
      resulttestjson "信息"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check_7_8 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.9
check_7_9() {
  id_7_9="7.9"
  desc_7_9="CA 根证书根据需要进行轮换 (不计评分)"
  check_7_9="$id_7_9  - $desc_7_9"
  starttestjson "$id_7_9" "$desc_7_9"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check_7_9"
    resulttestjson "信息"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_9 (集群模式未启用d)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 7.10
check_7_10() {
  id_7_10="7.10"
  desc_7_10="管理平面流量分流自数据平面流量 (不计评分)"
  check_7_10="$id_7_10  - $desc_7_10"
  starttestjson "$id_7_10" "$desc_7_10"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check_7_10"
    resulttestjson "信息"
    currentScore=$((currentScore + 0))
  else
    pass "$check_7_10 (集群模式未启用)"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

check_7_end() {
  endsectionjson
}
