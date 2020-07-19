#!/bin/sh

check_3() {
  logit "\n"
  id_3="3"
  desc_3="Docker 守护进程文件权限配置"
  check_3="$id_3 - $desc_3"
  info "$check_3"
  startsectionjson "$id_3" "$desc_3"
}

# 3.1
check_3_1() {
  id_3_1="3.1"
  desc_3_1="设置docker.service文件的所有权为 root:root (计入评分)"
  check_3_1="$id_3_1  - $desc_3_1"
  starttestjson "$id_3_1" "$desc_3_1"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check_3_1"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_1"
      #warn "     * Wrong ownership for $file"
      warn "     * 错误的所有权设置 $file"
      #resulttestjson "警告" "Wrong ownership for $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_1"
    info "     * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.2
check_3_2() {
  id_3_2="3.2"
  desc_3_2="设置docker.service文件权限为644或更多限制性 (计入评分)"
  check_3_2="$id_3_2  - $desc_3_2"
  starttestjson "$id_3_2" "$desc_3_2"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 644 ] || [ "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_2"
      #warn "     * Wrong permissions for $file"
      warn "     * 错误的文件权限设置 $file"
      #resulttestjson "警告" "Wrong permissions for $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_2"
    info "     * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.3
check_3_3() {
  id_3_3="3.3"
  desc_3_3="设置docker.socket文件所有权为 root:root (计入评分)"
  check_3_3="$id_3_3  - $desc_3_3"
  starttestjson "$id_3_3" "$desc_3_3"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check_3_3"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_3"
      #warn "     * Wrong ownership for $file"
      warn "     * 错误的所有权设置 $file"
      #resulttestjson "警告" "Wrong ownership for $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_3"
    info "     * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.4
check_3_4() {
  id_3_4="3.4"
  desc_3_4="设置docker.socket文件权限为644或更多限制性 (计入评分)"
  check_3_4="$id_3_4  - $desc_3_4"
  starttestjson "$id_3_4" "$desc_3_4"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 644 ] || [ "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_4"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_4"
      warn "     * 错误的文件权限设置 $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_4"
    info "     * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.5
check_3_5() {
  id_3_5="3.5"
  desc_3_5="设置/etc/docker目录所有权为 root:root (计入评分)"
  check_3_5="$id_3_5  - $desc_3_5"
  starttestjson "$id_3_5" "$desc_3_5"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
      pass "$check_3_5"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_5"
      warn "     * 错误的所有权设置 $directory"
      resulttestjson "警告" "错误的所有权设置 $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_5"
    info "     * 没有找到目录"
    resulttestjson "正常" "没有找到目录"
    currentScore=$((currentScore + 0))
  fi
}

# 3.6
check_3_6() {
  id_3_6="3.6"
  desc_3_6="设置/etc/docker目录权限为755或更多限制性 (计入评分)"
  check_3_6="$id_3_6  - $desc_3_6"
  starttestjson "$id_3_6" "$desc_3_6"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -eq 755 ] || [ "$(stat -c %a $directory)" -eq 700 ]; then
      pass "$check_3_6"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_6"
      warn "     * 错误的文件权限设置 $directory"
      resulttestjson "警告" "错误的文件权限设置 $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_6"
    info "     * 没有找到目录"
    resulttestjson "正常" "没有找到目录"
    currentScore=$((currentScore + 0))
  fi
}

# 3.7
check_3_7() {
  id_3_7="3.7"
  desc_3_7="设置仓库证书文件所有权为root:root (计入评分)"
  check_3_7="$id_3_7  - $desc_3_7"
  starttestjson "$id_3_7" "$desc_3_7"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    owners=$(find "$directory" -type f -name '*.crt')
    for p in $owners; do
      if [ "$(stat -c %u $p)" -ne 0 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn "$check_3_7"
      warn "     * 错误的所有权设置 $directory"
      resulttestjson "警告" "错误的所有权设置 $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check_3_7"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check_3_7"
    info "     * 没有找到目录"
    resulttestjson "正常" "没有找到目录"
    currentScore=$((currentScore + 0))
  fi
}

# 3.8
check_3_8() {
  id_3_8="3.8"
  desc_3_8="设置仓库证书文件权限为444或更多限制性 (计入评分)"
  check_3_8="$id_3_8  - $desc_3_8"
  starttestjson "$id_3_8" "$desc_3_8"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    perms=$(find "$directory" -type f -name '*.crt')
    for p in $perms; do
      if [ "$(stat -c %a $p)" -ne 444 ] && [ "$(stat -c %a $p)" -ne 400 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn "$check_3_8"
      warn "     * 错误的文件权限设置 $directory"
      resulttestjson "警告" "错误的文件权限设置 $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check_3_8"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check_3_8"
    info "     * 没有找到目录"
    resulttestjson "正常" "没有找到目录"
    currentScore=$((currentScore + 0))
  fi
}

# 3.9
check_3_9() {
  id_3_9="3.9"
  desc_3_9="设置TLS CA证书文件所有权为root:root (计入评分)"
  check_3_9="$id_3_9  - $desc_3_9"
  starttestjson "$id_3_9" "$desc_3_9"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
      pass "$check_3_9"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_9"
      warn "     * 错误的所有权设置 $tlscacert"
      resulttestjson "警告" "错误的所有权设置 $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_9"
    info "     * No TLS CA certificate found"
    resulttestjson "正常" "No TLS CA certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.10
check_3_10() {
  id_3_10="3.10"
  desc_3_10="设置TLS CA证书文件权限为444或更多限制性 (计入评分)"
  check_3_10="$id_3_10  - $desc_3_10"
  starttestjson "$id_3_10" "$desc_3_10"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %a $tlscacert)" -eq 444 ] || [ "$(stat -c %a $tlscacert)" -eq 400 ]; then
      pass "$check_3_10"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_10"
      warn "      * 错误的文件权限设置 $tlscacert"
      resulttestjson "警告" "错误的文件权限设置 $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_10"
    info "      * 没找到TLS CA证书文件"
    resulttestjson "正常" "没找到TLS CA证书文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.11
check_3_11() {
  id_3_11="3.11"
  desc_3_11="设置docker服务器证书文件所有权为root:root (计入评分)"
  check_3_11="$id_3_11  - $desc_3_11"
  starttestjson "$id_3_11" "$desc_3_11"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
      pass "$check_3_11"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_11"
      warn "      * 错误的所有权设置 $tlscert"
      resulttestjson "警告" "错误的所有权设置 $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_11"
    info "      * 没有找到TLS服务器证书文件"
    resulttestjson "正常" "没有找到TLS服务器证书文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.12
check_3_12() {
  id_3_12="3.12"
  desc_3_12="设置docker服务器证书文件权限为444或更多限制 (计入评分)"
  check_3_12="$id_3_12  - $desc_3_12"
  starttestjson "$id_3_12" "$desc_3_12"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %a $tlscert)" -eq 444 ] || [ "$(stat -c %a $tlscert)" -eq 400 ]; then
      pass "$check_3_12"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_12"
      warn "      * 错误的文件权限设置 $tlscert"
      resulttestjson "警告" "错误的文件权限设置 $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_12"
    info "      * 没有找到TLS服务器证书文件"
    resulttestjson "正常" "没有找到TLS服务器证书文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.13
check_3_13() {
  id_3_13="3.13"
  desc_3_13="设置docker服务器证书密钥文件所有权为 root:root (计入评分)"
  check_3_13="$id_3_13  - $desc_3_13"
  starttestjson "$id_3_13" "$desc_3_13"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
      pass "$check_3_13"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_13"
      warn "      * 错误的所有权设置 $tlskey"
      resulttestjson "警告" "错误的所有权设置 $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_13"
    info "      * 没有找到TLS Key"
    resulttestjson "正常" "没有找到TLS Key"
    currentScore=$((currentScore + 0))
  fi
}

# 3.14
check_3_14() {
  id_3_14="3.14"
  desc_3_14="设置docker服务器证书密钥文件权限为400 (计入评分)"
  check_3_14="$id_3_14  - $desc_3_14"
  starttestjson "$id_3_14" "$desc_3_14"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %a $tlskey)" -eq 400 ]; then
      pass "$check_3_14"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_14"
      warn "      * 错误的文件权限设置 $tlskey"
      resulttestjson "警告" "错误的文件权限设置 $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_14"
    info "      * 没有找到TLS Key"
    resulttestjson "正常" "没有找到TLS Key"
    currentScore=$((currentScore + 0))
  fi
}

# 3.15
check_3_15() {
  id_3_15="3.15"
  desc_3_15="设置docker.sock文件所有权为 root:docker (计入评分)"
  check_3_15="$id_3_15  - $desc_3_15"
  starttestjson "$id_3_15" "$desc_3_15"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
      pass "$check_3_15"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_15"
      warn "      * 错误的所有权设置 $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_15"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.16
check_3_16() {
  id_3_16="3.16"
  desc_3_16="设置docker.sock文件权限为660或更多限制性 (计入评分)"
  check_3_16="$id_3_16  - $desc_3_16"
  starttestjson "$id_3_16" "$desc_3_16"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 660 ] || [  "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_16"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_16"
      warn "      * 错误的文件权限设置 $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_16"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.17
check_3_17() {
  id_3_17="3.17"
  desc_3_17="设置daemon.json文件所有权为 root:root (计入评分)"
  check_3_17="$id_3_17  - $desc_3_17"
  starttestjson "$id_3_17" "$desc_3_17"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_17"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_17"
      warn "      * 错误的所有权设置 $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_17"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.18
check_3_18() {
  id_3_18="3.18"
  desc_3_18="设置daemon.json文件权限为644或更多限制性 (计入评分)"
  check_3_18="$id_3_18  - $desc_3_18"
  starttestjson "$id_3_18" "$desc_3_18"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 644 ] || [  "$(stat -c %a $file)" -eq 640 ] || [ "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_18"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_18"
      warn "      * 错误的文件权限设置 $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_18"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.19
check_3_19() {
  id_3_19="3.19"
  desc_3_19="设置/etc/default/docker文件所有权为 root:root (计入评分)"
  check_3_19="$id_3_19  - $desc_3_19"
  starttestjson "$id_3_19" "$desc_3_19"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_19"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_19"
      warn "      * 错误的所有权设置 $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_19"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.20
check_3_20() {
  id_3_20="3.20"
  desc_3_20="设置/etc/default/docker文件权限为644或更多限制性 root:root (计入评分)"
  check_3_20="$id_3_20  - $desc_3_20"
  starttestjson "$id_3_20" "$desc_3_20"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_20"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_20"
      warn "      * 错误的所有权设置 $file"
      resulttestjson "警告" "错误的所有权设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_20"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.21
check_3_21() {
  id_3_21="3.21"
  desc_3_21="设置/etc/sysconfig/docker的文件权限为644或更多的限制性 (计入评分)"
  check_3_21="$id_3_21  - $desc_3_21"
  starttestjson "$id_3_21" "$desc_3_21"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 644 ] || [ "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_21"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_21"
      warn "      * 错误的文件权限设置 $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_21"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

# 3.22
check_3_22() {
  id_3_22="3.22"
  desc_3_22="设置/etc/default/docker的文件权限为644或更多的限制性 (计入评分)"
  check_3_22="$id_3_22  - $desc_3_22"
  starttestjson "$id_3_22" "$desc_3_22"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -eq 644 ] || [ "$(stat -c %a $file)" -eq 600 ]; then
      pass "$check_3_22"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_22"
      warn "      * 错误的文件权限设置 $file"
      resulttestjson "警告" "错误的文件权限设置 $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_22"
    info "      * 没有找到文件"
    resulttestjson "正常" "没有找到文件"
    currentScore=$((currentScore + 0))
  fi
}

check_3_end() {
  endsectionjson
}
