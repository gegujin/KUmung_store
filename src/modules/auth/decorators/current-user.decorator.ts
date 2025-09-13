// src/modules/auth/decorators/current-user.decorator.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { SafeUser } from '../types/user.types';

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): SafeUser => {
    const req = ctx.switchToHttp().getRequest<{ user?: SafeUser }>();
    return req.user as SafeUser;
  },
);
