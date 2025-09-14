import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config({ path: process.env.NODE_ENV ? `.env.${process.env.NODE_ENV}` : '.env' });

const host = process.env.DB_HOST ?? '127.0.0.1';
const port = Number(process.env.DB_PORT ?? 3306);
const username = process.env.DB_USERNAME ?? process.env.DB_USER ?? 'root';
const password = process.env.DB_PASSWORD ?? process.env.DB_PASS ?? '';
const database = process.env.DB_DATABASE ?? process.env.DB_NAME ?? 'kumeong_db';

export const AppDataSource = new DataSource({
  type: 'mysql',
  host,
  port,
  username,
  password,
  database,
  charset: 'utf8mb4',
  entities: [__dirname + '/../modules/**/*.entity.{ts,js}'],
  migrations: [__dirname + '/migrations/*.{ts,js}'],
  synchronize: false, // ✅ 운영 안전: 마이그레이션만 사용
  logging: false,
});

export default AppDataSource;
