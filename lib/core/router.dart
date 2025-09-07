import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import 'package:kumeong_store/features/auth/login_screen.dart';

// 탭 루트
import 'package:kumeong_store/features/home/home_screen.dart';            // name: 'home'
import 'package:kumeong_store/features/chat/chat_list_screen.dart';       // name: 'chatList'
import 'package:kumeong_store/features/mypage/heart_screen.dart';         // name: 'favorites'
import 'package:kumeong_store/features/mypage/mypage_screen.dart';        // name: 'mypage'

// 마이페이지 서브
import 'package:kumeong_store/features/friend/friend_screen.dart';
import 'package:kumeong_store/features/mypage/recent_post_screen.dart';
import 'package:kumeong_store/features/mypage/sell_screen.dart';
import 'package:kumeong_store/features/mypage/buy_screen.dart';

// 기타 단독 화면들
import 'package:kumeong_store/features/product/product_detail_screen.dart';
import 'package:kumeong_store/features/product/product_edit_screen.dart';
import 'package:kumeong_store/features/chat/chat_room_screen.dart';
import 'package:kumeong_store/features/trade/trade_confirm_screen.dart';
import 'package:kumeong_store/features/trade/payment_method_screen.dart';
import 'package:kumeong_store/features/trade/secure_payment_screen.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_list_screen.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_alert_screen.dart';
import 'package:kumeong_store/features/delivery/ku_delivery_detail_screen.dart';
import 'package:kumeong_store/features/delivery/delivery_status_screen.dart';

// Models
import 'package:kumeong_store/models/post.dart';

class SecurePayArgs {
  final String roomId;
  final String productId;
  final String productTitle;
  final int price;
  final String partnerName;
  final String? imageUrl;
  final String? categoryTop;
  final String? categorySub;
  final int availablePoints;
  final int availableMoney;
  final String defaultAddress;

  const SecurePayArgs({
    required this.roomId,
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.partnerName,
    this.imageUrl,
    this.categoryTop,
    this.categorySub,
    this.availablePoints = 0,
    this.availableMoney = 0,
    this.defaultAddress = '서울특별시 성동구 왕십리로 00, 101동 1001호',
  });
}

final GoRouter router = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: '/',
  routes: [
    // ───────── Auth
    GoRoute(
      path: '/',
      name: 'login',
      builder: (_, __) => const LoginPage(),
    ),

    // ───────── 탭 루트: 홈
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (_, __) => const HomePage(),
      // (홈 서브가 나중에 생기면 여기에 중첩 GoRoute로 추가)
    ),

    // ───────── 탭 루트: 채팅
    GoRoute(
      path: '/chat',
      name: 'chatList',
      builder: (_, __) => const ChatListScreen(),
      routes: [
        GoRoute(
          path: ':roomId',
          name: 'chatRoom',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId']!;
            final extras = state.extra as Map? ?? {};
            return ChatScreen(
              partnerName: extras['partnerName'] as String? ?? '거래자',
              roomId: roomId,
              isKuDelivery: extras['isKuDelivery'] as bool? ?? false,
              securePaid: extras['securePaid'] as bool? ?? false,
            );
          },
        ),
      ],
    ),

    // ───────── 탭 루트: 관심
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (_, __) => const HeartPage(),
    ),

    // ───────── 탭 루트: 마이
    GoRoute(
      path: '/mypage',
      name: 'mypage',
      builder: (_, __) => const MyPage(),
      routes: [
        GoRoute(
          path: 'friends',
          name: 'friends',
          builder: (_, __) => const FriendsPage(),
        ),
        GoRoute(
          path: 'recent',
          name: 'recentPosts',
          builder: (_, __) => const RecentPostPage(),
        ),
        GoRoute(
          path: 'sell',
          name: 'sellHistory',
          builder: (_, __) => const SellPage(),
        ),
        GoRoute(
          path: 'buy',
          name: 'buyHistory',
          builder: (_, __) => const BuyPage(),
        ),
      ],
    ),

    // ───────── 기타 단독 라우트들
    GoRoute(
      path: '/product/:productId',
      name: 'productDetail',
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        final extraProduct =
            state.extra is Product ? state.extra as Product : null;
        return ProductDetailScreen(
          productId: productId,
          initialProduct: extraProduct,
        );
      },
    ),
    GoRoute(
      path: '/product/edit/:productId',
      name: 'productEdit',
      builder: (context, state) =>
          ProductEditScreen(productId: state.pathParameters['productId']!),
    ),
    GoRoute(
      path: '/trade/confirm',
      name: 'tradeConfirm',
      builder: (context, state) {
        final qs = state.uri.queryParameters;
        return TradeConfirmScreen(
          productId: qs['productId'],
          roomId: qs['roomId'],
        );
      },
    ),
    GoRoute(
      path: '/trade/payment',
      name: 'paymentMethod',
      builder: (context, state) {
        final isDelivery = state.uri.queryParameters['delivery'] == 'true';
        String roomId = state.uri.queryParameters['roomId'] ?? 'room-demo';
        String? productId = state.uri.queryParameters['productId'];
        String? partnerName;
        String? productTitle;
        int price = 0;
        String? imageUrl;
        String? categoryTop;

        int _toInt(Object? v) =>
            (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

        final x = state.extra;
        if (x is Map) {
          final m = Map<String, Object?>.from(x);
          roomId = (m['roomId'] as String?) ?? roomId;
          productId = m['productId'] as String? ?? productId;
          partnerName = m['partnerName'] as String?;
          productTitle = m['productTitle'] as String?;
          price = _toInt(m['price']);
          imageUrl = m['imageUrl'] as String?;
          categoryTop = m['categoryTop'] as String?;
        }

        return PaymentMethodScreen(
          roomId: roomId,
          isDelivery: isDelivery,
          productId: productId,
          partnerName: partnerName,
          productTitle: productTitle,
          price: price,
          imageUrl: imageUrl,
          categoryTop: categoryTop,
        );
      },
    ),
    GoRoute(
      path: '/pay/secure/:roomId/:productId',
      name: 'securePay',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        final productId = state.pathParameters['productId']!;
        final x = state.extra;
        if (x is SecurePayArgs) {
          return SecurePaymentScreen(
            roomId: x.roomId,
            productId: x.productId,
            productTitle: x.productTitle,
            price: x.price,
            partnerName: x.partnerName,
            imageUrl: x.imageUrl,
            categoryTop: x.categoryTop,
            categorySub: x.categorySub,
            availablePoints: x.availablePoints,
            availableMoney: x.availableMoney,
            defaultAddress: x.defaultAddress,
          );
        }
        return SecurePaymentScreen(roomId: roomId, productId: productId);
      },
    ),
    GoRoute(
      path: '/delivery/feed',
      name: 'deliveryFeed',
      builder: (_, __) => const KuDeliveryFeedScreen(),
    ),
    GoRoute(
      path: '/delivery/alerts',
      name: 'kuDeliveryAlerts',
      builder: (_, __) => const KuDeliveryAlertScreen(),
    ),
    GoRoute(
      name: KuDeliveryDetailScreen.routeName,
      path: '/delivery/detail',
      builder: (context, state) =>
          KuDeliveryDetailScreen(args: state.extra as KuDeliveryDetailArgs),
    ),
    GoRoute(
      path: '/delivery/status',
      name: 'delivery-status',
      builder: (context, state) =>
          DeliveryStatusScreen(args: state.extra as DeliveryStatusArgs),
    ),
  ],
  errorBuilder: (_, state) =>
      Scaffold(body: Center(child: Text('라우팅 오류: ${state.error}'))),
);
