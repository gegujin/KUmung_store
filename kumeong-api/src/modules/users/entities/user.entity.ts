// // src/modules/users/entities/user.entity.ts
// import {
//   Entity,
//   PrimaryGeneratedColumn,
//   Column,
//   OneToMany,
//   CreateDateColumn,
//   UpdateDateColumn,
//   Unique,
//   BeforeInsert,
//   BeforeUpdate,
//   Index,
// } from 'typeorm';
// import { Product } from '../../products/entities/product.entity';

// export enum UserRole {
//   USER = 'USER',
//   ADMIN = 'ADMIN',
// }

// @Entity('users')
// @Unique(['email'])
// export class User {
//   @PrimaryGeneratedColumn('uuid')
//   id: string;

//   // 이메일: 유니크 + 소문자 정규화 훅 적용
//   @Column({ length: 120 })
//   email: string;

//   @Column({ length: 100 })
//   name: string;

//   // bcrypt 해시는 일반적으로 60자
//   @Column({ type: 'varchar', length: 60, select: false })
//   passwordHash: string;

//   // ✅ SQLite 호환: enum → simple-enum
//   @Column({
//     type: 'simple-enum',
//     enum: UserRole,
//     default: UserRole.USER,
//   })
//   role: UserRole;

//   // Product 역방향 관계
//   @OneToMany(() => Product, (p) => p.owner)
//   products: Product[];

//   @Index('idx_users_created_at')
//   @CreateDateColumn()
//   createdAt: Date;

//   @UpdateDateColumn()
//   updatedAt: Date;

//   // ===== Normalize hooks =====
//   @BeforeInsert()
//   @BeforeUpdate()
//   normalizeFields() {
//     if (this.email) this.email = this.email.trim().toLowerCase();
//     if (!this.role) this.role = UserRole.USER;
//   }
// }

import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';
import { Product } from '../../products/entities/product.entity';

export enum UserRole {
  USER = 'USER',
  ADMIN = 'ADMIN',
}

@Entity('users')
@Unique(['email'])
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 120 })
  email: string;

  @Column({ length: 100 })
  name: string;

  @Column({ select: false })
  passwordHash: string;

  @Column({ type: 'simple-enum', enum: UserRole, default: UserRole.USER })
  role: UserRole;

  @OneToMany(() => Product, (p) => p.owner, { cascade: false })
  products: Product[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
