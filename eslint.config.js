"@"
// @ts-check
import tseslint from 'typescript-eslint';
import prettierPlugin from 'eslint-plugin-prettier';

export default [
  // 여기가 .eslintignore 대체
  { ignores: ['dist/**', 'node_modules/**', '**/*.spec.ts'] },

  // TypeScript 권장 규칙 (type-aware 아님)
  ...tseslint.configs.recommended,

  {
    plugins: { prettier: prettierPlugin },
    rules: {
      // Prettier 연동 + LF 고정
      'prettier/prettier': ['error', { endOfLine: 'lf' }],

      // 지금 단계에선 개발 편의상 완화
      '@typescript-eslint/no-floating-promises': ['error', { ignoreIIFE: true }],
      '@typescript-eslint/require-await': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-unsafe-argument': 'off'
    }
  }
];
"@ | Set-Content -Encoding utf8 eslint.config.js"
