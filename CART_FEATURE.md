# 장바구니 기능 구현 완료

## 구현 날짜: 2025-11-26

## 주요 기능

### 1. 장바구니에 상품 추가 (API 8.1)
- `POST /api/cart/add`
- 상품 ID와 수량을 전달하여 장바구니에 추가
- 최소/최대 주문 수량 검증

### 2. 장바구니 조회 (API 8.2)
- `GET /api/cart/{distributorId}`
- 특정 유통업체의 장바구니 조회
- 상품 목록, 총 금액, 총 수량 표시

### 3. 장바구니 아이템 수량 변경 (API 8.3)
- `PUT /api/cart/{distributorId}/items/{itemId}?quantity={quantity}`
- 장바구니 내 상품 수량 증가/감소

### 4. 장바구니 아이템 삭제 (API 8.4)
- `DELETE /api/cart/{distributorId}/items/{itemId}`
- 개별 상품 삭제

### 5. 장바구니 비우기 (API 8.5)
- `DELETE /api/cart/{distributorId}`
- 전체 장바구니 비우기

## 구현된 파일

### Domain Layer
- `lib/domain/entities/cart.dart` - Cart, CartItem 엔티티
- `lib/domain/repositories/cart_repository.dart` - Cart Repository 인터페이스
- `lib/domain/usecases/cart_usecases.dart` - 5개의 UseCase

### Data Layer
- `lib/data/models/cart_model.dart` - CartModel, CartItemModel
- `lib/data/datasources/cart_remote_datasource.dart` - API 통신
- `lib/data/repositories/cart_repository_impl.dart` - Repository 구현

### Presentation Layer
- `lib/presentation/providers/cart_provider.dart` - 상태 관리
- `lib/presentation/pages/cart_page.dart` - 장바구니 UI
- `lib/presentation/pages/product_detail_page.dart` - 장바구니 담기 버튼 추가

### Dependency Injection
- `lib/injection_container.dart` - Cart 관련 의존성 주입 추가

## UI 특징

### 장바구니 페이지 (CartPage)
- ✅ 상품 목록 표시 (이미지, 이름, 가격, 수량)
- ✅ 수량 증가/감소 버튼
- ✅ 개별 상품 삭제
- ✅ 전체 삭제 (확인 다이얼로그)
- ✅ 총 상품 수 및 총 금액 표시
- ✅ 주문하기 버튼 (준비 중)
- ✅ 빈 장바구니 상태 표시

### 상품 상세 페이지 개선
- ✅ 하단에 "장바구니 담기" 버튼 추가
- ✅ 수량 선택 다이얼로그
- ✅ 최소/최대 주문 수량 제한
- ✅ 품절 상품 처리

## 사용 방법

### 1. 장바구니에 상품 추가
```dart
// 상품 상세 페이지에서 "장바구니 담기" 버튼 클릭
// 수량 선택 후 "담기" 버튼 클릭
```

### 2. 장바구니 보기
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider(
      create: (_) => InjectionContainer.getCartProvider(),
      child: CartPage(
        distributorId: 'distributor1',
        distributorName: '유통업체명',
      ),
    ),
  ),
);
```

### 3. 수량 변경
- 장바구니 페이지에서 +/- 버튼 사용

### 4. 상품 삭제
- 장바구니 페이지에서 X 버튼 클릭

### 5. 전체 삭제
- 장바구니 페이지 상단의 "전체 삭제" 버튼 클릭

## 다음 단계

- [ ] 홈페이지에 장바구니 아이콘 추가
- [ ] 장바구니 아이템 개수 뱃지 표시
- [ ] 주문하기 기능 구현
- [ ] 여러 유통업체의 장바구니 관리
- [ ] 장바구니 로컬 캐싱

## 테스트 권장사항

1. 상품 상세 페이지에서 장바구니 담기
2. 수량 증가/감소 테스트
3. 개별 삭제 및 전체 삭제 테스트
4. 최소/최대 수량 제한 테스트
5. 품절 상품 처리 테스트
