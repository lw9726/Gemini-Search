import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, "../.env");


export function setupEnvironment() {
  // 如果已经有环境变量,就直接使用
  if (process.env.GOOGLE_API_KEY) {
    return {
      GOOGLE_API_KEY: process.env.GOOGLE_API_KEY,
      NODE_ENV: process.env.NODE_ENV || "development",
    };
  }

  // 否则尝试加载 .env 文件
  const result = dotenv.config({ path: envPath });
  if (result.error) {
    throw new Error(
      `Failed to load .env file from ${envPath}: ${result.error.message}`
    );
  }
  
  // 再次检查是否成功获取到需要的环境变量
  if (!process.env.GOOGLE_API_KEY) {
    throw new Error(
      "GOOGLE_API_KEY environment variable must be set either in environment or in .env file"
    );
  }

  return {
    GOOGLE_API_KEY: process.env.GOOGLE_API_KEY,
    NODE_ENV: process.env.NODE_ENV || "development",
  };
}
