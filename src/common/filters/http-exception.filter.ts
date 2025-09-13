import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse();
    const req = ctx.getRequest();

    const isHttp = exception instanceof HttpException;
    const status = isHttp
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    let message = 'Internal server error';
    let details: any = undefined;

    if (isHttp) {
      const body = exception.getResponse();
      if (typeof body === 'string') {
        message = body;
      } else if (body && typeof body === 'object') {
        const msg = (body as any).message;
        if (Array.isArray(msg)) {
          message = 'Validation failed';
          details = msg; // class-validator 에러 배열
        } else if (msg) {
          message = msg;
        } else if ((body as any).error) {
          message = (body as any).error;
        }
      }
    } else if (exception?.message) {
      message = exception.message;
    }

    res.status(status).json({
      ok: false,
      error: {
        code: status,
        message,
        details,
      },
      path: req.originalUrl || req.url,
      timestamp: new Date().toISOString(),
    });
  }
}
