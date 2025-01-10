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

# 设置生产环境
ENV NODE_ENV=production

# 安装所有依赖，包括开发依赖
RUN npm install
RUN npm install -g esbuild

# 复制源代码
COPY . .

# 构建应用
RUN npm run build || (echo "Build failed" && exit 1)

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
