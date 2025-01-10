# 使用 Node.js 18 作为基础镜像
FROM node:18-slim as builder

# 设置工作目录
WORKDIR /app

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 复制项目文件
# 注意：在 GitHub Actions 中，代码已经被检出，所以直接复制而不是 git clone
COPY . .

# 创建 .env 文件
RUN echo "GOOGLE_API_KEY=placeholder" > .env && \
    echo "NODE_ENV=production" >> .env && \
    echo "PORT=7860" >> .env

# 安装依赖
RUN npm install

# 安装 esbuild
RUN npm install esbuild --save-dev

# 构建应用
RUN npm run build

# 第二阶段：创建生产镜像
FROM node:18-slim

WORKDIR /app

# 复制构建产物和必要文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.env ./

# 只安装生产依赖
RUN npm ci --only=production

# 创建启动脚本
RUN echo '#!/bin/sh\n\
sed -i "s/GOOGLE_API_KEY=.*/GOOGLE_API_KEY=$GOOGLE_API_KEY/" /app/.env\n\
exec npm run start' > /app/start.sh && \
    chmod +x /app/start.sh

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=7860

# 设置用户
RUN chown -R node:node /app
USER node

# 暴露端口
EXPOSE 7860

# 启动应用
CMD ["/app/start.sh"]
