# 배송 관리 기능 구현 완료

## 구현된 기능

### 1. 유통업자 기능
- **주문 목록에서 배송 관리 버튼** (`distributor_order_list_page.dart`)
  - 주문확정(CONFIRMED) 상태: "배송 시작하기" 버튼 표시
  - 배송중(SHIPPED) 상태: "배송 완료" 버튼 표시
  
- **배송 시작 모달** (`ship_delivery_modal.dart`)
  - **배송 방식 선택**
    - 택배 배송: 택배사 선택, 송장번호 입력
    - 직접 배송: 기사 이름, 연락처, 차량 번호 입력
  - 예상 도착일 선택
  
- **배송 관리 API 호출**
  - `POST /api/deliveries/order/{orderId}` - 배송 정보 생성
  - `POST /api/deliveries/order/{orderId}/ship` - 배송 시작
    - 택배 배송: `deliveryType: "COURIER"` + 택배사, 송장번호
    - 직접 배송: `deliveryType: "DIRECT"` + 기사 정보, 차량 번호
  - `POST /api/deliveries/order/{orderId}/complete` - 배송 완료

### 2. 가게사장님 기능
- **배송 조회 화면** (`store_delivery_list_page.dart`)
  - 주문 내역 페이지에서 배송 아이콘 클릭으로 접근
  - 상태별 필터링 (전체, 상품준비중, 배송중, 배송완료)
  - 배송 정보 표시
    - 배송 방식 (택배 배송 / 직접 배송)
    - 택배 배송: 택배사, 송장번호
    - 직접 배송: 기사 이름, 연락처, 차량 번호
    - 예상 도착일, 배송 시작/완료 시간
  
- **배송 조회 API 호출**
  - `GET /api/deliveries/store` - 전체 배송 목록
  - `GET /api/deliveries/order/{orderId}` - 주문별 배송 상세

### 3. 배송 상태
- `PREPARING` - 상품준비중 (파란색)
- `SHIPPED` - 배송중 (초록색)
- `DELIVERED` - 배송완료 (보라색)

## 파일 구조

```
lib/
├── domain/entities/
│   └── delivery.dart                          # 배송 엔티티
├── data/
│   ├── models/
│   │   └── delivery_model.dart                # 배송 모델
│   └── datasources/
│       └── delivery_remote_datasource.dart    # 배송 API 데이터소스
├── presentation/
│   ├── providers/
│   │   └── delivery_provider.dart             # 배송 상태 관리
│   ├── pages/
│   │   ├── store_delivery_list_page.dart      # 가게사장님 배송 조회
│   │   ├── distributor_order_list_page.dart   # 유통업자 주문 목록 (수정)
│   │   └── order_detail_page.dart             # 주문 상세 (수정)
│   └── widgets/
│       └── ship_delivery_modal.dart           # 배송 시작 모달
└── core/constants/
    └── api_constants.dart                     # API 엔드포인트 추가
```

## 사용 방법

### 유통업자
**배송 시작:**
1. 받은 주문 목록에서 "주문확정" 상태의 주문 확인
2. "배송 시작하기" 버튼 클릭 또는 주문 상세로 이동
3. 배송 시작 모달에서 배송 방식 선택
   - **택배 배송**: 택배사, 송장번호, 예상 도착일 입력
   - **직접 배송**: 기사 이름, 연락처, 차량 번호, 예상 도착일 입력
4. "배송 시작" 버튼 클릭

**배송 완료:**
1. 받은 주문 목록에서 "배송중" 상태의 주문 확인
2. "배송 완료" 버튼 클릭 (목록 또는 상세 페이지)
3. 확인 다이얼로그에서 "완료" 클릭

### 가게사장님
1. 주문 내역 페이지 상단의 배송 아이콘 클릭
2. 배송 목록에서 상태별 필터링
3. 각 배송의 상세 정보 확인
   - 배송 방식 (택배/직접)
   - 택배 배송: 택배사, 송장번호
   - 직접 배송: 기사 정보, 차량 번호
   - 예상 도착일

## 배송 프로세스 흐름

```
주문확정 (CONFIRMED)
    ↓
[유통업자] 배송 시작 → 상품준비중 (PREPARING)
    ↓
[유통업자] 배송 시작 (택배/직접) → 배송중 (SHIPPED)
    ↓
[유통업자] 배송 완료 → 배송완료 (DELIVERED)
```

## 다음 단계 (선택사항)
- 배송 추적 외부 API 연동 (택배사 API)
- 푸시 알림 (배송 시작, 배송 완료)
- 배송 지연 알림
