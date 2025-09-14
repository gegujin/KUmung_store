import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { UserRole } from '../../users/entities/user.entity';

@Injectable()
export class OwnerGuard implements CanActivate {
  constructor(
    @InjectRepository(Product)
    private readonly products: Repository<Product>,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const user = req.user as { id: string; role?: UserRole } | undefined;
    const id = req.params?.id as string | undefined;

    if (!id) throw new ForbiddenException('Missing product id');

    const p = await this.products.findOne({
      where: { id },
      select: { id: true, ownerId: true },
    });
    if (!p) throw new NotFoundException('Product not found');

    if (!user) throw new ForbiddenException('Unauthorized');

    if (user.role === UserRole.ADMIN) return true; // 관리자 우회
    if (p.ownerId !== user.id) {
      throw new ForbiddenException('Only owner can modify/delete');
    }
    return true;
  }
}
