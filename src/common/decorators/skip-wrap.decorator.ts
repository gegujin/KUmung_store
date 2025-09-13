import { SetMetadata } from '@nestjs/common';

export const SKIP_WRAP_KEY = 'skipWrap';
/** 이 데코레이터가 붙은 핸들러/컨트롤러는 응답 래핑을 건너뜁니다. */
export const SkipWrap = () => SetMetadata(SKIP_WRAP_KEY, true);
