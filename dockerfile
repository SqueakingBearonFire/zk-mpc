# 1. 使用官方 Rust 镜像
FROM rust:1.72 as builder

# 2. 安装额外工具（如必要）
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. 设置工作目录并复制代码
WORKDIR /usr/src/zk-mpc

# 若希望从 git 仓库直接克隆（构建时自动拉取）
# 注意：若希望绑定本地代码，可在 docker run 时挂载
RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Yoii-Inc/zk-mpc . \
    && git submodule update --init --recursive

# 4. 编译项目（release）
RUN cargo build --release

# 5. 创建运行阶段的轻量镜像
FROM debian:bookworm-slim

# 安装必要运行时依赖
RUN apt-get update && apt-get install -y \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制编译好的二进制文件
COPY --from=builder /usr/src/zk-mpc/target/release/werewolf-cli ./werewolf-cli
COPY --from=builder /usr/src/zk-mpc/run_werewolf.zsh ./run_werewolf.zsh

# 保证 run_werewolf.zsh 可执行
RUN chmod +x run_werewolf.zsh

# 设置入口，可根据需要修改
CMD ["./run_werewolf.zsh", "init", "3"]
# 或者运行 werewolf-cli 示例：
# ENTRYPOINT ["./werewolf-cli"]
# 默认参数示例：
# CMD ["0", "./data/3"]

