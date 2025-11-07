FROM nvcr.io/nvidia/tritonserver:25.03-trtllm-python-py3

ENV DEBIAN_FRONTEND=noninteractive \
    CODE_SERVER_PORT=8080 \
    CODE_SERVER_PASSWORD="password" \
    HOME=/home/coder

# 安装必要工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates sudo wget gnupg git locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# 创建 coder 用户
RUN useradd -m -s /bin/bash coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

# 安装 code-server（使用官方安装脚本）
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 复制入口脚本并设置权限
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/opt/entrypoint.sh"]
# 默认命令：如果用户没有提供其它命令，将尝试以最常见的模型库路径启动 tritonserver
CMD ["tritonserver", "--model-repository=/models"]
