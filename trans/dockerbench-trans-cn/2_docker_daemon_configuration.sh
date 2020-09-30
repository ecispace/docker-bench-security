#!/bin/sh

check_2() {
  logit "\n"
  id_2="2"
  desc_2="Docker 守护进程安全配置"
  check_2="$id_2 - $desc_2"
  info "$check_2"
  startsectionjson "$id_2" "$desc_2"
}

# 2.1
check_2_1() {
  id_2_1="2.1"
  desc_2_1="限制默认网桥上容器之间的网络流量 (计入评分)"
  check_2_1="$id_2_1  - $desc_2_1"
  starttestjson "$id_2_1" "$desc_2_1"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--icc' | grep false >/dev/null 2>&1; then
    pass "$check_2_1"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_configuration_file_args 'icc' | grep "false" >/dev/null 2>&1; then
    pass "$check_2_1"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_1"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 2.2
check_2_2() {
  id_2_2="2.2"
  desc_2_2="设置日志级别为info (计入评分)"
  check_2_2="$id_2_2  - $desc_2_2"
  starttestjson "$id_2_2" "$desc_2_2"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'log-level' >/dev/null 2>&1; then
    if get_docker_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
      pass "$check_2_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    elif [ -z "$(get_docker_configuration_file_args 'log-level')" ]; then
      pass "$check_2_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_2"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  elif get_docker_effective_command_line_args '-l'; then
    if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
      pass "$check_2_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_2"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_2_2"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.3
check_2_3() {
  id_2_3="2.3"
  desc_2_3="允许docker更改IPtables (计入评分)"
  check_2_3="$id_2_3  - $desc_2_3"
  starttestjson "$id_2_3" "$desc_2_3"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
    warn "$check_2_3"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  elif get_docker_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
    warn "$check_2_3"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_3"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.4
check_2_4() {
  id_2_4="2.4"
  desc_2_4="不使用不安全的镜像仓库 (计入评分)"
  check_2_4="$id_2_4  - $desc_2_4"
  starttestjson "$id_2_4" "$desc_2_4"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
    warn "$check_2_4"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  elif ! [ -z "$(get_docker_configuration_file_args 'insecure-registries')" ]; then
    if get_docker_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
      pass "$check_2_4"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_4"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_2_4"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.5
check_2_5() {
  id_2_5="2.5"
  desc_2_5="不使用aufs存储驱动程序 (计入评分)"
  check_2_5="$id_2_5  - $desc_2_5"
  starttestjson "$id_2_5" "$desc_2_5"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "^\sStorage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
    warn "$check_2_5"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_5"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.6
check_2_6() {
  id_2_6="2.6"
  desc_2_6="docker守护进程配置TLS身份认证 (计入评分)"
  check_2_6="$id_2_6  - $desc_2_6"
  starttestjson "$id_2_6" "$desc_2_6"

  totalChecks=$((totalChecks + 1))
  if [ $(get_docker_configuration_file_args 'tcp://') ] || \
    [ $(get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://') >/dev/null 2>&1 ]; then
    if [ $(get_docker_configuration_file_args '"tlsverify":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify') >/dev/null 2>&1 ]; then
      pass "$check_2_6"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    elif [ $(get_docker_configuration_file_args '"tls":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tls' | grep 'tls$') >/dev/null 2>&1 ]; then
      warn "$check_2_6"
      #warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
      warn "     * Docker守护进程监听使用了TLS的TCP, 但未启用验证"
      #resulttestjson "警告" "Docker daemon currently listening on TCP with TLS, but no verification"
      resulttestjson "警告" "Docker守护进程监听使用了TLS的TCP, 但未启用验证"
      currentScore=$((currentScore - 1))
    else
      warn "$check_2_6"
      #warn "     * Docker daemon currently listening on TCP without TLS"
      warn "     * Docker守护进程监听未使用TLS的TCP"
      #resulttestjson "警告" "Docker daemon currently listening on TCP without TLS"
      resulttestjson "警告" "Docker守护进程监听未使用TLS的TCP"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_2_6"
    #info "     * Docker daemon not listening on TCP"
    info "     * Docker守护进程未监听TCP"
    #resulttestjson "信息" "Docker daemon not listening on TCP"
    resulttestjson "信息" "Docker守护进程未监听TCP"
    currentScore=$((currentScore + 0))
  fi
}

# 2.7
check_2_7() {
  id_2_7="2.7"
  desc_2_7="配置合适的ulimit (不计评分)"
  check_2_7="$id_2_7  - $desc_2_7"
  starttestjson "$id_2_7" "$desc_2_7"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
    pass "$check_2_7"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
    pass "$check_2_7"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    info "$check_2_7"
    #info "     * Default ulimit doesn't appear to be set"
    info "     * 默认的ulimit 似乎没有设置"
    #resulttestjson "信息" "Default ulimit doesn't appear to be set"
    resulttestjson "信息" "默认的ulimit 似乎没有设置"
    currentScore=$((currentScore + 0))
  fi
}

# 2.8
check_2_8() {
  id_2_8="2.8"
  desc_2_8="启用用户命名空间 (计入评分)"
  check_2_8="$id_2_8  - $desc_2_8"
  starttestjson "$id_2_8" "$desc_2_8"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'userns-remap' | grep -v '""'; then
    pass "$check_2_8"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
    pass "$check_2_8"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_8"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 2.9
check_2_9() {
  id_2_9="2.9"
  desc_2_9="使用默认cgroup (计入评分)"
  check_2_9="$id_2_9  - $desc_2_9"
  starttestjson "$id_2_9" "$desc_2_9"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'cgroup-parent' | grep -v ''; then
    warn "$check_2_9"
    #info "     * Confirm cgroup usage"
    info "     * 确认cgroup的使用"
    #resulttestjson "警告" "Confirm cgroup usage"
    resulttestjson "警告" "确认cgroup的使用"
    currentScore=$((currentScore + 0))
  elif get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
    warn "$check_2_9"
    #info "     * Confirm cgroup usage"
    info "     * 确认cgroup的使用"
    #resulttestjson "警告" "Confirm cgroup usage"
    resulttestjson "警告" "确认cgroup的使用"
    currentScore=$((currentScore + 0))
  else
    pass "$check_2_9"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.10
check_2_10() {
  id_2_10="2.10"
  desc_2_10="设置容器的默认空间大小 (计入评分)"
  check_2_10="$id_2_10  - $desc_2_10"
  starttestjson "$id_2_10" "$desc_2_10"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
    warn "$check_2_10"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  elif get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
    warn "$check_2_10"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_10"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.11
check_2_11() {
  id_2_11="2.11"
  desc_2_11="启用docker客户端命令的授权 (计入评分)"
  check_2_11="$id_2_11  - $desc_2_11"
  starttestjson "$id_2_11" "$desc_2_11"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'authorization-plugins' | grep -v '\[]'; then
    pass "$check_2_11"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
    pass "$check_2_11"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_11"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 2.12
check_2_12() {
  id_2_12="2.12"
  desc_2_12="配置集中和远程日志记录 (计入评分)"
  check_2_12="$id_2_12  - $desc_2_12"
  starttestjson "$id_2_12" "$desc_2_12"

  totalChecks=$((totalChecks + 1))
  if docker info --format '{{ .LoggingDriver }}' | grep 'json-file' >/dev/null 2>&1; then
    warn "$check_2_12"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_12"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  fi
}

# 2.13
check_2_13() {
  id_2_13="2.13"
  desc_2_13="启用实时恢复 (计入评分)"
  check_2_13="$id_2_13  - $desc_2_13"
  starttestjson "$id_2_13" "$desc_2_13"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
    pass "$check_2_13"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
      pass "$check_2_13 (Incompatible with swarm mode)"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    elif get_docker_effective_command_line_args '--live-restore' | grep "live-restore" >/dev/null 2>&1; then
      pass "$check_2_13"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_13"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  fi
}

# 2.14
check_2_14() {
  id_2_14="2.14"
  desc_2_14="禁用userland代理 (计入评分)"
  check_2_14="$id_2_14  - $desc_2_14"
  starttestjson "$id_2_14" "$desc_2_14"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'userland-proxy' | grep false >/dev/null 2>&1; then
    pass "$check_2_14"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
    pass "$check_2_14"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_14"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 2.15
check_2_15() {
  id_2_15="2.15"
  desc_2_15="应用守护进程范围的自定义seccomp配置文件 (不计评分)"
  check_2_15="$id_2_15  - $desc_2_15"
  starttestjson "$id_2_15" "$desc_2_15"

  totalChecks=$((totalChecks + 1))
  if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
    pass "$check_2_15"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    info "$check_2_15"
    resulttestjson "信息"
    currentScore=$((currentScore + 0))
  fi
}

# 2.16
check_2_16() {
  id_2_16="2.16"
  desc_2_16="生产环境中避免实验性功能 (计入评分)"
  check_2_16="$id_2_16  - $desc_2_16"
  starttestjson "$id_2_16" "$desc_2_16"

  totalChecks=$((totalChecks + 1))
  if docker version -f '{{.Server.Experimental}}' | grep false 2>/dev/null 1>&2; then
    pass "$check_2_16"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_16"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 2.17
check_2_17() {
  id_2_17="2.17"
  desc_2_17="限制容器获取新的权限 (计入评分)"
  check_2_17="$id_2_17  - $desc_2_17"
  starttestjson "$id_2_17" "$desc_2_17"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--no-new-privileges' | grep "no-new-privileges" >/dev/null 2>&1; then
    pass "$check_2_17"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  elif get_docker_configuration_file_args 'no-new-privileges' | grep true >/dev/null 2>&1; then
    pass "$check_2_17"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_17"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

check_2_end() {
  endsectionjson
}
