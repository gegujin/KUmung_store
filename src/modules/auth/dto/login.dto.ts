// src/modules/auth/dto/login.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength, MaxLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'student@kku.ac.kr' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'password1234', minLength: 8 })
  @IsString()
  @MinLength(8)
  @MaxLength(64)
  password!: string;
}
