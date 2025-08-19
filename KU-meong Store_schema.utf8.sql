-- KU硫띻?寃?(KUMeong Store) ?곗씠?곕쿋?댁뒪 ?ㅽ궎留?v2.2
-- MySQL 8.0+ / utf8mb4 / InnoDB / SRID 4326

/* =========================================================
 A) 源⑤걮???ъ떎?됱쓣 ?꾪븳 ?쒕∼ (?먯떇 ??遺紐???닚)
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
 B) ?곗씠?곕쿋?댁뒪
========================================================= */
CREATE DATABASE IF NOT EXISTS kumeong_store
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE kumeong_store;

/* =========================================================
 C) ?꾩뿭 ?ㅼ젙/?곸닔
========================================================= */
CREATE TABLE app_settings (
  id            TINYINT UNSIGNED PRIMARY KEY CHECK (id = 1),
  delivery_fee_per_500m INT NOT NULL DEFAULT 200, -- 0.5km ??200??  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 寃쎄퀬 ?놁씠 ?덉젙 ?쎌엯 (?놁쑝硫?留뚮뱾怨? ?덉쑝硫?洹몃?濡?
INSERT INTO app_settings (id)
VALUES (1)
ON DUPLICATE KEY UPDATE id = VALUES(id);

-- ?숆탳 ?대찓???꾨찓???붿씠?몃━?ㅽ듃
CREATE TABLE school_domains (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  campus_code  VARCHAR(20) NOT NULL,
  domain       VARCHAR(120) NOT NULL,
  UNIQUE KEY uk_campus_domain (campus_code, domain)
) ENGINE=InnoDB;

/* =========================================================
 D) ?ъ슜??========================================================= */
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

-- 移쒓뎄/李⑤떒
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
 E) 移댄뀒怨좊━/?쒓렇
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
 F) ?곹뭹
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
  meeting_point   POINT SRID 4326 NOT NULL,   -- ??怨듦컙醫뚰몴 ?꾩닔
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
 G) 二쇰Ц/寃곗젣
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
 H) 梨꾪똿 (chat_rooms ??participants ??messages)
========================================================= */
CREATE TABLE chat_rooms (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id  BIGINT UNSIGNED NULL,  -- ?곹뭹蹂?諛??곌껐(?좏깮)
  order_id    BIGINT UNSIGNED NULL,  -- 吏꾪뻾以?二쇰Ц ?곌껐(?꾨윴??嫄곕옒?⑤꼸 ?좉?)
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
  last_read_message_id BIGINT UNSIGNED NULL, -- (?듭뀡) ?깅떒 李몄“
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
 I) 吏媛?========================================================= */
CREATE TABLE wallet_accounts (
  user_id    BIGINT UNSIGNED PRIMARY KEY,
  balance    INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE wallet_transactions (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT UNSIGNED NOT NULL,
  amount           INT NOT NULL,  -- +異⑹쟾 / -?ъ슜
  type             ENUM('TOPUP','WITHDRAW','PAY','REFUND','ADJUST') NOT NULL,
  related_order_id BIGINT UNSIGNED NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_wtx_user  FOREIGN KEY (user_id)          REFERENCES users(id)   ON DELETE CASCADE,
  CONSTRAINT fk_wtx_order FOREIGN KEY (related_order_id) REFERENCES orders(id)  ON DELETE SET NULL,
  KEY idx_wtx_user_created (user_id, created_at)
) ENGINE=InnoDB;

/* =========================================================
 J) KU?由?諛곕떖)  ???ъ씤??蹂대떎 "癒쇱?"
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
  requester_id     BIGINT UNSIGNED NOT NULL, -- 蹂댄넻 buyer
  rider_id         BIGINT UNSIGNED NULL,
  status           ENUM('REQUESTED','MATCHED','PICKUP','IN_TRANSIT','DELIVERED','COMPLETED','CANCELED') NOT NULL DEFAULT 'REQUESTED',
  start_name       VARCHAR(255) NOT NULL,
  end_name         VARCHAR(255) NOT NULL,
  start_location   POINT SRID 4326 NOT NULL,
  end_location     POINT SRID 4326 NOT NULL,
  distance_meters  INT NULL,
  fee_amount       INT NULL, -- distance 湲곗? 怨꾩궛媛?  requested_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
 K) ?ъ씤?? ??delivery_requests ?앹꽦 ??========================================================= */
CREATE TABLE point_accounts (
  user_id    BIGINT UNSIGNED PRIMARY KEY,
  balance    INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pacct_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE point_transactions (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id             BIGINT UNSIGNED NOT NULL,
  amount              INT NOT NULL, -- +?곷┰ / -李④컧
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
 L) 由щ럭/?좉퀬/?섎꼸???뚮┝
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
 M) ?⑥닔 / ?대깽??========================================================= */
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

-- ?대깽?? 寃곗젣 ???먮룞 ?뺤젙 (?깆뿉??orders.auto_confirm_at ?뗮똿 ?꾩슂)
-- ??event_scheduler???쒕쾭 沅뚰븳 ?덉쓣 ?뚮쭔 ON 媛??-- -- SET GLOBAL event_scheduler = ON;
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
 N) ?쒕뱶 ?곗씠??(?뚯씠釉?紐⑤몢 ?앹꽦????)
