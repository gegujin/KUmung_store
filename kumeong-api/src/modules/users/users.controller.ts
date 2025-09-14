import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users') // 전역 prefix(/api/v1)는 main.ts에서 붙습니다
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // 간단 헬스 체크
  @Get('health')
  health() {
    return { ok: true };
  }
}
