import type { UserRole } from '../../users/entities/user.entity';

export type SafeUser = {
  id: string;
  email: string;
  role: UserRole;  // ✅ 반드시 포함
};

// 호환용
export type JwtUser = SafeUser;
