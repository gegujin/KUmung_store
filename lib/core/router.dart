import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kumeong_store/features/auth/login_screen.dart';

// Screens
import '../features/home/home_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/product/product_edit_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_room_screen.dart';
import '../features/trade/trade_confirm_screen.dart';
import '../features/trade/payment_method_screen.dart';
import '../features/trade/secure_payment_screen.dart';
import '../features/delivery/ku_delivery_list_screen.dart';
import '../features/delivery/ku_delivery_alert_screen.dart';
import '../features/delivery/ku_delivery_detail_screen.dart';
import '../features/delivery/delivery_status_screen.dart';
//import '../features/settings/settings_screen.dart';
//import '../features/delivery/request_delivery_screen.dart';
//import '../features/mypage/mypage_screen.dart';

// Models
import '../models/post.dart';

// Services (예: DI로 주입받아도 됨)
/*
import '../features/auth/auth_service.dart';
import '../features/product/product_service.dart';
import '../features/chat/chat_service.dart';
*/

/// 결제 플로우에 필요한 인자
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

/// 외부에서 라우터를 만들 때 필요한 의존성 (아직 없는 파일은 주석처리)
/*
class AppRouter {
  final AuthService auth;
  final ProductService products;
  final ChatService chats;

  AppRouter({
    required this.auth,
    required this.products,
    required this.chats,
  });
*/
final GoRouter router = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: '/',
  /*
  refreshListenable: auth,
  redirect: (context, state) {
    final loggingIn = state.matchedLocation == '/login';
    final needAuth = _requiresAuth(state.matchedLocation);
    final loggedIn = auth.isLoggedIn;

    if (!loggedIn && needAuth && !loggingIn) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/login?return=$from';
    }
    if (loggedIn && loggingIn) {
      return '/';
    }
    return null;
  },
  */
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (_, __) => const LoginPage(),
    ),
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
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        return ProductEditScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/trade/confirm',
      name: 'tradeConfirm',
      builder: (context, state) {
        final qs = state.uri.queryParameters;
        final productId = qs['productId'];
        final roomId = qs['roomId'];
        return TradeConfirmScreen(
          productId: productId,
          roomId: roomId,
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

        return SecurePaymentScreen(
          roomId: roomId,
          productId: productId,
        );
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chatList',
      builder: (_, __) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:roomId',
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
    GoRoute(
      path: '/delivery/feed',
      name: 'deliveryFeed',
      builder: (_, __) =>
          const KuDeliveryFeedScreen(), // ku_delivery_list_screen.dart
    ),
    GoRoute(
      path: '/delivery/alerts',
      name: 'kuDeliveryAlerts',
      builder: (_, __) => const KuDeliveryAlertScreen(),
    ),
    GoRoute(
      name: KuDeliveryDetailScreen.routeName,
      path: '/delivery/detail',
      builder: (context, state) {
        final args = state.extra as KuDeliveryDetailArgs;
        return KuDeliveryDetailScreen(args: args);
      },
    ),
    GoRoute(
      path: '/delivery/status',
      name: 'delivery-status',
      builder: (context, state) {
        final args = state.extra as DeliveryStatusArgs;
        return DeliveryStatusScreen(args: args);
      },
    ),

    /*
    GoRoute(
      path: '/delivery/request',
      name: 'deliveryRequest',
      builder: (context, state) => const RequestDeliveryScreen(),
    ),
    GoRoute(
      path: '/mypage',
      name: 'mypage',
      builder: (_, __) => const MyPageScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),*/
    /*
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final ret = state.uri.queryParameters['return'];
        return LoginScreen(returnTo: ret);
      },
    ),
    */
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('라우팅 오류: ${state.error}')),
  ),
);

/*
  bool _requiresAuth(String path) {
    const protected = [
      '/product/edit',
      '/trade',
      '/trade/confirm',
      '/trade/payment',
      '/pay',
      '/chat',
      '/delivery',
      '/mypage',
    ];
    return protected.any((p) => path.startsWith(p));
  }
}
*/
