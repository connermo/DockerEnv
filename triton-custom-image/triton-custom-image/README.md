# tritonserver + code-server 自定义镜像

这个镜像基于 `nvcr.io/nvidia/tritonserver/25.03-trtllm-python-py3`，在容器内部安装并运行 code-server（在浏览器中提供 VS Code）。

默认配置
- code-server 端口：`8080`
- 默认密码：`password`（强烈建议在生产或公开网络中修改）
- Triton 默认模型库路径：`/models`（可通过运行容器时挂载变化）

快速构建与运行

持续集成（GitHub Actions）
---------------------------------

仓库包含一个用于自动构建并将镜像推送到 Docker Hub 的 GitHub Actions 工作流：`.github/workflows/docker-publish.yml`。

要启用自动构建并推送，请在仓库的 Settings → Secrets 中添加以下 Secrets：

- `DOCKERHUB_USERNAME`：你的 Docker Hub 用户名
- `DOCKERHUB_TOKEN`：Docker Hub 的访问令牌（建议使用 Access Token，而非密码）
- 可选：如果 GitHub Runner 需要从 `nvcr.io` 拉取基础镜像（某些 NVidia NGC 镜像为私有），请添加 `NVCR_USERNAME` 和 `NVCR_PASSWORD`（或相应的 NGC API Key）以允许在 workflow 中登录 `nvcr.io`。

工作流行为：
- 在 `main` 分支推送或手动触发时运行。
- 使用 `docker/build-push-action` 构建位于 `triton-custom-image/triton-custom-image` 的 Dockerfile，并把镜像推送到 `docker.io/${{ secrets.DOCKERHUB_USERNAME }}/triton-codeserver:latest` 以及带 `github.sha` 的标签。

注意：如果 `nvcr.io` 基础镜像需要认证，请确保证书已正确设置在 Secrets 中，否则构建会因为无法拉取基础镜像而失败。

示例：在设置好 Secrets 后，推送到 `main` 分支将自动触发构建并把镜像发布到 Docker Hub。

```bash
# 在仓库 triton-custom-image/triton-custom-image 目录下构建镜像
docker build -t triton-codeserver:local .

# 运行（示例：映射 code-server 端口，若需要 GPU 则加 --gpus all）
# 请根据需要映射 triton 的端口（如 8000/8001/8002）和挂载模型库目录

docker run --rm -it --gpus all -p 8080:8080 -p 8000:8000 triton-codeserver:local
```

环境变量
- `CODE_SERVER_PASSWORD`：设置 code-server 密码（默认 `password`）
- `CODE_SERVER_PORT`：code-server 监听端口（默认 `8080`）

安全提示
- 该示例在容器内启用了密码认证，但请通过反向代理（NGINX、Traefik）和 HTTPS 或在受控网络中使用。不要在公共网络上以默认密码运行。