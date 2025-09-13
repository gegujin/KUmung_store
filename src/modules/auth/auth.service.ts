// src/modules/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ConfigService } from '@nestjs/config';
import { UserRole } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly cfg: ConfigService,
  ) {}

  /** 회원가입 + 액세스 토큰 발급 */
  async register(dto: RegisterDto) {
    const newUser = await this.users.create(dto); // SafeUser(id,email,role)
    const accessToken = await this.signToken(newUser.id, newUser.email, newUser.role);

    return {
      accessToken,
      user: {
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
        // SafeUser에 name이 없을 수 있으므로 dto에서 보존
        name: dto.name?.trim() ?? '',
      },
    };
  }

  /** 로그인 + 액세스 토큰 발급 */
  async login(dto: LoginDto) {
    // 해시 포함 원본 레코드(UserRecord)
    const user = await this.users.findByEmailWithHash(dto.email);
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');

    const accessToken = await this.signToken(user.id, user.email, user.role);

    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
      },
    };
  }

  /** JWT 서명(ISSUER/AUDIENCE 설정 시 자동 포함) */
  private async signToken(sub: string, email: string, role: UserRole): Promise<string> {
    const issuer = this.cfg.get<string>('JWT_ISSUER');
    const audience = this.cfg.get<string>('JWT_AUDIENCE');

    return this.jwt.signAsync(
      { sub, email, role },
      {
        ...(issuer ? { issuer } : {}),
        ...(audience ? { audience } : {}),
      },
    );
  }
}
