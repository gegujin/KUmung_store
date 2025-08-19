import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/models/post.dart'; // demoProduct 사용
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 데모용 productId (연동 후엔 실제 목록에서 선택한 id 사용)
    final productId = (demoProduct.id.isNotEmpty) ? demoProduct.id : 'demo-product';
    final kux = Theme.of(context).extension<KuColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            const Text('홈 화면입니다.'),
            const SizedBox(height: 20),

            // ✅ 상품 상세 보기: /product/:productId
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  'productDetail',
                  pathParameters: {'productId': productId},
                  // 초기 렌더 최적화를 위해 extra로 데모 데이터 전달 (없어도 동작)
                  extra: demoProduct,
                );
              },
              child: const Text('상품 상세 보기'),
            ),

            const SizedBox(height: 10),

            // ✅ 상품 등록/수정: /product/edit/:productId
            // - 신규 작성 플로우가 따로 생기면 /product/new 같은 별도 라우트 추가 가능
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  'productEdit',
                  pathParameters: {'productId': productId}, // 신규면 'new' 등으로 사용 가능
                );
              },
              child: const Text('상품 등록 페이지'),
            ),Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () => context.pushNamed('deliveryFeed'),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kux.mintSoft, // 배경색 (부드러운 민트톤)
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'KU대리',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}