-- KU멍가게 (KUMeong Store) 데이터베이스 스키마 v2.2
-- MySQL 8.0+ / utf8mb4 / InnoDB / SRID 4326

/* =========================================================
 A) 깨끗한 재실행을 위한 드롭 (자식 → 부모 역순)
========================================================= */
SET FOREIGN_KEY_CHECKS = 0;

DROP EVENT     IF EXISTS ev_auto_confirm_orders;
DROP FUNCTION  IF EXISTS compute_delivery_fee;

DROP TABLE IF EXISTS
  notifications,
  penalties,
  reports,
  reviews,
  point_transactions,
  point_accounts,
  rider_earnings,
  delivery_requests,
  rider_profiles,
  wallet_transactions,
  wallet_accounts,
  chat_messages,
  chat_room_participants,
  chat_rooms,
  payments,
  orders,
  favorites,
  product_tags,
  product_images,
  products,
  tags,
  categories,
  friendships,
  email_verifications,
  users,
  school_domains,
  app_settings;

SET FOREIGN_KEY_CHECKS = 1;

/* =========================================================
 B) 데이터베이스
========================================================= */
CREATE DATABASE IF NOT EXISTS kumeong_store
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE kumeong_store;

/* =========================================================
 C) 전역 설정/상수
========================================================= */
CREATE TABLE app_settings (
  id            TINYINT UNSIGNED PRIMARY KEY CHECK (id = 1),
  delivery_fee_per_500m INT NOT NULL DEFAULT 200, -- 0.5km 당 200원
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 경고 없이 안정 삽입 (없으면 만들고, 있으면 그대로)
INSERT INTO app_settings (id)
VALUES (1)
ON DUPLICATE KEY UPDATE id = VALUES(id);

-- 학교 이메일 도메인 화이트리스트
CREATE TABLE school_domains (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  campus_code  VARCHAR(20) NOT NULL,
  domain       VARCHAR(120) NOT NULL,
  UNIQUE KEY uk_campus_domain (campus_code, domain)
) ENGINE=InnoDB;

/* =========================================================
 D) 사용자
========================================================= */
CREATE TABLE users (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(255) NOT NULL UNIQUE,
  email_verified TINYINT(1) NOT NULL DEFAULT 0,
  password_hash  VARCHAR(255) NULL,
  nickname       VARCHAR(40) NOT NULL,
  phone          VARCHAR(30) NULL,
  campus_code    VARCHAR(20) NULL,
  avatar_url     VARCHAR(500) NULL,
  role           ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
  trust_score    DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  rating_avg     DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  rating_count   INT NOT NULL DEFAULT 0,
  last_seen_at   DATETIME NULL,
  is_blocked     TINYINT(1) NOT NULL DEFAULT 0,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_users_campus (campus_code)
) ENGINE=InnoDB;

CREATE TABLE email_verifications (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  token       CHAR(64) NOT NULL,
  expires_at  DATETIME NOT NULL,
  verified_at DATETIME NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_emailv_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uk_emailv_token (token)
) ENGINE=InnoDB;

-- 친구/차단
CREATE TABLE friendships (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  from_user_id  BIGINT UNSIGNED NOT NULL,
  to_user_id    BIGINT UNSIGNED NOT NULL,
  status        ENUM('PENDING','ACCEPTED','BLOCKED') NOT NULL DEFAULT 'PENDING',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_friend_from FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_friend_to   FOREIGN KEY (to_user_id)   REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uk_friend_pair (from_user_id, to_user_id)
) ENGINE=InnoDB;

/* =========================================================
 E) 카테고리/태그
========================================================= */
CREATE TABLE categories (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  parent_id     BIGINT UNSIGNED NULL,
  sort_order    INT NOT NULL DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
  UNIQUE KEY uk_category_unique (name, parent_id)
) ENGINE=InnoDB;

CREATE TABLE tags (
  id    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name  VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

/* =========================================================
 F) 상품
========================================================= */
CREATE TABLE products (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seller_id       BIGINT UNSIGNED NOT NULL,
  title           VARCHAR(120) NOT NULL,
  price           INT NOT NULL CHECK (price >= 0),
  description     TEXT NULL,
  category_id     BIGINT UNSIGNED NULL,
  status          ENUM('ACTIVE','RESERVED','SOLD','HIDDEN') NOT NULL DEFAULT 'ACTIVE',
  likes_count     INT NOT NULL DEFAULT 0,
  views_count     INT NOT NULL DEFAULT 0,
  campus_code     VARCHAR(20) NULL,
  location_name   VARCHAR(120) NULL,
  meeting_point   POINT SRID 4326 NOT NULL,   -- ✅ 공간좌표 필수
  SPATIAL INDEX idx_product_meet (meeting_point),
  delivery_option ENUM('MEETUP','KUD','BOTH') NOT NULL DEFAULT 'BOTH',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME NULL,
  FULLTEXT KEY ft_products (title, description),
  CONSTRAINT fk_product_seller   FOREIGN KEY (seller_id)   REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  KEY idx_product_created  (created_at DESC),
  KEY idx_product_category (category_id, status, created_at DESC),
  KEY idx_product_campus   (campus_code, status, created_at DESC)
) ENGINE=InnoDB;

CREATE TABLE product_images (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  image_url  VARCHAR(500) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pimg_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  KEY idx_pimg_product (product_id, sort_order)
) ENGINE=InnoDB;

CREATE TABLE product_tags (
  product_id BIGINT UNSIGNED NOT NULL,
  tag_id     BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, tag_id),
  CONSTRAINT fk_ptag_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_ptag_tag     FOREIGN KEY (tag_id)     REFERENCES tags(id)     ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE favorites (
  user_id    BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_fav_user    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_fav_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

/* =========================================================
 G) 주문/결제
========================================================= */
CREATE TABLE orders (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id     BIGINT UNSIGNED NOT NULL,
  buyer_id       BIGINT UNSIGNED NOT NULL,
  seller_id      BIGINT UNSIGNED NOT NULL,
  status ENUM(
    'INIT','PENDING_PAYMENT','PAID','IN_DELIVERY',
    'MEETUP_SCHEDULED','COMPLETED','CANCELLED','DISPUTED'
  ) NOT NULL DEFAULT 'INIT',
  secure_pay     TINYINT(1) NOT NULL DEFAULT 0,
  is_delivery    TINYINT(1) NOT NULL DEFAULT 0,
  amount         INT NOT NULL,
  delivery_fee   INT NOT NULL DEFAULT 0,
  escrow_confirmed_at DATETIME NULL,
  auto_confirm_at    DATETIME NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
  CONSTRAINT fk_orders_buyer   FOREIGN KEY (buyer_id)   REFERENCES users(id)    ON DELETE RESTRICT,
  CONSTRAINT fk_orders_seller  FOREIGN KEY (seller_id)  REFERENCES users(id)    ON DELETE RESTRICT,
  KEY idx_orders_product (product_id, status, created_at DESC),
  KEY idx_orders_buyer   (buyer_id,  status, created_at DESC),
  KEY idx_orders_seller  (seller_id, status, created_at DESC),
  KEY idx_order_auto_confirm (auto_confirm_at)
) ENGINE=InnoDB;

CREATE TABLE payments (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id       BIGINT UNSIGNED NOT NULL,
  amount         INT NOT NULL,
  provider       VARCHAR(50) NULL,
  provider_tx_id VARCHAR(100) NULL,
  status         ENUM('PENDING','AUTHORIZED','CAPTURED','CANCELED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  requested_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at   DATETIME NULL,
  raw_payload    JSON NULL,
  CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  KEY idx_payment_status (status)
) ENGINE=InnoDB;

/* =========================================================
 H) 채팅 (chat_rooms → participants → messages)
========================================================= */
CREATE TABLE chat_rooms (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id  BIGINT UNSIGNED NULL,  -- 상품별 방 연결(선택)
  order_id    BIGINT UNSIGNED NULL,  -- 진행중 주문 연결(프런트 거래패널 토글)
  status      ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_croom_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
  CONSTRAINT fk_croom_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE SET NULL,
  KEY idx_chat_room_status (status, updated_at DESC)
) ENGINE=InnoDB;

CREATE TABLE chat_room_participants (
  room_id       BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  role          ENUM('BUYER','SELLER') NOT NULL,
  joined_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_read_message_id BIGINT UNSIGNED NULL, -- (옵션) 앱단 참조
  last_read_at  DATETIME NULL,
  PRIMARY KEY (room_id, user_id),
  CONSTRAINT fk_crp_room FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
  CONSTRAINT fk_crp_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE chat_messages (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  room_id    BIGINT UNSIGNED NOT NULL,
  sender_id  BIGINT UNSIGNED NOT NULL,
  type       ENUM('TEXT','IMAGE','SYSTEM') NOT NULL DEFAULT 'TEXT',
  content    TEXT NULL,
  image_url  VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cmsg_room   FOREIGN KEY (room_id)  REFERENCES chat_rooms(id) ON DELETE CASCADE,
  CONSTRAINT fk_cmsg_sender FOREIGN KEY (sender_id) REFERENCES users(id)     ON DELETE CASCADE,
  KEY idx_cmsg_room_created (room_id, created_at)
) ENGINE=InnoDB;

/* =========================================================
 I) 지갑
========================================================= */
CREATE TABLE wallet_accounts (
  user_id    BIGINT UNSIGNED PRIMARY KEY,
  balance    INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE wallet_transactions (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT UNSIGNED NOT NULL,
  amount           INT NOT NULL,  -- +충전 / -사용
  type             ENUM('TOPUP','WITHDRAW','PAY','REFUND','ADJUST') NOT NULL,
  related_order_id BIGINT UNSIGNED NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_wtx_user  FOREIGN KEY (user_id)          REFERENCES users(id)   ON DELETE CASCADE,
  CONSTRAINT fk_wtx_order FOREIGN KEY (related_order_id) REFERENCES orders(id)  ON DELETE SET NULL,
  KEY idx_wtx_user_created (user_id, created_at)
) ENGINE=InnoDB;

/* =========================================================
 J) KU대리(배달)  ← 포인트 보다 "먼저"
========================================================= */
CREATE TABLE rider_profiles (
  user_id    BIGINT UNSIGNED PRIMARY KEY,
  vehicle    ENUM('WALK','BICYCLE','SCOOTER','MOTORCYCLE','CAR') NOT NULL DEFAULT 'WALK',
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_rider_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE delivery_requests (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id         BIGINT UNSIGNED NOT NULL,
  requester_id     BIGINT UNSIGNED NOT NULL, -- 보통 buyer
  rider_id         BIGINT UNSIGNED NULL,
  status           ENUM('REQUESTED','MATCHED','PICKUP','IN_TRANSIT','DELIVERED','COMPLETED','CANCELED') NOT NULL DEFAULT 'REQUESTED',
  start_name       VARCHAR(255) NOT NULL,
  end_name         VARCHAR(255) NOT NULL,
  start_location   POINT SRID 4326 NOT NULL,
  end_location     POINT SRID 4326 NOT NULL,
  distance_meters  INT NULL,
  fee_amount       INT NULL, -- distance 기준 계산값
  requested_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accepted_at      DATETIME NULL,
  completed_at     DATETIME NULL,
  CONSTRAINT fk_dreq_order  FOREIGN KEY (order_id)     REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_dreq_req    FOREIGN KEY (requester_id) REFERENCES users(id)  ON DELETE RESTRICT,
  CONSTRAINT fk_dreq_rider  FOREIGN KEY (rider_id)     REFERENCES users(id)  ON DELETE SET NULL,
  SPATIAL INDEX idx_dreq_start (start_location),
  SPATIAL INDEX idx_dreq_end   (end_location),
  KEY idx_dreq_status (status)
) ENGINE=InnoDB;

CREATE TABLE rider_earnings (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rider_id      BIGINT UNSIGNED NOT NULL,
  delivery_id   BIGINT UNSIGNED NOT NULL,
  amount        INT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rearn_rider    FOREIGN KEY (rider_id)    REFERENCES users(id)              ON DELETE CASCADE,
  CONSTRAINT fk_rearn_delivery FOREIGN KEY (delivery_id)  REFERENCES delivery_requests(id) ON DELETE CASCADE,
  UNIQUE KEY uk_rider_delivery (rider_id, delivery_id)
) ENGINE=InnoDB;

/* =========================================================
 K) 포인트  ← delivery_requests 생성 후
========================================================= */
CREATE TABLE point_accounts (
  user_id    BIGINT UNSIGNED PRIMARY KEY,
  balance    INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pacct_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE point_transactions (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id             BIGINT UNSIGNED NOT NULL,
  amount              INT NOT NULL, -- +적립 / -차감
  type                ENUM('DELIVERY_EARN','PURCHASE_SPEND','REFUND','ADJUST') NOT NULL,
  related_order_id    BIGINT UNSIGNED NULL,
  related_delivery_id BIGINT UNSIGNED NULL,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ptr_user     FOREIGN KEY (user_id)             REFERENCES users(id)             ON DELETE CASCADE,
  CONSTRAINT fk_ptr_order    FOREIGN KEY (related_order_id)    REFERENCES orders(id)            ON DELETE SET NULL,
  CONSTRAINT fk_ptr_delivery FOREIGN KEY (related_delivery_id) REFERENCES delivery_requests(id) ON DELETE SET NULL,
  KEY idx_ptr_user_created (user_id, created_at)
) ENGINE=InnoDB;

/* =========================================================
 L) 리뷰/신고/페널티/알림
========================================================= */
CREATE TABLE reviews (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id     BIGINT UNSIGNED NOT NULL,
  reviewer_id  BIGINT UNSIGNED NOT NULL,
  reviewee_id  BIGINT UNSIGNED NOT NULL,
  rating       TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment      VARCHAR(500) NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_review_order    FOREIGN KEY (order_id)    REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id)  ON DELETE CASCADE,
  CONSTRAINT fk_review_reviewee FOREIGN KEY (reviewee_id) REFERENCES users(id)  ON DELETE CASCADE,
  KEY idx_review_reviewee (reviewee_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE reports (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_id  BIGINT UNSIGNED NOT NULL,
  target_type  ENUM('USER','PRODUCT','MESSAGE','REVIEW','OTHER') NOT NULL,
  target_id    BIGINT UNSIGNED NOT NULL,
  reason       VARCHAR(500) NOT NULL,
  status       ENUM('PENDING','REVIEWING','ACTIONED','DISMISSED') NOT NULL DEFAULT 'PENDING',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_report_reporter FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_report_target (target_type, target_id)
) ENGINE=InnoDB;

CREATE TABLE penalties (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  type       ENUM('NO_RESPONSE_24H','INACTIVE_48H','ABUSE','OTHER') NOT NULL,
  points     INT NOT NULL DEFAULT 0,
  expires_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_penalty_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_penalty_user (user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  type       ENUM('CHAT','TRADE','WARNING','SYSTEM') NOT NULL,
  title      VARCHAR(120) NOT NULL,
  body       VARCHAR(500) NULL,
  payload    JSON NULL,
  read_at    DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_notif_user_created (user_id, created_at),
  KEY idx_notif_unread (user_id, read_at)
) ENGINE=InnoDB;

/* =========================================================
 M) 함수 / 이벤트
========================================================= */
DELIMITER $$

CREATE FUNCTION compute_delivery_fee(meters INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE fee_per_500m INT;
  SELECT delivery_fee_per_500m INTO fee_per_500m
  FROM app_settings WHERE id = 1;
  RETURN CEIL(GREATEST(meters, 1) / 500) * fee_per_500m;
END$$

DELIMITER ;

-- 이벤트: 결제 후 자동 확정 (앱에서 orders.auto_confirm_at 셋팅 필요)
-- ※ event_scheduler는 서버 권한 있을 때만 ON 가능
-- -- SET GLOBAL event_scheduler = ON;
-- -- SHOW VARIABLES LIKE 'event_scheduler';

CREATE EVENT IF NOT EXISTS ev_auto_confirm_orders
  ON SCHEDULE EVERY 1 MINUTE STARTS CURRENT_TIMESTAMP
  DO
    UPDATE orders
       SET status = 'COMPLETED',
           escrow_confirmed_at = IFNULL(escrow_confirmed_at, NOW())
     WHERE status = 'PAID'
       AND auto_confirm_at IS NOT NULL
       AND auto_confirm_at <= NOW();

/* =========================================================
 N) 시드 데이터 (테이블 모두 생성된 뒤!)
========================================================= */

-- 카테고리
INSERT IGNORE INTO categories (id, name, parent_id, sort_order) VALUES
  (1, '디지털기기', NULL, 1),
  (2, '생활/가전', NULL, 2),
  (3, '가구/인테리어', NULL, 3),
  (4, '의류', NULL, 4),
  (5, '도서/티켓/취미', NULL, 5);

-- 유저 (id: 1=buyer, 2=seller, 3=admin 이 되도록 비워둔 상태에서 삽입)
INSERT INTO users (email, email_verified, password_hash, nickname, phone, campus_code, role)
VALUES
  ('buyer1@konkuk.ac.kr',  1, 'hash_buyer1',  '철수',  '010-1111-1111', 'KU', 'USER'),
  ('seller1@konkuk.ac.kr', 1, 'hash_seller1', '영희',  '010-2222-2222', 'KU', 'USER'),
  ('admin@konkuk.ac.kr',   1, 'hash_admin',   '관리자','010-9999-9999', 'KU', 'ADMIN');

-- 상품 (seller_id=2 가 존재)
INSERT INTO products
  (seller_id, title, price, description, category_id, status,
   campus_code, location_name, meeting_point, delivery_option)
VALUES
  (2, '아이패드 미니 6', 350000, '깨끗하게 사용한 아이패드 미니 6세대 팝니다.', 1, 'ACTIVE',
   'KU', '건대입구역 2번 출구', ST_SRID(POINT(127.073, 37.540), 4326), 'BOTH'),
  (2, '스탠드형 선풍기', 20000,  '소음 적고 성능 좋은 선풍기입니다.',            2, 'ACTIVE',
   'KU', '기숙사 A동 1층',       ST_SRID(POINT(127.071, 37.542), 4326), 'MEETUP');

-- 주문 (product_id=1,2 / buyer_id=1 / seller_id=2 가 존재)
INSERT INTO orders
  (product_id, buyer_id, seller_id, status, secure_pay, is_delivery, amount, delivery_fee)
VALUES
  (1, 1, 2, 'PAID', 1, 0, 350000, 0),   -- 아이패드 거래 (안심결제)
  (2, 1, 2, 'INIT', 0, 1, 20000,  200); -- 선풍기 거래 (KU대리 예정)

-- 채팅방 + 참가자 + 메시지
INSERT INTO chat_rooms (product_id, order_id, status)
VALUES (1, 1, 'OPEN'), (2, 2, 'OPEN');

INSERT INTO chat_room_participants (room_id, user_id, role)
VALUES
  (1, 1, 'BUYER'), (1, 2, 'SELLER'),
  (2, 1, 'BUYER'), (2, 2, 'SELLER');

INSERT INTO chat_messages (room_id, sender_id, type, content)
VALUES
  (1, 1, 'TEXT', '안녕하세요, 아이패드 아직 거래 가능할까요?'),
  (1, 2, 'TEXT', '네 가능합니다. 언제 시간 괜찮으세요?'),
  (1, 1, 'TEXT', '오늘 저녁 6시 건대입구역 2번 출구에서 괜찮을까요?'),
  (1, 2, 'TEXT', '좋습니다. 그때 뵐게요.'),
  (2, 1, 'TEXT', '선풍기 배달 신청 가능한가요?'),
  (2, 2, 'TEXT', '네, KU대리 연결해드릴게요.');

-- 지갑 / 포인트 기본값 (지갑 테이블이 이미 생성된 상태)
INSERT INTO wallet_accounts (user_id, balance) VALUES
  (1, 100000),
  (2, 0);

INSERT INTO point_accounts (user_id, balance) VALUES
  (1, 500),
  (2, 0);
