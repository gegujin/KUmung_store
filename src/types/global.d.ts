// src/types/global.d.ts
import type { UserRole } from '../modules/users/entities/user.entity';

declare global {
  namespace Express {
    interface User {
      id: string;
      email: string;
      role: UserRole; // ✅ 선택이 아니라 필수
    }
    interface Request {
      user?: User;
    }
  }
}
export {};
