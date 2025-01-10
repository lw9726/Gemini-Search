# 使用 Node.js 18 作为基础镜像
FROM --platform=linux/amd64 node:18-slim as builder

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 首先复制依赖文件
COPY package*.json ./

# 安装所有依赖
RUN npm install

# 确保安装构建工具
RUN npm install -g rollup esbuild

# 复制源代码
COPY . .

# 显示构建环境信息以便调试
RUN node --version && npm --version

# 列出已安装的依赖
RUN npm list

# 尝试构建，如果失败则输出更多信息
RUN npm run build --verbose || (echo "Build failed with detailed error" && npm list && exit 1)

# 第二阶段：创建生产镜像
FROM --platform=linux/amd64 node:18-slim
WORKDIR /app

# 复制构建产物和必要文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# 设置环境变量
ENV NODE_ENV=production \
    PORT=7860

# 设置用户
RUN chown -R node:node /app
USER node

# 暴露端口
EXPOSE 7860

# 启动应用
CMD ["node", "dist/index.js"]
