# DoraKit

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20macCatalyst-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

DoraKit은 Swift의 Codable 프로토콜을 위한 자동화된 JSON 코딩 키 생성을 제공하는 Swift 매크로 라이브러리입니다. 복잡한 `CodingKeys` enum을 수동으로 작성할 필요 없이, 간단한 매크로를 사용하여 JSON 직렬화/역직렬화를 자동화할 수 있습니다.

## ✨ 주요 기능

- **자동 CodingKeys 생성**: `@AutoCodingKeys` 매크로로 자동 `CodingKeys` enum 생성
- **커스텀 JSON 키 매핑**: `@jsonKey` 매크로로 Swift 프로퍼티명과 JSON 키명 분리
- **자동 프로토콜 준수**: 누락된 `Codable`, `Encodable`, `Decodable` 프로토콜 자동 추가
- **타입 안전성**: 컴파일 타임에 JSON 키 중복 및 유효성 검사
- **계산 프로퍼티 무시**: 저장 프로퍼티만 자동으로 처리

## 🚀 빠른 시작

### 설치

Swift Package Manager를 사용하여 설치하세요:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/DoraKit.git", from: "1.0.0")
]
```

### 기본 사용법

```swift
import DoraKit

@AutoCodingKeys
struct User {
    @jsonKey("user_name") let name: String
    @jsonKey("user_age") let age: Int
    let email: String        // "email"로 매핑
    let isActive: Bool       // "isActive"로 매핑
    
    var fullName: String {   // 계산 프로퍼티는 무시됨
        "\(name) (\(age))"
    }
}
```

위 코드는 다음과 같이 자동으로 변환됩니다:

```swift
struct User {
    let name: String
    let age: Int
    let email: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name = "user_name"
        case age = "user_age"
        case email
        case isActive
    }
}

extension User: Codable {
}
```

## 📖 상세 사용법

### @JsonKey 매크로

개별 프로퍼티에 커스텀 JSON 키를 지정할 때 사용합니다.

```swift
struct Product {
    @JsonKey("product_id") let id: String
    @JsonKey("product_name") let name: String
    let price: Double  // "price"로 매핑
}
```

**제약사항:**
- `let` 또는 `var` 선언에만 사용 가능
- 문자열 리터럴만 인자로 허용
- 빈 문자열은 허용하지 않음
- 하나의 프로퍼티에 하나의 `@JsonKey`만 사용 가능

### @AutoCodingKeys 매크로

구조체나 클래스에 자동 `CodingKeys` 생성을 적용합니다.

```swift
@AutoCodingKeys
struct Settings {
    let theme: String
    let notifications: Bool
    @JsonKey("dark_mode") let isDarkMode: Bool
}
```

**생성되는 코드:**
```swift
struct Settings {
    let theme: String
    let notifications: Bool
    let isDarkMode: Bool
    
    enum CodingKeys: String, CodingKey {
        case theme
        case notifications
        case isDarkMode = "dark_mode"
    }
}

extension Settings: Codable {
}
```

### 프로토콜 준수 자동화

매크로는 누락된 Codable 관련 프로토콜을 자동으로 추가합니다:

```swift
// 기존: Codable 없음 → Codable 추가
@AutoCodingKeys
struct User {
    let name: String
}

// 기존: Encodable만 있음 → Decodable 추가
@AutoCodingKeys
struct Product: Encodable {
    let id: String
}

// 기존: Decodable만 있음 → Encodable 추가
@AutoCodingKeys
struct Config: Decodable {
    let setting: String
}

// 기존: Codable 있음 → 변경 없음
@AutoCodingKeys
struct Data: Codable {
    let value: String
}
```

## ⚠️ 제약사항 및 주의사항

### @JsonKey 매크로
- **변수 선언에만 사용**: 함수, 클래스, 구조체 선언에는 사용 불가
- **문자열 리터럴만 허용**: 변수나 표현식은 인자로 사용 불가
- **빈 문자열 금지**: `@JsonKey("")`는 허용되지 않음
- **중복 사용 금지**: 하나의 프로퍼티에 여러 `@JsonKey` 사용 불가

### @AutoCodingKeys 매크로
- **구조체/클래스에만 사용**: 함수나 다른 선언에는 사용 불가
- **기존 CodingKeys와 충돌**: 이미 `CodingKeys` enum이나 typealias가 있으면 사용 불가
- **저장 프로퍼티만 처리**: 계산 프로퍼티는 자동으로 무시됨
- **최소 하나의 저장 프로퍼티 필요**: 저장 프로퍼티가 없으면 에러 발생
- **고유한 JSON 키 필요**: 모든 JSON 키는 타입 내에서 고유해야 함

## 🧪 예제

### 기본 예제

```swift
import DoraKit

@AutoCodingKeys
struct User {
    @JsonKey("user_name") let name: String
    let age: Int
}

@AutoCodingKeys
struct Product: Codable {
    @JsonKey("product_id") let id: String
    @JsonKey("product_name") let name: String
}

@AutoCodingKeys
struct Settings: Encodable, Hashable {
    @JsonKey("dark_mode") let isDarkMode: Bool
    let theme: String
}
```

### 복잡한 예제

```swift
@AutoCodingKeys
struct APIResponse<T: Codable> {
    @JsonKey("status_code") let statusCode: Int
    @JsonKey("error_message") let errorMessage: String?
    let data: T
    let timestamp: Date
    let success: Bool
    
    // 계산 프로퍼티는 무시됨
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
}
```

## 🔧 개발 환경

### 요구사항
- Swift 6.0+
- macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+, macCatalyst 13+

### 의존성
- [Swift Syntax](https://github.com/swiftlang/swift-syntax) 600.0.0+

## 📁 프로젝트 구조

```
DoraKit/
├── Sources/
│   ├── DoraKit/              # 공개 API
│   │   └── DoraKit.swift     # 매크로 선언
│   ├── DoraKitMacros/        # 매크로 구현
│   │   ├── JsonKeyMacro.swift          # @jsonKey 매크로 구현
│   │   ├── AutoCodingKeysMacro.swift   # @AutoCodingKeys 매크로 구현
│   │   ├── MacroExpansionError.swift   # 에러 타입 정의
│   │   └── DoraKitPlugin.swift         # 컴파일러 플러그인 등록
│   └── DoraKitClient/        # 사용 예제
│       └── main.swift
├── Tests/
│   └── DoraKitTests/         # 테스트 코드
│       └── DoraKitTests.swift
└── Package.swift
```

## 🧪 테스트

프로젝트는 포괄적인 테스트 스위트를 포함합니다:

```bash
swift test
```

테스트는 다음을 포함합니다:
- `@jsonKey` 매크로의 다양한 사용 시나리오
- `@AutoCodingKeys` 매크로의 프로토콜 준수 자동화
- 에러 케이스 및 제약사항 검증
- 복잡한 구조체에서의 동작 확인

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 기능 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

- [Swift Syntax](https://github.com/swiftlang/swift-syntax) 팀에게 감사드립니다
- Swift 매크로 시스템을 가능하게 해준 Swift 팀에게 감사드립니다

---

**DoraKit**으로 JSON 코딩을 더욱 간단하고 안전하게 만들어보세요! 🚀 