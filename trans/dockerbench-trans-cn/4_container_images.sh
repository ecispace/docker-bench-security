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

  infojson "suggest" "确保容器镜像的Dockerfile包含以下指令：USER <用户名或ID> 其中用户名或ID是指可以在容器基础镜像中找到的用户。 如果在容器基础镜像中没有创建特定用户，则在USER指令之前添加useradd命令以添加特定用户。例如，在Dockerfile中创建用户：RUN useradd -d /home/username -m -s /bin/bash username USER username注意：如果镜像中有容器不需要的用户，请考虑删除它们。 删除这些用户后，提交镜像，然后生成新的容器实例以供使用。"

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

  infojson "suggest" "配置和使用Docker内容信任。检查Docker镜像历史记录以评估其在网络上运行的风险。扫描Docker镜像以查找其依赖关系中的漏洞。"

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

  infojson "suggest" "如果可能的话，考虑使用最小基本镜像而不是标准的Redhat/Centos/Debian镜像。 可以选择BusyBox和Alpine。这不仅可以将您的镜像大小从> 150Mb修剪至20 Mb左右，还可以使用更少的工具和路径来提升权限。"

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

  infojson "suggest" "按照以下步骤重新构建带有安全补丁的镜像：第1步：取出所有基本镜像（即给定一组Dockerfiles，提取在FROM指令中声明的所有镜像，并重新提取它们以检查更新/修补版本）第2步：强制重建每个镜像：docker build --no-cache第3步：使用更新的镜像重新启动所有容器。还可以在Dockerfile中使用ONBUILD指令来触发经常用作基本镜像的特定更新指令。"

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

  infojson "suggest" "要在bash shell中启用内容信任，请输入以下命令：export DOCKER_CONTENT_TRUST = 1或者，在配置文件中设置此环境变量，以便每次登录时启用内容信任。"
  infojson "notice" "在设置了DOCKER_CONTENT_TRUST的环境中，需要在处理镜像时遵循信任过程 - 构建，创建，拉取，推送和运行。 可以使用--disable-content-trust标志按照需要在标记镜像上运行单独的操作，一般用于测试目的，生成环境中应尽不要使用。"

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

  infojson "suggest" "按照Docker文档，并使用HEALTHCHECK指令重建容器镜像。"

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

  infojson "suggest" "在安装软件包时，请使用最新的固定版本软件包。或可以在docker构建过程中使用--no-cache标志，以避免使用缓存的层。"

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

  infojson "suggest" "只在需要可执行的文件上允许setuid和setgid权限。 可在构建时通过在Dockerfile中添加以下命令来删除这些权限，最好添加在Dockerfile的末尾：RUN find / -perm +6000-type f -exec chmod a-s {} -;|| true。"
  infojson "notice" "以上命令会导致依赖setuid或setgid权限（包括合法权限）的可执行文件无法执行，需要小心处理。"

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

  infojson "suggest" "在Dockerfiles中使用COPY指令。"
  infojson "notice" "可能需ADD指令提供的功能，例如从远程URL获取文件。"

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

  infojson "suggest" "不要在Dockerfiles中存储任何类型的涉密信息。"
  infojson "notice" "若必须使用，需要制定相应的措施。"

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

  infojson "suggest" "使用GPG密钥下载和验证您所选择的软件包或任何其他安全软件包分发机制。"

  totalChecks=$((totalChecks + 1))
  note "$check_4_11"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

check_4_end() {
  endsectionjson
}
