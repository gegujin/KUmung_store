import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
/** 가드가 적용돼 있어도 이 데코레이터가 있으면 인증을 건너뜀 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
