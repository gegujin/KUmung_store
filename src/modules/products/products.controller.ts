// src/modules/products/products.controller.ts
import {
  Body,
  Controller,
  Get,
  Post,
  Param,
  Patch,
  Delete,
  UseGuards,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiUnauthorizedResponse,
  ApiTags,
} from '@nestjs/swagger';

import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { QueryProductDto } from './dto/query-product.dto';
import {
  OkItemProductDto,
  OkPageProductDto,
  DeleteResultDto,
} from './dto/product.responses';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { OwnerGuard } from './guards/owner.guard';
import { Public } from '../auth/decorators/public.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { SafeUser } from '../auth/types/user.types';

@ApiTags('Products')
@Controller({ path: 'products', version: '1' })
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  // 🔓 공개: 목록 (페이지네이션/정렬/검색)
  @Public()
  @Get()
  @ApiOkResponse({ type: OkPageProductDto, description: '상품 목록(페이지네이션)' })
  async findAll(@Query() query: QueryProductDto) {
    const { items, page, limit, total, pages } =
      await this.productsService.findAll(query);
    return { ok: true, data: { items, page, limit, total, pages } };
  }

  // 🔓 공개: 상세
  @Public()
  @Get(':id')
  @ApiOkResponse({ type: OkItemProductDto, description: '상품 상세' })
  @ApiNotFoundResponse({ description: 'Product not found' })
  async findOne(@Param('id', new ParseUUIDPipe({ version: '4' })) id: string) {
    const item = await this.productsService.findOne(id);
    return { ok: true, data: item };
  }

  // 🔐 보호: 생성 (로그인 필요) - ownerId는 토큰 사용자 id로 저장
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiCreatedResponse({ type: OkItemProductDto, description: '생성 성공' })
  @ApiUnauthorizedResponse({ description: 'Unauthorized' })
  async create(@Body() dto: CreateProductDto, @CurrentUser() u: SafeUser) {
    const created = await this.productsService.createWithOwner(dto, u.id);
    return { ok: true, data: created };
  }

  // 🔐 보호: 수정 (소유자만, ADMIN 우회)
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, OwnerGuard)
  @Patch(':id')
  @ApiOkResponse({ type: OkItemProductDto, description: '수정 성공' })
  @ApiNotFoundResponse({ description: 'Product not found' })
  @ApiUnauthorizedResponse({ description: 'Unauthorized' })
  @ApiForbiddenResponse({ description: 'Only owner can modify/delete' })
  async update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateProductDto,
  ) {
    const updated = await this.productsService.update(id, dto);
    return { ok: true, data: updated };
  }

  // 🔐 보호: 삭제 (소유자만, ADMIN 우회)
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, OwnerGuard)
  @Delete(':id')
  @ApiOkResponse({ type: DeleteResultDto, description: '삭제 성공' })
  @ApiNotFoundResponse({ description: 'Product not found' })
  @ApiUnauthorizedResponse({ description: 'Unauthorized' })
  @ApiForbiddenResponse({ description: 'Only owner can modify/delete' })
  async remove(@Param('id', new ParseUUIDPipe({ version: '4' })) id: string) {
    const res = await this.productsService.remove(id);
    return { deleted: true, id: res.id };
  }
}
