#!/bin/sh

check_5() {
  logit "\n"
  id_5="5"
  desc_5="容器运行时保护"
  check_5="$id_5 - $desc_5"
  info "$check_5"
  startsectionjson "$id_5" "$desc_5"
}

check_running_containers() {
  # If containers is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "  * 没有运行中的容器, 跳过第 5 部分"
    running_containers=0
  else
    running_containers=1
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
  fi
}

# 5.1
check_5_1() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_1="5.1"
  desc_5_1="启用 AppArmor 配置文件 (计入评分)"
  check_5_1="$id_5_1  - $desc_5_1"
  starttestjson "$id_5_1" "$desc_5_1"

  infojson "suggest" "如果AppArmor适用于你的Linux操作系统，可能需要遵循以下步骤：1.验证是否安装了AppArmor。 如果没有，请安装。2.为Docker容器创建或导入AppArmor配置文件。3.将此配置文件置于强制模式。4.使用自定义的AppArmor配置文件启动Docker容器。 例如，docker run --interactive --tty --security-opt =“apparmor：PROFILENAME”centos/bin/bash或者，可以保留Docker的默认apparmor配置文件。"
  infojson "notice" "AppArmor配置文件中定义的一组操作限制。 如果配置错误，容器可能无法完成工作。"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_apparmor_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'AppArmorProfile={{ .AppArmorProfile }}' "$c")

    if [ "$policy" = "AppArmorProfile=" ] || [ "$policy" = "AppArmorProfile=[]" ] || [ "$policy" = "AppArmorProfile=<no value>" ] || [ "$policy" = "AppArmorProfile=unconfined" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_1"
        warn "     * 没有发现 AppArmorProfile: $c"
	no_apparmor_containers="$no_apparmor_containers $c"
        fail=1
      else
        warn "     * 没有发现 AppArmorProfile: $c"
	no_apparmor_containers="$no_apparmor_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without AppArmor
  if [ $fail -eq 0 ]; then
      pass "$check_5_1"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "没有 AppArmorProfile 的容器" "$no_apparmor_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.2
check_5_2() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_2="5.2"
  desc_5_2="设置 SElinux 安全选项 (计入评分)"
  check_5_2="$id_5_2  - $desc_5_2"
  starttestjson "$id_5_2" "$desc_5_2"

  infojson "suggest" "如果SELinux适用于你的Linux操作系统，请使用它。 可能需要遵循以下步骤： 1.设置SELinux状态。 2.设置SELinux策略。 3.为Docker容器创建或导入SELinux策略模板。 4.启用SELinux的守护程序模式下启动Docker。 例如，docker daemon --selinux-enabled 5.使用安全选项启动Docker容器。 例如，docker run--interactive --tty --security-opt label = level：TopSecret centos/bin/bash。"
  infojson "notice" "selinux配置文件中定义的一组操作限制。 如果配置错误，容器可能无法完成工作。"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_securityoptions_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'SecurityOpt={{ .HostConfig.SecurityOpt }}' "$c")

    if [ "$policy" = "SecurityOpt=" ] || [ "$policy" = "SecurityOpt=[]" ] || [ "$policy" = "SecurityOpt=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_2"
        warn "     * 没有发现 SecurityOptions: $c"
	no_securityoptions_containers="$no_securityoptions_containers $c"
        fail=1
      else
        warn "     * 没有发现 SecurityOptions: $c"
	no_securityoptions_containers="$no_securityoptions_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without SELinux
  if [ $fail -eq 0 ]; then
      pass "$check_5_2"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "没有发现 SecurityOptions 的容器" "$no_securityoptions_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.3
check_5_3() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_3="5.3"
  desc_5_3="linux 内核功能在容器内受限 (计入评分)"
  check_5_3="$id_5_3  - $desc_5_3"
  starttestjson "$id_5_3" "$desc_5_3"

  infojson "suggest" "执行以下命令添加所需的功能： $> docker run --cap-add = {“Capability 1”，“Capability 2”} 例如，docker run --interactive --tty --cap-add = {“NET_ADMIN”，“SYS_ADMIN”} centos：latest /bin/bash 执行以下命令删除不需要的功能： $> docker run --cap-drop = {“能力1”，“能力2”} 例如，docker run --interactive --tty --cap-drop = {“SETUID”，“SETGID”} centos：latest /bin/bash 或者， 您可以选择删除所有功能并只添加所需功能： $> docker run --cap-drop = all --cap-add = {“Capability 1”，“Capability 2”} 例如，docker run --interactive --tty --cap-drop = all --cap-add = {“NET_ADMIN”，“SYS_ADMIN”} centos：latest /bin/bash。"
  infojson "notice" "基于添加或删除的Linux内核功能，容器中功能会受到限制。"

  totalChecks=$((totalChecks + 1))

  fail=0
  caps_containers=""
  for c in $containers; do
    container_caps=$(docker inspect --format 'CapAdd={{ .HostConfig.CapAdd}}' "$c")
    caps=$(echo "$container_caps" | tr "[:lower:]" "[:upper:]" | \
      sed 's/CAPADD/CapAdd/' | \
      sed -r "s/AUDIT_WRITE|CHOWN|DAC_OVERRIDE|FOWNER|FSETID|KILL|MKNOD|NET_BIND_SERVICE|NET_RAW|SETFCAP|SETGID|SETPCAP|SETUID|SYS_CHROOT|\s//g")

    if [ "$caps" != 'CapAdd=' ] && [ "$caps" != 'CapAdd=[]' ] && [ "$caps" != 'CapAdd=<no value>' ] && [ "$caps" != 'CapAdd=<nil>' ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_3"
        warn "     *   内核级功能: $caps 加到了 $c"
	caps_containers="$caps_containers $c"
        fail=1
      else
        warn "     *   内核级功能: $caps 加到了 $c "
	caps_containers="$caps_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with extra capabilities
  if [ $fail -eq 0 ]; then
      pass "$check_5_3"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "添加了内核级功能的容器" "$caps_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.4
check_5_4() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_4="5.4"
  desc_5_4="不使用特权容器 (计入评分)"
  check_5_4="$id_5_4  - $desc_5_4"
  starttestjson "$id_5_4" "$desc_5_4"

  infojson "suggest" "不要运行带有--privileged标志的容器。 例如，不要启动如下容器：docker run --interactive --tty --privileged centos/bin/bash。"
  infojson "notice" "除默认值之外的Linux内核功能将无法在容器内使用。"

  totalChecks=$((totalChecks + 1))

  fail=0
  privileged_containers=""
  for c in $containers; do
    privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$c")

    if [ "$privileged" = "true" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_4"
        warn "     * 运行在特权模式的容器: $c"
	privileged_containers="$privileged_containers $c"
        fail=1
      else
        warn "     * 运行在特权模式的容器: $c"
	privileged_containers="$privileged_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no privileged containers
  if [ $fail -eq 0 ]; then
      pass "$check_5_4"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "运行在特权模式的容器" "$privileged_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.5
check_5_5() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_5="5.5"
  desc_5_5="敏感的主机系统目录未挂载在容器上 (计入评分)"
  check_5_5="$id_5_5  - $desc_5_5"
  starttestjson "$id_5_5" "$desc_5_5"

  infojson "suggest" "不要将主机敏感目录挂载在容器上，尤其是在读写模式下。"

  totalChecks=$((totalChecks + 1))

  # List of sensitive directories to test for. Script uses new-lines as a separator.
  # Note the lack of identation. It needs it for the substring comparison.
  sensitive_dirs='/
/boot
/dev
/etc
/lib
/proc
/sys
/usr'
  fail=0
  sensitive_mount_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .VolumesRW }}' "$c" 2>/dev/null 1>&2; then
      volumes=$(docker inspect --format '{{ .VolumesRW }}' "$c")
    else
      volumes=$(docker inspect --format '{{ .Mounts }}' "$c")
    fi
    # Go over each directory in sensitive dir and see if they exist in the volumes
    for v in $sensitive_dirs; do
      sensitive=0
      if echo "$volumes" | grep -e "{.*\s$v\s.*true\s.*}" 2>/tmp/null 1>&2; then
        sensitive=1
      fi
      if [ $sensitive -eq 1 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_5"
          warn "     * 敏感目录 $v 被挂载到: $c"
	  sensitive_mount_containers="$sensitive_mount_containers $c:$v"
          fail=1
        else
          warn "     * 敏感目录 $v 被挂载到: $c"
	  sensitive_mount_containers="$sensitive_mount_containers $c:$v"
        fi
      fi
    done
  done
  # We went through all the containers and found none with sensitive mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_5"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "挂载敏感目录的容器" "$sensitive_mount_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.6
check_5_6() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_6="5.6"
  desc_5_6="sshd不在容器中运行 (计入评分)"
  check_5_6="$id_5_6  - $desc_5_6"
  starttestjson "$id_5_6" "$desc_5_6"

  infojson "suggest" "从容器中卸载SSH服务器，并使用nsenter或其他任何命令（如docker exec或docker attach）与容器实例进行交互。 docker exec --interactive --tty $ INSTANCE_ID sh OR docker attach $INSTANCE_ID。"

  totalChecks=$((totalChecks + 1))

  fail=0
  ssh_exec_containers=""
  printcheck=0
  for c in $containers; do

    processes=$(docker exec "$c" ps -el 2>/dev/null | grep -c sshd | awk '{print $1}')
    if [ "$processes" -ge 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_6"
        warn "     * 运行了sshd的容器: $c"
	ssh_exec_containers="$ssh_exec_containers $c"
        fail=1
        printcheck=1
      else
        warn "     * 运行了sshd的容器: $c"
	ssh_exec_containers="$ssh_exec_containers $c"
      fi
    fi

    exec_check=$(docker exec "$c" ps -el 2>/dev/null)
    if [ $? -eq 255 ]; then
        if [ $printcheck -eq 0 ]; then
          warn "$check_5_6"
          printcheck=1
        fi
      warn "     * Docker exec 命令执行失败: $c"
      ssh_exec_containers="$ssh_exec_containers $c"
      fail=1
    fi

  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
      pass "$check_5_6"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      #resulttestjson "警告" "Containers with sshd/docker exec failures" "$ssh_exec_containers"
      resulttestjson "警告" "sshd/docker exec执行失败的容器" "$ssh_exec_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.7
check_5_7() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_7="5.7"
  desc_5_7="特权端口禁止映射到容器内 (计入评分)"
  check_5_7="$id_5_7  - $desc_5_7"
  starttestjson "$id_5_7" "$desc_5_7"

  infojson "suggest" "启动容器时，不要将容器端口映射到特权主机端口。 另外，确保没有容器在Docker文件中特权端口映射声明。"

  totalChecks=$((totalChecks + 1))

  fail=0
  privileged_port_containers=""
  for c in $containers; do
    # Port format is private port -> ip: public port
    ports=$(docker port "$c" | awk '{print $0}' | cut -d ':' -f2)

    # iterate through port range (line delimited)
    for port in $ports; do
    if [ -n "$port" ] && [ "$port" -lt 1024 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_7"
          warn "     * 特权端口: $port 用在容器 $c"
	  privileged_port_containers="$privileged_port_containers $c:$port"
          fail=1
        else
          warn "     * 特权端口: $port 用在容器 $c"
	  privileged_port_containers="$privileged_port_containers $c:$port"
        fi
      fi
    done
  done
  # We went through all the containers and found no privileged ports
  if [ $fail -eq 0 ]; then
      pass "$check_5_7"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "使用特权端口的容器" "$privileged_port_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.8
check_5_8() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_8="5.8"
  desc_5_8="只映射必要的端口只映射必要的端口 (不计评分)"
  check_5_8="$id_5_8  - $desc_5_8"
  starttestjson "$id_5_8" "$desc_5_8"

  infojson "suggest" "修复容器镜像的Dockerfile，以便仅通过容器化应用程序公开所需的端口。 也可以通过在启动容器时不使用-P（UPPERCASE）或--publish-all标志来完全忽略Dockerfile中定义的端口列表。 使用-p（小写）或--publish标志来明确定义特定容器实例所需的端口。 例如，docker run --interactive --tty --publish 5000 - publish 5001 - publish 5002 centos/bin/bash。"

  totalChecks=$((totalChecks + 1))
  note "$check_5_8"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 5.9
check_5_9() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_9="5.9"
  desc_5_9="不共享主机的网络命名空间 (计入评分)"
  check_5_9="$id_5_9  - $desc_5_9"
  starttestjson "$id_5_9" "$desc_5_9"

  infojson "suggest" "启动容器时不要通过--net = host选项。"

  totalChecks=$((totalChecks + 1))

  fail=0
  net_host_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'NetworkMode={{ .HostConfig.NetworkMode }}' "$c")

    if [ "$mode" = "NetworkMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_9"
        warn "     * 运行在 host 网络模式的容器: $c"
	net_host_containers="$net_host_containers $c"
        fail=1
      else
        warn "     * 运行在 host 网络模式的容器: $c"
	net_host_containers="$net_host_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no Network Mode host
  if [ $fail -eq 0 ]; then
      pass "$check_5_9"
      resulttestjson "通过"
      currentScore=$((currentScore + 0))
  else
      resulttestjson "警告" "运行在 host 网络模式的容器" "$net_host_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.10
check_5_10() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_10="5.10"
  desc_5_10="确保容器的内存使用合理 (计入评分)"
  check_5_10="$id_5_10  - $desc_5_10"
  starttestjson "$id_5_10" "$desc_5_10"

  infojson "suggest" "建议使用--memory参数运行容器。 例如，可以运行一个容器如下： docker run --interactive --tty --memory 256m centos/bin/bash 在上面的示例中，容器启动时的内存限制为256 MB。 值得注意的是，如果存在内存限制，下面命令的输出将以科学计数形式返回值。 docker inspect --format ={{。Config.Memory}}7c5a2d4c7fe0 例如，如果上述容器实例的内存限制设置为256 MB，则上述命令的输出将为2.68435456e + 08而不是256m。 应该使用科学计算器或编程方法来转换此值。"
  infojson "notice" "如果您有设置适当的限制，容器可能将无法使用。"

  totalChecks=$((totalChecks + 1))

  fail=0
  mem_unlimited_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Config.Memory }}' "$c" 2> /dev/null 1>&2; then
      memory=$(docker inspect --format '{{ .Config.Memory }}' "$c")
    else
      memory=$(docker inspect --format '{{ .HostConfig.Memory }}' "$c")
    fi

    if [ "$memory" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_10"
        warn "     * 没有做内存限制的容器: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
        fail=1
      else
        warn "     * 没有做内存限制的容器: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_10"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "没有做内存限制的容器" "$mem_unlimited_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.11
check_5_11() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_11="5.11"
  desc_5_11="正确设置容器上的 CPU 优先级 (计入评分)"
  check_5_11="$id_5_11  - $desc_5_11"
  starttestjson "$id_5_11" "$desc_5_11"

  infojson "suggest" "管理容器之间的CPU份额。为此，请使用--cpu-shares参数启动容器。 例如，可以运行一个容器，如下所示： docker run --interactive --tty --cpu-shares 512 centos/bin/bash 在上面的示例中，容器以其他容器使用的50％的CPU份额启动。因此，如果另一个容器的CPU份额为80％，则此容器的CPU份额为40％。 注意：默认情况下，每个新容器将拥有1024个CPU份额。但是，如果运行审计部分中提到的命令，则此值显示为0。 或者使用如下方法： 1.进入/sys/fs/cgroup/cpu/system.slice/目录。 2.使用docker ps检查容器实例ID。 3.在上面的目录中（在步骤1中），将有一个名称为docker- <Instance ID> .scope的目录。例如，docker-4acae729e8659c6be696ee35b2237cc1fe4edd2672e9186434c5116e1a6fbed6.scope。进入此目录。 4.可以找到一个名为cpu.shares的文件。执行cat cpu.shares。可以看到CPU的份额值。因此，在docker run命令中没有使用-c或--cpu-shares参数配置CPU共享，该文件的值为1024。 如果我们将一个容器的CPU份额设置为512，则与其他容器相比，它将获得一半的CPU时间。因此，以1024作为100％，然后快速计算数据以得出您应为各个CPU份额设置的数字。例如，如果您想设置50％，则使用512;如果您想设置25％，则使用256。"
  infojson "notice" "如果没有设置适当的CPU共享，容器进程可能会不能执行。 但主机上的CPU资源是空闲的，CPU共享不会对容器可能使用的CPU造成任何限制。"

  totalChecks=$((totalChecks + 1))

  fail=0
  cpu_unlimited_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Config.CpuShares }}' "$c" 2> /dev/null 1>&2; then
      shares=$(docker inspect --format '{{ .Config.CpuShares }}' "$c")
    else
      shares=$(docker inspect --format '{{ .HostConfig.CpuShares }}' "$c")
    fi

    if [ "$shares" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_11"
        warn "     * 没有做CPU限制的容器: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
        fail=1
      else
        warn "     * 没有做CPU限制的容器: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_11"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "没有做CPU限制的容器" "$cpu_unlimited_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.12
check_5_12() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_12="5.12"
  desc_5_12="设置容器的根文件系统为只读 (计入评分)"
  check_5_12="$id_5_12  - $desc_5_12"
  starttestjson "$id_5_12" "$desc_5_12"

  infojson "suggest" "在容器的运行时添加一个只读标志以强制容器的根文件系统以只读方式装入。 docker run <Run arguments> - read-only <Container Image Name or ID> <Command> 在容器的运行时启用只读选项，包括但不限于如下： 1.使用--tmpfs选项为非持久数据写入临时文件系统。 docker run --interactive --tty --read-only --tmpfs"/run"--tmpfs"/tmp"centos/bin/bash 2.启用Docker rw在容器的运行时载入，以便将容器数据直接保存在Docker主机文件系统上。  docker run --interactive --tty --read-only -v /opt/app/data/run/app/data：rw centos/bin/bash 3.使用Docker共享存储卷插件来存储Docker数据卷以保留容器数据。 docker volume create -d convoy --opt o=size=20GB my-named-volume docker run --interactive --tty --read-only -v my-named-volume：/run/app/data centos/bin/bash 4.在容器运行期间，将容器数据传输到容器外部，以便保持容器数据。包括托管数据库，网络文件共享和API。"
  infojson "notice" "如果未定义数据写入策略，则在容器运行时启用--read-only可能会破坏某些容器软件包。 定义容器的数据应该在运行时保持不变，以确定要使用哪个建议过程。例： ·启用--tmpfs将临时文件写入到/tmp ·使用Docker共享数据卷进行持久数据写入"

  totalChecks=$((totalChecks + 1))

  fail=0
  fsroot_mount_containers=""
  for c in $containers; do
   read_status=$(docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' "$c")

    if [ "$read_status" = "false" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_12"
        warn "     * 根文件系统挂载为读写的容器: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
        fail=1
      else
        warn "     * 根文件系统挂载为读写的容器: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_12"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "根文件系统挂载为读写的容器" "$fsroot_mount_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.13
check_5_13() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_13="5.13"
  desc_5_13="确保进入容器的流量绑定到特定的主机接口 (计入评分)"
  check_5_13="$id_5_13  - $desc_5_13"
  starttestjson "$id_5_13" "$desc_5_13"

  infojson "suggest" "将容器端口绑定到所需主机端口上的特定主机接口。 例如，docker run--detach --publish 10.2.3.4:49153:80 nginx 在上面的示例中，容器端口80绑定到49153上的主机端口，并且仅接受来自10.2.3.4外部接口的传入连接。"

  totalChecks=$((totalChecks + 1))

  fail=0
  incoming_unbound_containers=""
  for c in $containers; do
    for ip in $(docker port "$c" | awk '{print $3}' | cut -d ':' -f1); do
      if [ "$ip" = "0.0.0.0" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_13"
          warn "     * 端口绑定到不做限定的IP: $c 中的 $ip"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
          fail=1
        else
          warn "     * 端口绑定到不做限定的IP: $c 中的 $ip"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
        fi
      fi
    done
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
      pass "$check_5_13"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "一些容器的端口绑定了不做限定的IP" "$incoming_unbound_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.14
check_5_14() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_14="5.14"
  desc_5_14="容器重启策略 on-failure 设置为 5  (计入评分)"
  check_5_14="$id_5_14  - $desc_5_14"
  starttestjson "$id_5_14" "$desc_5_14"

  infojson "suggest" "如果一个容器需要自己重新启动，可以如下设置： docker run --detach --restart = on-failure:5 nginx。"
  infojson "notice" "容器只会尝试重新启动5次。"

  totalChecks=$((totalChecks + 1))

  fail=0
  maxretry_unset_containers=""
  for c in $containers; do
    policy=$(docker inspect --format MaximumRetryCount='{{ .HostConfig.RestartPolicy.MaximumRetryCount }}' "$c")

    if [ "$policy" != "MaximumRetryCount=5" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_14"
        warn "     * 最大重试次数没有设置为 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
        fail=1
      else
        warn "     * 最大重试次数没有设置为 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
      fi
    fi
  done
  # We went through all the containers and they all had MaximumRetryCount=5
  if [ $fail -eq 0 ]; then
      pass "$check_5_14"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "最大重试次数没有设置为 5 的容器" "$maxretry_unset_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.15
check_5_15() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_15="5.15"
  desc_5_15="确保主机的进程命名空间不共享 (计入评分)"
  check_5_15="$id_5_15  - $desc_5_15"
  starttestjson "$id_5_15" "$desc_5_15"

  infojson "suggest" "不要使用'--pid = host'参数启动容器。 例如，不要启动一个容器，如下所示： docker run --interactive --tty --pid = host centos/bin/bash。"
  infojson "notice" "注意：容器进程无法看到主机系统上的进程。 在某些情况下，可能需要容器共享主机的进程命名空间。 例如，可以使用像strace或gdb这样的调试工具构建容器，在调试容器中的进程时要使用这些工具。 如必要，最好只能使用“-p”参数共享必须的主机进程。 例如，docker run --pid = host rhel7 strace -p 1234。"

  totalChecks=$((totalChecks + 1))

  fail=0
  pidns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'PidMode={{.HostConfig.PidMode }}' "$c")

    if [ "$mode" = "PidMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_15"
        warn "     * 主机PID命名空间被共享: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
        fail=1
      else
        warn "     * 主机PID命名空间被共享: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_15"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "一些容器的主机PID命名空间被共享" "$pidns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.16
check_5_16() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_16="5.16"
  desc_5_16="主机的 IPC 命令空间不共享 (计入评分)"
  check_5_16="$id_5_16  - $desc_5_16"
  starttestjson "$id_5_16" "$desc_5_16"

  infojson "suggest" "不要使用'--ipc = host'参数启动容器。 例如，不要启动如下容器：docker run --interactive --tty --ipc = host centos/bin/bash。"
  infojson "notice" "注意：共享内存段用于加速进程间通信。 它通常被高性能应用程序使用。 如果这些应用程序被容器化为多个容器，则可能需要共享容器的IPC名称空间以实现高性能。 在这种情况下，您仍然应该共享容器特定的IPC 命名空间而不是整个主机IPC命名空间。 可以将容器的IPC名称空间与另一个容器共享，如下所示： 例如，docker run --interactive --tty --ipc = container：e3a7a1a97c58 centos/bin/bash。"

  totalChecks=$((totalChecks + 1))

  fail=0
  ipcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'IpcMode={{.HostConfig.IpcMode }}' "$c")

    if [ "$mode" = "IpcMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_16"
        warn "     * 主机IPC命名空间被共享: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
        fail=1
      else
        warn "     * 主机IPC命名空间被共享: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_16"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "一些容器的主机IPC命名空间被共享" "$ipcns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.17
check_5_17() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_17="5.17"
  desc_5_17="主机设备不直接共享给容器 (不计评分)"
  check_5_17="$id_5_17  - $desc_5_17"
  starttestjson "$id_5_17" "$desc_5_17"

  infojson "suggest" "不要将主机设备直接共享于容器。 如果必须将主机设备共享给容器，请使用正确的一组权限： 例如，不要启动一个容器，如下所示： docker run --interactive --tty --device=/dev/tty0:/dev/tty0：rwm --device=/dev/temp_sda:/dev/temp_sda：rwm centos bash 例如，以正确的权限共享主机设备： docker run --interactive --tty --device=/dev/tty0:/dev/tty0：rw --device=/dev/temp_sda:/dev/temp_sda：r centos bash。"
  infojson "notice" "将无法直接在容器内使用主机设备。"

  totalChecks=$((totalChecks + 1))

  fail=0
  hostdev_exposed_containers=""
  for c in $containers; do
    devices=$(docker inspect --format 'Devices={{ .HostConfig.Devices }}' "$c")

    if [ "$devices" != "Devices=" ] && [ "$devices" != "Devices=[]" ] && [ "$devices" != "Devices=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_17"
        #info "     * Container has devices exposed directly: $c"
        info "     * 容器中有直接暴露的主机设备: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
        fail=1
      else
        #info "     * Container has devices exposed directly: $c"
        info "     * 容器中有直接暴露的主机设备: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
      pass "$check_5_17"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "信息" "容器中有直接暴露的主机设备" "$hostdev_exposed_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.18
check_5_18() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_18="5.18"
  desc_5_18="设置默认的 ulimit 配置（在需要时） (不计评分)"
  check_5_18="$id_5_18  - $desc_5_18"
  starttestjson "$id_5_18" "$desc_5_18"

  infojson "suggest" "如果需要，覆盖默认的ulimit设置。 例如，要覆盖默认的ulimit设置，请启动一个容器，如下所示： docker run --ulimit nofile = 1024：1024 --interactive --tty centos/bin/bash。"
  infojson "notice" "如果ulimits未正确设置，则可能无法实现所需的资源控制，甚至导致系统无法使用。"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_ulimit_containers=""
  for c in $containers; do
    ulimits=$(docker inspect --format 'Ulimits={{ .HostConfig.Ulimits }}' "$c")

    if [ "$ulimits" = "Ulimits=" ] || [ "$ulimits" = "Ulimits=[]" ] || [ "$ulimits" = "Ulimits=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_18"
        info "     * 容器没有设置ulimit默认值: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
        fail=1
      else
        info "     * 容器没有设置ulimit默认值: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
      pass "$check_5_18"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "信息" "容器没有设置ulimit默认值" "$no_ulimit_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.19
check_5_19() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_19="5.19"
  desc_5_19="设置装载传播模式不共享 (计入评分)"
  check_5_19="$id_5_19  - $desc_5_19"
  starttestjson "$id_5_19" "$desc_5_19"

  infojson "suggest" "不建议以共享模式传播中安装卷。 例如，不要启动容器，如下所示：docker run <Run arguments> --volume=/hostPath:/containerPath:shared <Container Image Name or ID> <Command>。。"

  totalChecks=$((totalChecks + 1))

  fail=0
  mountprop_shared_containers=""
  for c in $containers; do
    if docker inspect --format 'Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}' "$c" | \
     grep shared 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_19"
        warn "     * 装载传播模式设置了共享: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
        fail=1
      else
        warn "     * 装载传播模式设置了共享: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with shared propagation mode
  if [ $fail -eq 0 ]; then
      pass "$check_5_19"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
    resulttestjson "警告" "一些容器的装载传播模式设置了共享" "$mountprop_shared_containers"
    currentScore=$((currentScore - 1))
  fi
}

# 5.20
check_5_20() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_20="5.20"
  desc_5_20="设置主机的 UTS 命令空间不共享 (计入评分)"
  check_5_20="$id_5_20  - $desc_5_20"
  starttestjson "$id_5_20" "$desc_5_20"

  infojson "suggest" "不要使用--uts = host参数启动容器。 例如，不要启动如下容器：docker run --rm --interactive --tty --uts = host rhel7.2。"

  totalChecks=$((totalChecks + 1))

  fail=0
  utcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'UTSMode={{.HostConfig.UTSMode }}' "$c")

    if [ "$mode" = "UTSMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_20"
        warn "     * 主机的 UTS 命令空间被共享: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
        fail=1
      else
        warn "     * 主机的 UTS 命令空间被共享: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_20"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "一些容器的主机的 UTS 命令空间被共享" "$utcns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.21
check_5_21() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_21="5.21"
  desc_5_21="默认的 seccomp 配置文件未禁用 (计入评分)"
  check_5_21="$id_5_21  - $desc_5_21"
  starttestjson "$id_5_21" "$desc_5_21"

  infojson "suggest" "默认情况下，seccomp配置文件处于启用状态。除非您要修改和使用修改后的seccomp配置文件，否则您无需执行任何操作。"
  infojson "notice" "注意：在Docker 1.10及更高版本中，不管是否将-cap-add参数传递给容器，默认的seccomp配置文件都会阻止系统调用。在这种情况下，您应该创建自己的自定义seccomp配置文件。您还可以通过在docker run上传递--securityopt=seccomp:unconfined来禁用默认的seccomp配置文件。"

  totalChecks=$((totalChecks + 1))

  fail=0
  seccomp_disabled_containers=""
  for c in $containers; do
    if docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | \
      grep -E 'seccomp:unconfined|seccomp=unconfined' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_21"
        warn "     * 默认的 seccomp 配置文件设置了禁用: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
        fail=1
      else
        warn "     * 默认的 seccomp 配置文件设置了禁用: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with default secomp profile disabled
  if [ $fail -eq 0 ]; then
      pass "$check_5_21"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "这些容器的默认的 seccomp 配置文件设置了禁用" "$seccomp_disabled_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.22
check_5_22() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_22="5.22"
  desc_5_22="docker exec 命令不能使用特权选项n (计入评分)"
  check_5_22="$id_5_22  - $desc_5_22"
  starttestjson "$id_5_22" "$desc_5_22"

  infojson "suggest" "在docker exec命令中不要使用--privileged选项。"
  infojson "notice" "如果您需要容器内的增强功能，则只运行具有所需功能的容器。"

  totalChecks=$((totalChecks + 1))
  note "$check_5_22"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 5.23
check_5_23() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_23="5.23"
  desc_5_23="docker exec 命令不能与 uuser=root 选项一起使用 (不计评分)"
  check_5_23="$id_5_23  - $desc_5_23"
  starttestjson "$id_5_23" "$desc_5_23"

  infojson "suggest" "在docker exec命令中不要使用--user选项。"

  totalChecks=$((totalChecks + 1))
  note "$check_5_23"
  resulttestjson "提示"
  currentScore=$((currentScore + 0))
}

# 5.24
check_5_24() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_24="5.24"
  desc_5_24="确保 cgroug 安全使用 (计入评分)"
  check_5_24="$id_5_24  - $desc_5_24"
  starttestjson "$id_5_24" "$desc_5_24"

  infojson "suggest" "如无必须，不要使用 --cgroup-parent 选项在docker运行。"

  totalChecks=$((totalChecks + 1))

  fail=0
  unexpected_cgroup_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'CgroupParent={{.HostConfig.CgroupParent }}x' "$c")

    if [ "$mode" != "CgroupParent=x" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_24"
        warn "     * 确认 cgroug 安全使用: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
        fail=1
      else
        warn "     * 确认 cgroug 安全使用: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_24"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "这些容器使用了不安全的cgroug" "$unexpected_cgroup_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.25
check_5_25() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi
  id_5_25="5.25"
  desc_5_25="限制容器获得额外的权限 (计入评分)"
  check_5_25="$id_5_25  - $desc_5_25"
  starttestjson "$id_5_25" "$desc_5_25"

  infojson "suggest" "例如，应该按如下启动容器：docker run --rm -it --security-opt = no-new-privileges ubuntu bash。"
  infojson "notice" "no_new_priv会阻止像SELinux这样的LSM变为不允许访问当前进程的进程标签。"

  totalChecks=$((totalChecks + 1))

  fail=0
  addprivs_containers=""
  for c in $containers; do
    if ! docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | grep 'no-new-privileges' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_25"
        warn "     * 权限没有做限定: $c"
        addprivs_containers="$addprivs_containers $c"
        fail=1
      else
        warn "     * 权限没有做限定: $c"
        addprivs_containers="$addprivs_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with capability to acquire additional privileges
  if [ $fail -eq 0 ]; then
      pass "$check_5_25"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "这些容器的权限没有做限定" "$addprivs_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.26
check_5_26() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_26="5.26"
  desc_5_26="运行时检查容器健康状态 (计入评分)"
  check_5_26="$id_5_26  - $desc_5_26"
  starttestjson "$id_5_26" "$desc_5_26"

  infojson "suggest" "使用--health-cmd和其他参数运行容器。 例如，docker run -d --health-cmd ='stat /etc/passwd || exit1'nginx。"

  totalChecks=$((totalChecks + 1))

  fail=0
  nohealthcheck_containers=""
  for c in $containers; do
    if ! docker inspect --format '{{ .Id }}: Health={{ .State.Health.Status }}' "$c" 2>/dev/null 1>&2; then
      if [ $fail -eq 0 ]; then
        warn "$check_5_26"
        warn "     * 没有设置健康检查: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
        fail=1
      else
        warn "     * 没有设置健康检查: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
      pass "$check_5_26"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "这些容器没有设置健康检查" "$nohealthcheck_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.27
check_5_27() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_27="5.27"
  desc_5_27="确保 docker 命令始终获取最新版本的镜像 (不计评分)"
  check_5_27="$id_5_27  - $desc_5_27"
  starttestjson "$id_5_27" "$desc_5_27"

  infojson "suggest" "使用正确的版本锁定机制（默认情况下分配的最新标签仍然不完善），避免提取缓存的旧版本。 版本固定机制也应用于基本镜像，软件包和整个镜像。 可以根据要求定制版本固定规则。"

  totalChecks=$((totalChecks + 1))
  info "$check_5_27"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 5.28
check_5_28() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_28="5.28"
  desc_5_28="限制使用 PID cgroup (计入评分)"
  check_5_28="$id_5_28  - $desc_5_28"
  starttestjson "$id_5_28" "$desc_5_28"

  infojson "suggest" "在启动容器时，使用--pids-limit标志。例如，docker run -it -pids-limit 100 <Image_ID> 在上述示例中，允许在任何给定时间运行的进程数设置为100.在达到100个并发运行进程的限制之后，docker将限制任何新的进程创建。"
  infojson "notice" "根据需要设置PID限制值。 不正确的值可能会使容器不能使用。"

  totalChecks=$((totalChecks + 1))

  fail=0
  nopids_limit_containers=""
  for c in $containers; do
    pidslimit="$(docker inspect --format '{{.HostConfig.PidsLimit }}' "$c")"

    if [ "$pidslimit" = "0" ] || [  "$pidslimit" = "<nil>" ] || [  "$pidslimit" = "-1" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_28"
        warn "     * 没有设置PID限制: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
        fail=1
      else
        warn "     * 没有设置PID限制: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found all with PIDs limit
  if [ $fail -eq 0 ]; then
      pass "$check_5_28"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "这些容器没有设置PID限制" "$nopids_limit_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.29
check_5_29() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_29="5.29"
  desc_5_29="不要使用 docker 的默认网桥 docker0 (不计评分)"
  check_5_29="$id_5_29  - $desc_5_29"
  starttestjson "$id_5_29" "$desc_5_29"

  infojson "suggest" "遵循Docker文档并设置用户定义的网络。 运行定义的网络中的所有容器。"
  infojson "notice" "必须管理用户定义的网络。"

  totalChecks=$((totalChecks + 1))

  fail=0
  docker_network_containers=""
  networks=$(docker network ls -q 2>/dev/null)
  for net in $networks; do
    if docker network inspect --format '{{ .Options }}' "$net" 2>/dev/null | grep "com.docker.network.bridge.name:docker0" >/dev/null 2>&1; then
      docker0Containers=$(docker network inspect --format='{{ range $k, $v := .Containers }} {{ $k }} {{ end }}' "$net" | \
        sed -e 's/^ //' -e 's/  /\n/g' 2>/dev/null)

        if [ -n "$docker0Containers" ]; then
          if [ $fail -eq 0 ]; then
            info "$check_5_29"
            fail=1
          fi
          for c in $docker0Containers; do
            if [ -z "$exclude" ]; then
              cName=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | sed 's/\///g')
            else
              pattern=$(echo "$exclude" | sed 's/,/|/g')
              cName=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | sed 's/\///g' | grep -Ev "$pattern" )
            fi
            if [ -n "$cName" ]; then
              info "     * 在docker0网络中的容器: $cName"
              docker_network_containers="$docker_network_containers $c:$cName"
            fi
          done
        fi
      currentScore=$((currentScore + 0))
    fi
  done
  # We went through all the containers and found none in docker0 network
  if [ $fail -eq 0 ]; then
      pass "$check_5_29"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "信息" "使用了docker0网络的容器" "$docker_network_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.30
check_5_30() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_30="5.30"
  desc_5_30="不共享主机的用户命名空间 (计入评分)"
  check_5_30="$id_5_30  - $desc_5_30"
  starttestjson "$id_5_30" "$desc_5_30"

  infojson "suggest" "不要在主机和容器之间共享用户名称空间。 例如，不要像下面那样运行容器： docker run --rm -it --userns = host ubuntu bash。"

  totalChecks=$((totalChecks + 1))

  fail=0
  hostns_shared_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .HostConfig.UsernsMode }}' "$c" 2>/dev/null | grep -i 'host' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_30"
        warn "     * 共享了命名空间: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
        fail=1
      else
        warn "     * 共享了命名空间: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with host's user namespace shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_30"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "共享了用户命名空间的容器" "$hostns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.31
check_5_31() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_31="5.31"
  desc_5_31="任何容器内不能安装 docker 套接字 (计入评分)"
  check_5_31="$id_5_31  - $desc_5_31"
  starttestjson "$id_5_31" "$desc_5_31"

  infojson "suggest" "确保没有容器将docker.sock作为卷。"

  totalChecks=$((totalChecks + 1))

  fail=0
  docker_sock_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Mounts }}' "$c" 2>/dev/null | grep 'docker.sock' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_31"
        warn "     * Docker套接字被共享: $c"
        docker_sock_containers="$docker_sock_containers $c"
        fail=1
      else
        warn "     * Docker套接字被共享: $c"
        docker_sock_containers="$docker_sock_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with docker.sock shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_31"
      resulttestjson "通过"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "警告" "共享了Docker套接字的容器" "$docker_sock_containers"
      currentScore=$((currentScore - 1))
  fi
}

check_5_end() {
  endsectionjson
}
