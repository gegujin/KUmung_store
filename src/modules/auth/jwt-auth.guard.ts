// src/modules/auth/jwt-auth.guard.ts
import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from './decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    // @Public()면 인증 스킵
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;
    return super.canActivate(context);
  }

  // 표준 IAuthGuard 시그니처 유지 + 명확한 에러 메시지
  handleRequest<TUser = any>(
    err: any,
    user: any,
    info: any,
    _context: ExecutionContext,
    _status?: any,
  ): TUser {
    if (err) throw err;

    if (!user) {
      const name = info?.name ?? info?.constructor?.name;
      const reason =
        name === 'TokenExpiredError'
          ? 'Token expired'
          : name === 'JsonWebTokenError'
          ? 'Invalid token'
          : info?.message || 'Unauthorized';
      throw new UnauthorizedException(reason);
    }
    return user as TUser;
  }
}

/**
 * 선택 인증 가드:
 * - 토큰이 없거나 무효여도 에러를 던지지 않고 null 사용자로 통과
 * - 토큰이 유효하면 req.user 주입
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true; // 완전 공개 라우트는 패스
    return super.canActivate(context); // 있으면 파싱, 없으면 handleRequest에서 null
  }

  handleRequest<TUser = any>(
    err: any,
    user: any,
    _info: any,
    _context: ExecutionContext,
    _status?: any,
  ): TUser {
    if (err) return null as unknown as TUser; // 에러 삼킴
    return (user ?? null) as unknown as TUser;
  }
}
