# Fresh Flow

신선한 식자재 유통 관리 플랫폼

## 주요 기능

### 인증 시스템
- 사용자 회원가입 (매장 사장님/공급업체)
- 로그인/로그아웃
- JWT 토큰 기반 인증

### 매장 관리
- 매장 정보 등록 (매장 사장님 전용)
- 매장 정보 입력 항목:
  - 매장명, 업종, 지역
  - 주요 취급 품목
  - 매장 설명
  - 직원 수, 영업 시간
  - 전화번호, 주소

## 아키텍처

이 프로젝트는 Clean Architecture와 SOLID 원칙을 따릅니다:

### 레이어 구조
- **Presentation Layer**: UI 및 상태 관리 (Provider)
- **Domain Layer**: 비즈니스 로직 및 엔티티
- **Data Layer**: 데이터 소스 및 리포지토리 구현

### SOLID 원칙 적용
- **Single Responsibility**: 각 클래스는 단일 책임만 가짐
- **Open/Closed**: 확장에는 열려있고 수정에는 닫혀있음
- **Liskov Substitution**: 인터페이스 기반 설계
- **Interface Segregation**: 작고 구체적인 인터페이스
- **Dependency Inversion**: 추상화에 의존

## 시작하기

### 필수 요구사항
- Flutter SDK (3.10.1 이상)
- Dart SDK
- Android Studio / VS Code

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## API 엔드포인트

### 매장 등록
```
POST /api/store/info
Content-Type: application/json
Authorization: Bearer {JWT_TOKEN}

{
  "storeName": "맛있는 한식당",
  "businessType": "한식",
  "region": "서울 강남구",
  "mainProducts": "쌀/곡물,채소,육류",
  "description": "정성을 다하는 한식당입니다",
  "employeeCount": 5,
  "operatingHours": "09:00-22:00",
  "phoneNumber": "010-1234-5678",
  "address": "서울시 강남구 테헤란로 123"
}
```

## 프로젝트 구조

```
lib/
├── core/              # 공통 유틸리티 및 상수
├── data/              # 데이터 레이어
│   ├── datasources/   # 원격/로컬 데이터 소스
│   ├── models/        # 데이터 모델
│   └── repositories/  # 리포지토리 구현
├── domain/            # 도메인 레이어
│   ├── entities/      # 비즈니스 엔티티
│   ├── repositories/  # 리포지토리 인터페이스
│   └── usecases/      # 유스케이스
├── presentation/      # 프레젠테이션 레이어
│   ├── pages/         # UI 페이지
│   └── providers/     # 상태 관리
└── injection_container.dart  # 의존성 주입
```
