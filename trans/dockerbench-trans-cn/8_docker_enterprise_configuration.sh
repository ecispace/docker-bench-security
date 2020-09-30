#!/bin/sh

check_8() {
  logit "\n"
  id_8="8"
  desc_8="Docker 企业版配置"
  check_8="$id_8 - $desc_8"
  info "$check_8"
  startsectionjson "$id_8" "$desc_8"
}

check_product_license() {
  if docker version | grep -Eqi '^Server.*Community$|Version.*-ce$'; then
    info "  * 社区版引擎协议, 跳过第8部分"
    enterprise_license=0
  else
    enterprise_license=1
  fi
}

check_8_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1="8.1"
  desc_8_1="通用控制平面配置"
  check_8_1="$id_8_1 - $desc_8_1"
  info "$check_8_1"
}

# 8.1.1
check_8_1_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_1="8.1.1"
  desc_8_1_1="配置LDAP认证服务 (计入评分)"
  check_8_1_1="$id_8_1_1  - $desc_8_1_1"
  starttestjson "$id_8_1_1" "$desc_8_1_1"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_1"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.2
check_8_1_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_2="8.1.2"
  desc_8_1_2="使用外部证书 (计入评分)"
  check_8_1_2="$id_8_1_2  - $desc_8_1_2"
  starttestjson "$id_8_1_2" "$desc_8_1_2"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_2"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.3
check_8_1_3() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_3="8.1.3"
  desc_8_1_3="为没有授权的用户使用客户端证书包 (不计评分)"
  check_8_1_3="$id_8_1_3  - $desc_8_1_3"
  starttestjson "$id_8_1_3" "$desc_8_1_3"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_3"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.4
check_8_1_4() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_4="8.1.4"
  desc_8_1_4="配备适用于集群的RBAC策略 (不计评分)"
  check_8_1_4="$id_8_1_4  - $desc_8_1_4"
  starttestjson "$id_8_1_4" "$desc_8_1_4"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_4"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.5
check_8_1_5() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_5="8.1.5"
  #desc_8_1_5="Enable signed image enforcement (计入评分)"
  desc_8_1_5="启用签名镜像增强 (计入评分)"
  check_8_1_5="$id_8_1_5  - $desc_8_1_5"
  starttestjson "$id_8_1_5" "$desc_8_1_5"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_5"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.6
check_8_1_6() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_6="8.1.6"
  desc_8_1_6="设置每个用户的会话值为'3'或更低 (计入评分)"
  check_8_1_6="$id_8_1_6  - $desc_8_1_6"
  starttestjson "$id_8_1_6" "$desc_8_1_6"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_6"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

# 8.1.7
check_8_1_7() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_7="8.1.7"
  desc_8_1_7="设置 'Lifetime Minutes'值为15  , 'Renewal Threshold Minutes'值为0  (计入评分)"
  check_8_1_7="$id_8_1_7  - $desc_8_1_7"
  starttestjson "$id_8_1_7" "$desc_8_1_7"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_7"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

check_8_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  logit "\n"
  id_8_2="8.2"
  desc_8_2="Docker 可信任的仓库配置"
  check_8_2="$id_8_2 - $desc_8_2"
  info "$check_8_2"
}

check_8_2_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_2_1="8.2.1"
  desc_8_2_1="允许镜像漏洞扫描 (计入评分)"
  check_8_2_1="$id_8_2_1  - $desc_8_2_1"
  starttestjson "$id_8_2_1" "$desc_8_2_1"

  totalChecks=$((totalChecks + 1))
  note "$check_8_2_1"
  resulttestjson "信息"
  currentScore=$((currentScore + 0))
}

check_8_end() {
  endsectionjson
}
