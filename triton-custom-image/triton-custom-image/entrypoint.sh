#!/bin/bash
set -e

# 启动 code-server（以 coder 用户）
CODE_PORT="${CODE_SERVER_PORT:-8080}"
CODE_PASS="${CODE_SERVER_PASSWORD:-password}"

mkdir -p /home/coder/.local/share/code-server
chown -R coder:coder /home/coder

# 以 coder 用户启动 code-server，设置密码环境变量
su - coder -c "env PASSWORD='${CODE_PASS}' code-server --bind-addr 0.0.0.0:${CODE_PORT} --auth password --user-data-dir /home/coder/.local/share/code-server &"

# 若传入命令则执行（例如镜像的 CMD），否则尝试直接执行 tritonserver 或进入阻塞
if [ "$#" -gt 0 ]; then
  exec "$@"
else
  if command -v tritonserver >/dev/null 2>&1; then
    exec tritonserver --model-repository=/models
  else
    echo "No command provided and tritonserver not found; keeping container alive."
    tail -f /dev/null
  fi
fi
