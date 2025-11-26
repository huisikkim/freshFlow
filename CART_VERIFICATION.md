# 장바구니 저장 기능 검증 가이드

## 수정 내용

### 문제점
`product_detail_page.dart`의 "장바구니 담기" 버튼에서 실제로 CartProvider를 호출하지 않고 TODO 주석만 있었습니다.

### 해결 방법
1. **CartProvider 통합**: `InjectionContainer.getCartProvider()`를 사용하여 CartProvider 인스턴스 생성
2. **실제 API 호출**: `cartProvider.addToCart(productId, quantity)` 메서드 호출
3. **사용자 피드백**: 로딩 상태, 성공/실패 메시지 표시
4. **장바구니 이동**: 성공 시 "보기" 버튼으로 장바구니 페이지 이동 가능

## 검증 절차

### 1. 상품 상세 페이지에서 장바구니 담기
```
1. 앱 실행 및 로그인
2. 유통업체 카탈로그 페이지로 이동
3. 상품 선택하여 상세 페이지 진입
4. 하단의 "장바구니 담기" 버튼 클릭
5. 수량 선택 다이얼로그에서 수량 조정
6. "담기" 버튼 클릭
```

**예상 결과:**
- "장바구니에 담는 중..." 로딩 메시지 표시
- 성공 시: "상품명 X개를 장바구니에 담았습니다" 메시지 (녹색)
- 실패 시: "장바구니 담기 실패: [오류 메시지]" (빨간색)

### 2. 장바구니 페이지에서 확인
```
1. 성공 메시지의 "보기" 버튼 클릭
   또는
2. 직접 장바구니 페이지로 이동
```

**예상 결과:**
- 방금 담은 상품이 장바구니에 표시됨
- 상품 이미지, 이름, 가격, 수량이 정확히 표시됨
- 총 금액이 올바르게 계산됨

### 3. 수량 변경 테스트
```
1. 장바구니에서 +/- 버튼으로 수량 조정
2. 서버에 업데이트 요청 전송 확인
3. 총 금액이 자동으로 재계산되는지 확인
```

### 4. 상품 삭제 테스트
```
1. 장바구니에서 X 버튼 클릭
2. 확인 다이얼로그에서 "삭제" 선택
3. 해당 상품이 장바구니에서 제거되는지 확인
```

### 5. 전체 삭제 테스트
```
1. 장바구니 상단의 "전체 삭제" 버튼 클릭
2. 확인 다이얼로그에서 "비우기" 선택
3. 장바구니가 완전히 비워지는지 확인
4. "장바구니가 비어있습니다" 메시지 표시 확인
```

## API 호출 흐름

```
ProductDetailPage
  ↓ (사용자가 "담기" 클릭)
_addToCart()
  ↓
InjectionContainer.getCartProvider()
  ↓
CartProvider.addToCart(productId, quantity)
  ↓
AddToCartUseCase.execute()
  ↓
CartRepository.addToCart()
  ↓
CartRemoteDataSource.addToCart()
  ↓
POST /api/cart/add
  {
    "productId": 123,
    "quantity": 5
  }
  ↓
서버 응답 (Cart 객체)
  ↓
CartProvider 상태 업데이트
  ↓
UI 업데이트 (SnackBar 표시)
```

## 주요 코드 변경사항

### lib/presentation/pages/product_detail_page.dart

#### Before (TODO만 있음)
```dart
ElevatedButton(
  onPressed: () async {
    Navigator.pop(dialogContext);
    // TODO: CartProvider를 사용하여 장바구니에 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('...')),
    );
  },
  child: const Text('담기'),
),
```

#### After (실제 구현)
```dart
ElevatedButton(
  onPressed: () {
    Navigator.pop(dialogContext);
    _addToCart(context, product, quantity);
  },
  child: const Text('담기'),
),

Future<void> _addToCart(BuildContext context, Product product, int quantity) async {
  final cartProvider = InjectionContainer.getCartProvider();
  
  try {
    // 로딩 표시
    ScaffoldMessenger.of(context).showSnackBar(...);
    
    // 실제 API 호출
    await cartProvider.addToCart(product.id, quantity);
    
    // 성공 메시지 및 장바구니 이동 옵션
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('...'),
        action: SnackBarAction(
          label: '보기',
          onPressed: () {
            Navigator.push(...CartPage...);
          },
        ),
      ),
    );
  } catch (e) {
    // 에러 처리
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

## 디버깅 팁

### 1. 네트워크 오류 발생 시
- API 서버가 실행 중인지 확인
- `lib/core/constants/api_constants.dart`에서 baseUrl 확인
- 로그인 토큰이 유효한지 확인

### 2. "로그인이 필요합니다" 오류
- 사용자가 로그인되어 있는지 확인
- AuthRepository에서 토큰을 가져올 수 있는지 확인

### 3. 장바구니가 비어 보이는 경우
- 올바른 distributorId를 사용하고 있는지 확인
- GET /api/cart/{distributorId} API 응답 확인
- Product 객체에 distributorId가 포함되어 있는지 확인

### 4. 수량 제한 오류
- Product의 minOrderQuantity, maxOrderQuantity 값 확인
- 서버 측 검증 로직 확인

## 다음 단계

- [ ] 홈페이지에 장바구니 아이콘 추가
- [ ] 장바구니 아이템 개수 뱃지 표시
- [ ] 여러 유통업체의 장바구니 관리
- [ ] 장바구니 로컬 캐싱 (오프라인 지원)
- [ ] 장바구니 동기화 (여러 기기 간)
