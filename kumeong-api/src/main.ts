// src/main.ts
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { SuccessResponseInterceptor } from './common/interceptors/success-response.interceptor';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const cfg = app.get(ConfigService);

  // CORS
  const corsOrigin = cfg.get<string>('CORS_ORIGIN');
  app.enableCors({
    origin: corsOrigin ? corsOrigin.split(',').map((s) => s.trim()) : true,
    credentials: true,
  });

  // Prefix & Versioning
  const apiPrefix = cfg.get<string>('API_PREFIX') ?? '/api';
  const apiVersion = cfg.get<string>('API_VERSION') ?? '1';
  app.setGlobalPrefix(apiPrefix);
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: apiVersion });

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true }, // ✅ DTO 숫자/불리언 캐스팅
      forbidUnknownValues: false,
    }),
  );

  // ✅ Global Interceptor & Filter (응답/에러 표준화)
  app.useGlobalInterceptors(new SuccessResponseInterceptor());
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Swagger
  const swaggerConfig = new DocumentBuilder()
    .setTitle('KU멍가게 API')
    .setDescription('캠퍼스 중고거래/배달(KU대리) 백엔드 v1')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        in: 'header',
        name: 'Authorization',
        description: 'JWT access token',
      },
      'bearer',
    )
    .build();

  const swaggerDoc = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup(`${apiPrefix}/docs`, app, swaggerDoc, {
    swaggerOptions: { persistAuthorization: true },
    customSiteTitle: 'KU멍가게 API Docs',
  });

  // Listen
  const port = Number(cfg.get<string>('PORT') ?? 3000);
  await app.listen(port);

  const baseUrl = await app.getUrl();
  console.log(`🚀 ${baseUrl}${apiPrefix}/v${apiVersion}`);
  console.log(`📚 Swagger: ${baseUrl}${apiPrefix}/docs`);
}

bootstrap().catch((err) => {
  console.error(err);
  process.exit(1);
});
