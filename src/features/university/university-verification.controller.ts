// src/core/verify/code-store.service.ts
import { Injectable } from '@nestjs/common';
import { createHash } from 'crypto';

type Expiring = { value: string; expireAt: number };

@Injectable()
export class CodeStoreService {
  // email → codeHash (TTL)
  private codeMap = new Map<string, Expiring>();
  // email → cooldown flag (TTL)
  private cooldownMap = new Map<string, Expiring>();

  private now(): number {
    return Date.now();
  }
  private key(email: string): string {
    return email.trim().toLowerCase();
  }

  private setWithTtl(
    map: Map<string, Expiring>,
    key: string,
    value: string,
    ttlSec: number,
  ): void {
    map.set(key, { value, expireAt: this.now() + ttlSec * 1000 });
  }

  private getIfAlive(map: Map<string, Expiring>, key: string): string | null {
    const rec = map.get(key);
    if (!rec) return null;
    if (rec.expireAt < this.now()) {
      map.delete(key);
      return null;
    }
    return rec.value;
  }

  private del(map: Map<string, Expiring>, key: string): void {
    map.delete(key);
  }

  private hash(code: string): string {
    return createHash('sha256').update(code).digest('hex');
  }

  /** 인증 코드를 저장 (TTL 적용) */
  async set(email: string, code: string, ttlSec: number): Promise<void> {
    const hash = this.hash(code);
    this.setWithTtl(this.codeMap, this.key(email), hash, ttlSec);
  }

  /** 사용자가 입력한 코드가 유효한지 검사 (일회성: 성공 시 삭제) */
  async verify(email: string, code: string): Promise<boolean> {
    const saved = this.getIfAlive(this.codeMap, this.key(email));
    if (!saved) return false;
    const ok = this.hash(code) === saved;
    if (ok) this.del(this.codeMap, this.key(email)); // 성공 시 일회성 소비
    return ok;
  }

  /**
   * 쿨다운 토큰 획득(전송 허용 여부 판단).
   * - 아직 쿨다운 중이면 false
   * - 새로 쿨다운을 설정하고 true
   */
  async cooldown(email: string, cooldownSec: number): Promise<boolean> {
    const k = this.key(email);
    if (this.getIfAlive(this.cooldownMap, k)) return false; // 아직 쿨다운
    this.setWithTtl(this.cooldownMap, k, '1', cooldownSec);
    return true;
  }

  // (테스트 편의) 메모리 스토어 초기화
  /* istanbul ignore next */
  clearAllForTest?(): void {
    this.codeMap.clear();
    this.cooldownMap.clear();
  }

  sweep() {
    const now = this.now();
    for (const [k, v] of this.codeMap) if (v.expireAt < now) this.codeMap.delete(k);
    for (const [k, v] of this.cooldownMap) if (v.expireAt < now) this.cooldownMap.delete(k);
  }
}
