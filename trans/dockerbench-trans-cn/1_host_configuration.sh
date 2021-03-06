#!/bin/sh

check_1() {
  logit ""
  id_1="1"
  desc_1="Docker主机配置"
  check_1="$id_1 - $desc_1"
  info "$check_1"
  startsectionjson "$id_1" "$desc_1"
}

check_1_1() {
  logit ""
  id_1_1="1.1"
  desc_1_1="通用配置"
  check_1_1="$id_1_1 - $desc_1_1"
  info "$check_1_1"

}

# 1.1.1
check_1_1_1() {
  id_1_1_1="1.1.1"
  desc_1_1_1="加固容器宿主机 (不计评分)"
  check_1_1_1="$id_1_1_1  - $desc_1_1_1"
  starttestjson "$id_1_1_1" "$desc_1_1_1"

  infojson "suggest" "使用主机安全标准加固主机。"

  totalChecks=$((totalChecks + 1))
  note "$check_1_1_1"

  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 1.1.2
check_1_1_2() {
  id_1_1_2="1.1.2"
  desc_1_1_2="保持Docker版本更新 (不计评分)"
  check_1_1_2="$id_1_1_2  - $desc_1_1_2"
  starttestjson "$id_1_1_2" "$desc_1_1_2"

  infojson "suggest" "跟踪Docker发布并根据需要进行更新。"
  infojson "notice" "对Docker版本更新进行风险评估，了解它们可能会如何影响Docker操作。 请注意，有些使用Docker的第三方产品可能需要支持较老版本的Docker。"

  totalChecks=$((totalChecks + 1))
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="$(date +%y.%m.0 -d @$(( $(date +%s) - 2592000)))"
  do_version_check "$docker_current_version" "$docker_version"
  if [ $? -eq 11 ]; then
    info "$check_1_1_2"
    # info "       * Using $docker_version, verify is it up to date as deemed necessary"
    info "       * 使用的版本 $docker_version, 确认Docker更新到所需版本"
    #info "       * Your operating system vendor may provide support and security maintenance for Docker"
    info "       * 你的操作系统提供商可能提供docker的支持以及安全维护"
    resulttestjson "信息" "Using $docker_version"
    currentScore=$((currentScore + 0))
  else
    pass "$check_1_1_2"
    #info "       * Using $docker_version which is current"
    info "       * 当前使用的版本 $docker_version "
    #info "       * Check with your operating system vendor for support and security maintenance for Docker"
    info "       * 你的操作系统提供商可能提供docker的支持以及安全维护"
    resulttestjson "通过" "Using $docker_version"
    currentScore=$((currentScore + 0))
  fi
}

check_1_2() {
  logit ""
  id_1_2="1.2"
  desc_1_2="Linux 主机专用配置"
  check_1_2="$id_1_2 - $desc_1_2"
  info "$check_1_2"
}

# 1.2.1
check_1_2_1() {
  id_1_2_1="1.2.1"
  desc_1_2_1="为容器创建一个单独的分区 (计入评分)"
  check_1_2_1="$id_1_2_1 - $desc_1_2_1"
  starttestjson "$id_1_2_1" "$desc_1_2_1"

  infojson "suggest" "新安装docker时，为/var/lib/docker挂载点创建一个单独的分区。对于先前安装的系统，请使用逻辑卷管理器（LVM）创建分区。"

  totalChecks=$((totalChecks + 1))

  if mountpoint -q -- "$(docker info -f '{{ .DockerRootDir }}')" >/dev/null 2>&1; then
    pass "$check_1_2_1"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_2_1"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.2
check_1_2_2() {
  id_1_2_2="1.2.2"
  desc_1_2_2="只有受信任的用户才能控制 docker 守护进程  (计入评分)"
  check_1_2_2="$id_1_2_2  - $desc_1_2_2"
  starttestjson "$id_1_2_2" "$desc_1_2_2"

  infojson "suggest" "从docker组中删除任何不受信任的用户。 另外，请勿在主机上创建敏感目录到容器卷的映射。"
  infojson "notice" "作为普通用户构建和执行容器的权限将受到限制。"

  totalChecks=$((totalChecks + 1))
  if command -v getent >/dev/null 2>&1; then
    docker_users=$(getent group docker)
  else
    docker_users=$(grep 'docker' /etc/group)
  fi
  info "$check_1_2_2"
  for u in $docker_users; do
    info "       * $u"
  done
  resulttestjson "信息" "users" "$docker_users"
  currentScore=$((currentScore + 0))
}

# 1.2.3
check_1_2_3() {
  id_1_2_3="1.2.3"
  desc_1_2_3="审计docker守护进程 (计入评分)"
  check_1_2_3="$id_1_2_3  - $desc_1_2_3"
  starttestjson "$id_1_2_3" "$desc_1_2_3"

  infojson "suggest" "为Docker守护进程添加一条规则，例如，在/etc/audit/audit.rules文件中将该行添加到以下行中或者运行命令直接添加：auditctl -w /usr/bin/docker -k docker然后，重新启动审计守护进程。 例如server auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/dockerd"
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check_1_2_3"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_3"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_2_3"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_2_3"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.4
check_1_2_4() {
  id_1_2_4="1.2.4"
  desc_1_2_4="审计docker文件和目录-/var/lib/docker - /var/lib/docker (计入评分)"
  check_1_2_4="$id_1_2_4  - $desc_1_2_4"
  starttestjson "$id_1_2_4" "$desc_1_2_4"

  infojson "suggest" "为/var/lib/docker目录添加一条规则。 例如，将以下行添加到/etc/audit/audit.rules文件中：-w/var/lib/docker -k docker然后，重新启动审计守护进程。 例如service auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  directory="/var/lib/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_2_4"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_4"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_4"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_4"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_4"
    info "       * 没有找到目录"
    resulttestjson "信息" "没有找到目录"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.5
check_1_2_5() {
  id_1_2_5="1.2.5"
  desc_1_2_5="审计docker文件和目录 - /etc/docker (计入评分)"
  check_1_2_5="$id_1_2_5  - $desc_1_2_5"
  starttestjson "$id_1_2_5" "$desc_1_2_5"

  infojson "suggest" "为/etc/docker目录添加一条规则。 例如，在/etc/audit/audit.rules文件中添加如下所示的行-w /etc/docker -k docker然后，重新启动审计守护进程。 例如servise auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_2_5"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_5"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_5"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_5"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_5"
    info "       * 没有找到目录"
    resulttestjson "信息" "没有找到目录"
    currentScore=$((currentScore + 0))
fi
}

# 1.2.6
check_1_2_6() {
  id_1_2_6="1.2.6"
  desc_1_2_6="审计docker文件和目录 - docker.service (计入评分)"
  check_1_2_6="$id_1_2_6  - $desc_1_2_6"
  starttestjson "$id_1_2_6" "$desc_1_2_6"

  infojson "suggest" "如果该文件存在，请为其添加规则。例如，在/etc/audit/audit.rules文件中添加以下行：-w /usr/lib/systemd/system/docker.service -k docker然后，重新启动审计守护进程。 例如，servise auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_2_6"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_6"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_6"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_6"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_6"
    info "       * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.7
check_1_2_7() {
  id_1_2_7="1.2.7"
  desc_1_2_7="审计docker文件和目录 - docker.socket (计入评分)"
  check_1_2_7="$id_1_2_7  - $desc_1_2_7"
  starttestjson "$id_1_2_7" "$desc_1_2_7"

  infojson "suggest" "如果文件存在，为其添加审计策略：. 在/etc/audit/audit.rules 文件添加一行: -w /usr/lib/systemd/system/docker.socket -k docker 然后重启审计进程：service auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_2_7"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_7"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_7"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_7"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_7"
    info "       * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.8
check_1_2_8() {
  id_1_2_8="1.2.8"
  desc_1_2_8="审计docker文件和目录 - /etc/default/docker (计入评分)"
  check_1_2_8="$id_1_2_8  - $desc_1_2_8"
  starttestjson "$id_1_2_8" "$desc_1_2_8"

  infojson "suggest" "如果文件存在，为其添加审计策略在/etc/audit/audit.rules 文件添加一行-w /etc/default/docker -k docker然后重启审计进程service auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_8"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_8"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_8"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_8"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_8"
    info "       * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.9
check_1_2_9() {
  id_1_2_9="1.2.9"
  desc_1_2_9="审计docker文件和目录 - /etc/sysconfig/docker (计入评分)"
  check_1_2_9="$id_1_2_9  - $desc_1_2_9"
  starttestjson "$id_1_2_9" "$desc_1_2_9"

  infojson "suggest" " 在/etc/sysconfig/docker 文件添加规则。
      例如在 /etc/audit/audit.rules 文件中添加如下行: -w /etc/sysconfig/docker -k docker
      然后，重新启动审计守护程序。 例如: service auditd restart"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_9"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_9"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_9"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_9"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_9"
    info "       * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.10
check_1_2_10() {
  id_1_2_10="1.2.10"
  desc_1_2_10="审计docker文件和目录 - /etc/docker/daemon.json (计入评分)"
  check_1_2_10="$id_1_2_10  - $desc_1_2_10"
  starttestjson "$id_1_2_10" "$desc_1_2_10"

  infojson "suggest" "添加/etc/docker/daemon.json 文件的规则 例如在 /etc/audit/audit.rules文件中添加如下行-w /etc/docker/daemon.json -k docker 然后，重新启动审计守护程序。 例如service auditd restart。"
  infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_10"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_10"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_10"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_10"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_10"
    info "        * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.11
check_1_2_11() {
  id_1_2_11="1.2.11"
  desc_1_2_11="审计docker文件和目录 - /usr/bin/containerd (计入评分)"
  check_1_2_11="$id_1_2_11  - $desc_1_2_11"
  starttestjson "$id_1_2_11" "$desc_1_2_11"

  infojson "suggest" "跟踪Docker发布并根据需要进行更新。"
    infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/containerd"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_11"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_11"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_11"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_11"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_11"
    info "        * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.12
check_1_2_12() {
  id_1_2_12="1.2.12"
  desc_1_2_12="审计docker文件和目录 - /usr/sbin/runc (计入评分)"
  check_1_2_12="$id_1_2_12  - $desc_1_2_12"
  starttestjson "$id_1_2_12" "$desc_1_2_12"

  infojson "suggest" "跟踪Docker发布并根据需要进行更新。"
    infojson "notice" "审计生成相当大的日志文件。 确保定期归档它们。 另外，创建一个单独的审计分区以避免写满根文件系统。"

  totalChecks=$((totalChecks + 1))
  file="/usr/sbin/runc"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_12"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_12"
        resulttestjson "警告"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_12"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_12"
      resulttestjson "警告"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_12"
    info "        * 没有找到文件"
    resulttestjson "信息" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

check_1_end() {
  endsectionjson
}
