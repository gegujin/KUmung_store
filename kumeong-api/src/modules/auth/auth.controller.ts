// src/modules/auth/auth.controller.ts
import { Body, Controller, Get, Post, UseGuards, HttpCode } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiTags,
  ApiBody,
  ApiOperation,
  ApiOkResponse,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';       // ✅ 경로 수정
import type { SafeUser } from './types/user.types';                       // ✅ 경로 수정
import { Public } from './decorators/public.decorator';

@ApiTags('Auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Post('register')
  @HttpCode(200) // Swagger 예시(200)와 실제 상태코드 일치
  @ApiOperation({ summary: '회원가입 + 액세스 토큰 발급' })
  @ApiBody({
    type: RegisterDto,
    examples: {
      sample: {
        summary: '예시',
        value: {
          email: 'student@kku.ac.kr',
          name: 'KKU Student',
          password: 'password1234',
        },
      },
    },
  })
  @ApiOkResponse({
    description: '가입 성공',
    schema: {
      example: {
        ok: true,
        data: {
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          user: {
            id: 'uuid',
            email: 'student@kku.ac.kr',
            name: 'KKU Student',
            role: 'USER', // ✅ role 포함
          },
        },
      },
    },
  })
  async register(@Body() dto: RegisterDto) {
    const result = await this.auth.register(dto);
    return { ok: true, data: result };
  }

  @Public()
  @Post('login')
  @HttpCode(200)
  @ApiOperation({ summary: '로그인 + 액세스 토큰 발급' })
  @ApiBody({
    type: LoginDto,
    examples: {
      sample: {
        summary: '예시',
        value: {
          email: 'student@kku.ac.kr',
          password: 'password1234',
        },
      },
    },
  })
  @ApiOkResponse({
    description: '로그인 성공',
    schema: {
      example: {
        ok: true,
        data: {
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          user: {
            id: 'uuid',
            email: 'student@kku.ac.kr',
            name: 'KKU Student',
            role: 'USER', // ✅ role 포함
          },
        },
      },
    },
  })
  @ApiUnauthorizedResponse({
    description: '잘못된 자격 증명',
    schema: {
      example: {
        ok: false,
        error: { code: 401, message: 'Invalid credentials' },
        path: '/api/v1/auth/login',
        timestamp: '2025-09-13T12:34:56.789Z',
      },
    },
  })
  async login(@Body() dto: LoginDto) {
    const result = await this.auth.login(dto);
    return { ok: true, data: result };
  }

  @Get('me')
  @ApiOperation({ summary: '현재 사용자 정보 조회 (JWT 필요)' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOkResponse({
    schema: {
      example: {
        ok: true,
        data: {
          user: {
            id: 'uuid',
            email: 'student@kku.ac.kr',
            role: 'USER', // ✅ role 포함
          },
        },
      },
    },
  })
  @ApiUnauthorizedResponse({
    description: 'JWT 누락/유효하지 않음',
  })
  me(@CurrentUser() user: SafeUser) {
    return { ok: true, data: { user } };
  }
}
