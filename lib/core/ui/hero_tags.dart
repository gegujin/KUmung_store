/// Hero 태그 헬퍼들(중복 방지용 네임스페이스 포함)
/// branch 예: 'home', 'chat', 'favorites', 'mypage'
String _ns(String branch) => 'ns:$branch';

/// 루트 화면의 FAB 전용 태그
String heroTagFab(String branch) => '${_ns(branch)}:fab';

/// 상품 이미지(리스트 <-> 상세) 태그
/// - productId: 동일 상품이면 반드시 동일 값 사용
/// - index: 동일 카드 내 다중 이미지가 있을 때 구분용
/// - branch: 탭/브랜치 구분(기본 'home')
String heroTagProductImg(
  String productId, {
  int index = 0,
  String branch = 'home',
}) =>
    '${_ns(branch)}:prd:$productId:img:$index';

/// 판매자 아바타 태그(여러 화면에서 쓰일 수 있으니 반드시 branch 지정 권장)
String heroTagSellerAvatar(
  String sellerId, {
  String branch = 'home',
}) =>
    '${_ns(branch)}:seller:$sellerId:avatar';
