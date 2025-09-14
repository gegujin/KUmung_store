// src/core/database/database.module.ts
import { Global, Module } from '@nestjs/common';
import { TypeOrmModule, TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { SnakeNamingStrategy } from 'typeorm-naming-strategies';

// ✅ 드라이버별 옵션 타입을 명시적으로 import
import { MysqlConnectionOptions } from 'typeorm/driver/mysql/MysqlConnectionOptions';
import { SqliteConnectionOptions } from 'typeorm/driver/sqlite/SqliteConnectionOptions';

@Global()
@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService): TypeOrmModuleOptions => {
        const kind = cfg.get<'mysql' | 'sqlite' | 'memory'>('DB_KIND', 'sqlite');
        const isProd = process.env.NODE_ENV === 'production';

        // 공통 옵션(읽기전용 배열/const 지양)
        const common = {
          autoLoadEntities: true,
          namingStrategy: new SnakeNamingStrategy(),
          synchronize: kind === 'mysql' ? false : true,
          migrationsRun: isProd,
          logging: !isProd,
          migrations: ['dist/migrations/*.js'],
        };

        if (kind === 'mysql') {
          const opts: MysqlConnectionOptions = {
            type: 'mysql',
            host: cfg.get<string>('DB_HOST')!,
            port: cfg.get<number>('DB_PORT') ?? 3306,
            username: cfg.get<string>('DB_USERNAME')!,
            // ✅ string | undefined 로 확정
            password: cfg.get<string>('DB_PASSWORD') ?? undefined,
            database: cfg.get<string>('DB_NAME')!,
            ...common,
          };
          return opts as TypeOrmModuleOptions;
        }

        if (kind === 'memory') {
          const opts: SqliteConnectionOptions = {
            type: 'sqlite',
            database: ':memory:',
            dropSchema: true,
            ...common,
          };
          return opts as TypeOrmModuleOptions;
        }

        // default: 파일 기반 sqlite
        const opts: SqliteConnectionOptions = {
          type: 'sqlite',
          database: cfg.get<string>('DB_SQLITE_PATH', 'data/kumeong.sqlite')!,
          ...common,
        };
        return opts as TypeOrmModuleOptions;
      },
    }),
  ],
  exports: [TypeOrmModule],
})
export class DatabaseModule {}
