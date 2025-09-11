// lib/core/router/route_names.dart
class RouteNames {
  // ── 탭 루트
  static const home = 'home';
  static const chat = 'chat';
  static const favorites = 'favorites';
  static const mypage = 'mypage';

  // ── 인증(Auth) 관련
  static const login = 'login';
  static const schoolSignUp = 'schoolSignUp';
  static const idFind = 'idFind';
  static const passwordFind = 'passwordFind';

  // ── Home 하위
  static const productDetail = 'productDetail';
  static const productEdit = 'productEdit';
  static const categories = 'categories';
  static const alarms = 'alarms';
  @Deprecated('productDetail을 사용하세요')
  static const homeDetail = productDetail;

  // ── KU대리
  static const kuDeliverySignup = 'kuDeliverySignup';
  static const deliveryStatus = 'delivery-status';
  static const kuDeliveryFeed   = 'kuDeliveryFeed';
  static const kuDeliveryDetail = 'kuDeliveryDetail';
  static const kuDeliveryAlerts = 'kuDeliveryAlerts';

  // ── Chat
  static const chatRoom = 'chatRoom';
  static const chatRoomOverlay = 'chatRoomOverlay';

  // ── MyPage 하위
  static const points = 'points';
  static const buyHistory = 'buyHistory';
  static const sellHistory = 'sellHistory';
  static const recentPosts = 'recentPosts';
  static const friends = 'friends';

  // ── 거래/결제 플로우
  static const tradeConfirm = 'tradeConfirm';
  static const paymentMethod = 'paymentMethod';
  static const securePay = 'securePay';
}
