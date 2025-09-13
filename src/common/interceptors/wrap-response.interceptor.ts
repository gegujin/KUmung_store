import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable, map } from 'rxjs';
import { SKIP_WRAP_KEY } from '../decorators/skip-wrap.decorator';

@Injectable()
export class WrapResponseInterceptor implements NestInterceptor {
  constructor(private readonly reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const skip = this.reflector.getAllAndOverride<boolean>(SKIP_WRAP_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (skip) return next.handle();

    return next.handle().pipe(
      map((data) => {
        // 이미 { ok: ... } 형태면 그대로 유지
        if (data && typeof data === 'object' && 'ok' in data) return data;
        return { ok: true, data };
      }),
    );
  }
}
