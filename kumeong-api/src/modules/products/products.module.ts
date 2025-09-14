// src/modules/products/products.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Product } from './entities/product.entity';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { OwnerGuard } from './guards/owner.guard';

@Module({
  imports: [TypeOrmModule.forFeature([Product])],
  controllers: [ProductsController],
  providers: [ProductsService, OwnerGuard],
  exports: [TypeOrmModule, ProductsService],
})
export class ProductsModule {}
