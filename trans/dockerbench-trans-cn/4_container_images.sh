#!/bin/sh

check_4() {
  logit "\n"
  id_4="4"
  desc_4="容器镜像和构建文件"
  check_4="$id_4 - $desc_4"
  info "$check_4"
  startsectionjson "$id_4" "$desc_4"
}

# 4.1
check_4_1() {
  id_4_1="4.1"
  desc_4_1="创建容器的用户 (计入评分)"
  check_4_1="$id_4_1  - $desc_4_1"
  starttestjson "$id_4_1" "$desc_4_1"

  totalChecks=$((totalChecks + 1))

  # If container_users is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "$check_4_1"
    info "     * 没有运行中的容器"
    resulttestjson "信息" "没有运行中的容器"
    currentScore=$((currentScore + 0))
  else
    # We have some containers running, set failure flag to 0. Check for Users.
    fail=0
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
    root_containers=""
    for c in $containers; do
      user=$(docker inspect --format 'User={{.Config.User}}' "$c")

      if [ "$user" = "User=0" ] || [ "$user" = "User=root" ] || [ "$user" = "User=" ] || [ "$user" = "User=[]" ] || [ "$user" = "User=<no value>" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_4_1"
          warn "     * 以root用户运行: $c"
	  root_containers="$root_containers $c"
          fail=1
        else
          warn "     * 以root用户运行: $c"
	  root_containers="$root_containers $c"
        fi
      fi
    done
    # We went through all the containers and found none running as root
    if [ $fail -eq 0 ]; then
        pass "$check_4_1"
        resulttestjson "通过"
        currentScore=$((currentScore + 1))
    else
        resulttestjson "警告" "以root用户运行" "$root_containers"
        currentScore=$((currentScore - 1))
    fi
  fi
  # Make the loop separator go back to space
  set +f; unset IFS
}

# 4.2
check_4_2() {
  id_4_2="4.2"
  desc_4_2="容器使用可信的基础镜像 (不计评分)"
  check_4_2="$id_4_2  - $desc_4_2"
  starttestjson "$id_4_2" "$desc_4_2"

  totalChecks=$((totalChecks + 1))
  note "$check_4_2"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 4.3
check_4_3() {
  id_4_3="4.3"
  desc_4_3="容器中不安装没有必要的软件包 (不计评分)"
  check_4_3="$id_4_3  - $desc_4_3"
  starttestjson "$id_4_3" "$desc_4_3"

  totalChecks=$((totalChecks + 1))
  note "$check_4_3"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 4.4
check_4_4() {
  id_4_4="4.4"
  desc_4_4="扫描镜像漏洞并且构建包含安全补丁的镜像 (不计评分)"
  check_4_4="$id_4_4  - $desc_4_4"
  starttestjson "$id_4_4" "$desc_4_4"

  totalChecks=$((totalChecks + 1))
  note "$check_4_4"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 4.5
check_4_5() {
  id_4_5="4.5"
  desc_4_5="启用 docker 内容信任 (计入评分)"
  check_4_5="$id_4_5  - $desc_4_5"
  starttestjson "$id_4_5" "$desc_4_5"

  totalChecks=$((totalChecks + 1))
  if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
    pass "$check_4_5"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    warn "$check_4_5"
    resulttestjson "警告"
    currentScore=$((currentScore - 1))
  fi
}

# 4.6
check_4_6() {
  id_4_6="4.6"
  desc_4_6="将 HEALTHCHECK 说明添加到容器镜像 (计入评分)"
  check_4_6="$id_4_6  - $desc_4_6"
  starttestjson "$id_4_6" "$desc_4_6"

  totalChecks=$((totalChecks + 1))
  fail=0
  no_health_images=""
  for img in $images; do
    if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        warn "$check_4_6"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        warn "     * 没有发现安全检查: $imgName"
	no_health_images="$no_health_images $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_6"
    resulttestjson "通过"
    currentScore=$((currentScore + 1))
  else
    resulttestjson "警告" "没有安全检查的镜像" "$no_health_images"
    currentScore=$((currentScore - 1))
  fi
}

# 4.7
check_4_7() {
  id_4_7="4.7"
  desc_4_7="不在 dockerfile 中单独使用更新命令 (不计评分)"
  check_4_7="$id_4_7  - $desc_4_7"
  starttestjson "$id_4_7" "$desc_4_7"

  totalChecks=$((totalChecks + 1))
  fail=0
  update_images=""
  for img in $images; do
    if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_7"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * 发现更新指令: $imgName"
	update_images="$update_images $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_7"
    resulttestjson "通过"
    currentScore=$((currentScore + 0))
  else
    resulttestjson "信息" "发现更新指令" "$update_images"
    currentScore=$((currentScore + 0))
  fi
}

# 4.8
check_4_8() {
  id_4_8="4.8"
  desc_4_8="镜像中删除 setuid 和 setgid 权限 (不计评分)"
  check_4_8="$id_4_8  - $desc_4_8"
  starttestjson "$id_4_8" "$desc_4_8"

  totalChecks=$((totalChecks + 1))
  note "$check_4_8"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 4.9
check_4_9() {
  id_4_9="4.9"
  desc_4_9="在 dockerfile 中使用 COPY 而不是 ADD  (不计评分)"
  check_4_9="$id_4_9  - $desc_4_9"
  starttestjson "$id_4_9" "$desc_4_9"

  totalChecks=$((totalChecks + 1))
  fail=0
  add_images=""
  for img in $images; do
    if docker history --format "{{ .CreatedBy }}" --no-trunc "$img" | \
      sed '$d' | grep -q 'ADD'; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_9"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * 在镜像历史中发现ADD: $imgName"
        add_images="$add_images $imgName"
      fi
      currentScore=$((currentScore + 0))
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_9"
    resulttestjson "通过"
    currentScore=$((currentScore + 0))
  else
    resulttestjson "信息" "使用了ADD的镜像" "$add_images"
  fi
}

# 4.10
check_4_10() {
  id_4_10="4.10"
  desc_4_10="涉密信息不存储在 Dockerfiles (不计评分)"
  check_4_10="$id_4_10  - $desc_4_10"
  starttestjson "$id_4_10" "$desc_4_10"

  totalChecks=$((totalChecks + 1))
  note "$check_4_10"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 4.11
check_4_11() {
  id_4_11="4.11"
  desc_4_11="仅安装已经验证的软件包 (不计评分)"
  check_4_11="$id_4_11  - $desc_4_11"
  starttestjson "$id_4_11" "$desc_4_11"

  totalChecks=$((totalChecks + 1))
  note "$check_4_11"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

check_4_end() {
  endsectionjson
}