========================================================= */

-- 移댄뀒怨좊━
INSERT IGNORE INTO categories (id, name, parent_id, sort_order) VALUES
  (1, '?붿??멸린湲?, NULL, 1),
  (2, '?앺솢/媛??, NULL, 2),
  (3, '媛援??명뀒由ъ뼱', NULL, 3),
  (4, '?섎쪟', NULL, 4),
  (5, '?꾩꽌/?곗폆/痍⑤?', NULL, 5);

-- ?좎? (id: 1=buyer, 2=seller, 3=admin ???섎룄濡?鍮꾩썙???곹깭?먯꽌 ?쎌엯)
INSERT INTO users (email, email_verified, password_hash, nickname, phone, campus_code, role)
VALUES
  ('buyer1@konkuk.ac.kr',  1, 'hash_buyer1',  '泥좎닔',  '010-1111-1111', 'KU', 'USER'),
  ('seller1@konkuk.ac.kr', 1, 'hash_seller1', '?곹씗',  '010-2222-2222', 'KU', 'USER'),
  ('admin@konkuk.ac.kr',   1, 'hash_admin',   '愿由ъ옄','010-9999-9999', 'KU', 'ADMIN');

-- ?곹뭹 (seller_id=2 媛 議댁옱)
INSERT INTO products
  (seller_id, title, price, description, category_id, status,
   campus_code, location_name, meeting_point, delivery_option)
VALUES
  (2, '?꾩씠?⑤뱶 誘몃땲 6', 350000, '源⑤걮?섍쾶 ?ъ슜???꾩씠?⑤뱶 誘몃땲 6?몃? ?앸땲??', 1, 'ACTIVE',
   'KU', '嫄대??낃뎄??2踰?異쒓뎄', ST_SRID(POINT(127.073, 37.540), 4326), 'BOTH'),
  (2, '?ㅽ깲?쒗삎 ?좏뭾湲?, 20000,  '?뚯쓬 ?곴퀬 ?깅뒫 醫뗭? ?좏뭾湲곗엯?덈떎.',            2, 'ACTIVE',
   'KU', '湲곗닕??A??1痢?,       ST_SRID(POINT(127.071, 37.542), 4326), 'MEETUP');

-- 二쇰Ц (product_id=1,2 / buyer_id=1 / seller_id=2 媛 議댁옱)
INSERT INTO orders
  (product_id, buyer_id, seller_id, status, secure_pay, is_delivery, amount, delivery_fee)
VALUES
  (1, 1, 2, 'PAID', 1, 0, 350000, 0),   -- ?꾩씠?⑤뱶 嫄곕옒 (?덉떖寃곗젣)
  (2, 1, 2, 'INIT', 0, 1, 20000,  200); -- ?좏뭾湲?嫄곕옒 (KU?由??덉젙)

-- 梨꾪똿諛?+ 李멸???+ 硫붿떆吏
INSERT INTO chat_rooms (product_id, order_id, status)
VALUES (1, 1, 'OPEN'), (2, 2, 'OPEN');

INSERT INTO chat_room_participants (room_id, user_id, role)
VALUES
  (1, 1, 'BUYER'), (1, 2, 'SELLER'),
  (2, 1, 'BUYER'), (2, 2, 'SELLER');

INSERT INTO chat_messages (room_id, sender_id, type, content)
VALUES
  (1, 1, 'TEXT', '?덈뀞?섏꽭?? ?꾩씠?⑤뱶 ?꾩쭅 嫄곕옒 媛?ν븷源뚯슂?'),
  (1, 2, 'TEXT', '??媛?ν빀?덈떎. ?몄젣 ?쒓컙 愿쒖갖?쇱꽭??'),
  (1, 1, 'TEXT', '?ㅻ뒛 ???6??嫄대??낃뎄??2踰?異쒓뎄?먯꽌 愿쒖갖?꾧퉴??'),
  (1, 2, 'TEXT', '醫뗭뒿?덈떎. 洹몃븣 逾먭쾶??'),
  (2, 1, 'TEXT', '?좏뭾湲?諛곕떖 ?좎껌 媛?ν븳媛??'),
  (2, 2, 'TEXT', '?? KU?由??곌껐?대뱶由닿쾶??');

-- 吏媛?/ ?ъ씤??湲곕낯媛?(吏媛??뚯씠釉붿씠 ?대? ?앹꽦???곹깭)
INSERT INTO wallet_accounts (user_id, balance) VALUES
  (1, 100000),
  (2, 0);

INSERT INTO point_accounts (user_id, balance) VALUES
  (1, 500),
  (2, 0);
