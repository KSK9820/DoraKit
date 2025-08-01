# DoraKit

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20macCatalyst-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

DoraKit is a Swift macro library that provides automated JSON coding key generation for Swift's Codable protocol. Eliminate the need to manually write complex `CodingKeys` enums by using simple macros to automate JSON serialization/deserialization.

## ✨ Key Features

- **Automatic CodingKeys Generation**: Generate `CodingKeys` enums automatically with `@AutoCodingKeys` macro
- **Custom JSON Key Mapping**: Separate Swift property names from JSON key names using `@jsonKey` macro
- **Automatic Protocol Conformance**: Automatically add missing `Codable`, `Encodable`, `Decodable` protocols
- **Type Safety**: Compile-time validation of JSON key duplicates and validity
- **Computed Property Ignoring**: Only stored properties are processed automatically

## 🚀 Quick Start

### Installation

Install using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/DoraKit.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import DoraKit

@AutoCodingKeys
struct User {
    @jsonKey("user_name") let name: String
    @jsonKey("user_age") let age: Int
    let email: String        // maps to "email"
    let isActive: Bool       // maps to "isActive"
    
    var fullName: String {   // computed property is ignored
        "\(name) (\(age))"
    }
}
```

The above code is automatically transformed into:

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

## 📖 Detailed Usage

### @JsonKey Macro

Use this macro to specify custom JSON keys for individual properties.

```swift
struct Product {
    @JsonKey("product_id") let id: String
    @JsonKey("product_name") let name: String
    let price: Double  // maps to "price"
}
```

**Constraints:**
- Can only be applied to `let` or `var` declarations
- Only string literals are allowed as arguments
- Empty strings are not allowed
- Only one `@JsonKey` can be applied per property

### @AutoCodingKeys Macro

Apply this macro to structs or classes for automatic `CodingKeys` generation.

```swift
@AutoCodingKeys
struct Settings {
    let theme: String
    let notifications: Bool
    @JsonKey("dark_mode") let isDarkMode: Bool
}
```

**Generated Code:**
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

### Protocol Conformance Automation

The macro automatically adds missing Codable-related protocols:

```swift
// Existing: No Codable → Codable added
@AutoCodingKeys
struct User {
    let name: String
}

// Existing: Only Encodable → Decodable added
@AutoCodingKeys
struct Product: Encodable {
    let id: String
}

// Existing: Only Decodable → Encodable added
@AutoCodingKeys
struct Config: Decodable {
    let setting: String
}

// Existing: Codable present → No changes
@AutoCodingKeys
struct Data: Codable {
    let value: String
}
```

## ⚠️ Constraints and Warnings

### @JsonKey Macro
- **Variables only**: Cannot be used on functions, classes, or struct declarations
- **String literals only**: Variables or expressions cannot be used as arguments
- **No empty strings**: `@JsonKey("")` is not allowed
- **No duplicates**: Multiple `@JsonKey` cannot be used on the same property

### @AutoCodingKeys Macro
- **Structs/Classes only**: Cannot be used on functions or other declarations
- **CodingKeys conflict**: Cannot be used if `CodingKeys` enum or typealias already exists
- **Stored properties only**: Computed properties are automatically ignored
- **At least one stored property required**: Error occurs if no stored properties exist
- **Unique JSON keys required**: All JSON keys must be unique within the same type

## 🧪 Examples

### Basic Examples

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

### Advanced Examples

```swift
@AutoCodingKeys
struct APIResponse<T: Codable> {
    @JsonKey("status_code") let statusCode: Int
    @JsonKey("error_message") let errorMessage: String?
    let data: T
    let timestamp: Date
    let success: Bool
    
    // Computed property is ignored
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
}
```

## 🔧 Development Environment

### Requirements
- Swift 6.0+
- macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+, macCatalyst 13+

### Dependencies
- [Swift Syntax](https://github.com/swiftlang/swift-syntax) 600.0.0+

## 📁 Project Structure

```
DoraKit/
├── Sources/
│   ├── DoraKit/              # Public API
│   │   └── DoraKit.swift     # Macro declarations
│   ├── DoraKitMacros/        # Macro implementations
│   │   ├── JsonKeyMacro.swift          # @jsonKey macro implementation
│   │   ├── AutoCodingKeysMacro.swift   # @AutoCodingKeys macro implementation
│   │   ├── MacroExpansionError.swift   # Error type definitions
│   │   └── DoraKitPlugin.swift         # Compiler plugin registration
│   └── DoraKitClient/        # Usage examples
│       └── main.swift
├── Tests/
│   └── DoraKitTests/         # Test code
│       └── DoraKitTests.swift
└── Package.swift
```

## 🧪 Testing

The project includes comprehensive test suites:

```bash
swift test
```

Tests include:
- Various usage scenarios for `@jsonKey` macro
- Protocol conformance automation for `@AutoCodingKeys` macro
- Error cases and constraint validation
- Behavior verification in complex structs

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## 📄 License

This project is distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to the [Swift Syntax](https://github.com/swiftlang/swift-syntax) team
- Thanks to the Swift team for making the macro system possible

---

Make JSON coding simpler and safer with **DoraKit**! 🚀 