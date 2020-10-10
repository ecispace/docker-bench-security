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

  infojson "suggest" "如果在系统出错时启用了集群模式，请停用。"

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

  infojson "suggest" "如果配置的管理节点数量过多，则可以使用以下命令将超出部分作为节点降级： docker node demote <ID>。"

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

  infojson "suggest" "对此操作需要重新初始化集群，以指定--listen-addr参数的特定接口。"

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

  infojson "suggest" "使用--opt加密标志创建网络。"

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

  infojson "suggest" "按照docker秘密管理方法，并用它来有效管理秘密。"

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

  infojson "suggest" "如果正在初始化swarm，使用下面的命令。 docker swarm init --autolock 如果想在现有的swarm manager节点上设置--autolock，请使用以下命令。 Docker swarm update --autolock。"
  infojson "notice" "在自动锁定模式下的群体不会从重新启动恢复，需用户手动干预以输入解锁密钥。 在某些部署中，这可能不是很方便。"

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

  infojson "suggest" "运行以下命令来更换。 Docker swarm unlock-key --rotate 此外，为了便于审计，维护密钥轮换记录并确保为密钥轮换符合规定周期。"

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

  infojson "suggest" "运行以下命令来设置所需的到期时间。 例如，docker swarm update--cert-expiry 48h。"

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

  infojson "suggest" "运行以下命令来更换证书。 Docker swarm ca - rotate。"

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

  infojson "suggest" "分别用管理数据系统和业务数据系统的专用接口初始化Swarm。 例如，docker swarm init --advertise-addr = 192.168.0.1 --data-path-addr = 17.1.0.3"
  infojson "notice" "需要每个节点2个网络接口卡。"

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
