// src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';

import { UsersModule } from '../users/users.module';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';

@Module({
  imports: [
    UsersModule,            // ✅ JwtStrategy가 UsersService 주입받으므로 필수
    ConfigModule,
    PassportModule.register({ defaultStrategy: 'jwt', session: false }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        secret: cfg.getOrThrow<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: cfg.get<string>('JWT_EXPIRES', '7d'),
          ...(cfg.get('JWT_ISSUER') ? { issuer: cfg.get('JWT_ISSUER') } : {}),
          ...(cfg.get('JWT_AUDIENCE') ? { audience: cfg.get('JWT_AUDIENCE') } : {}),
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [JwtModule, PassportModule], // 다른 모듈에서 JwtService/Passport 사용 가능
})
export class AuthModule {}
