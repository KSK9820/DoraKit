import DoraKit

// MARK: - DoraKit Usage Examples
/// This file demonstrates how to use the DoraKit macros for automatic JSON coding key generation.
/// 
/// The examples show:
/// 1. Basic usage with @AutoCodingKeys and @JsonKey
/// 2. Different protocol conformance scenarios
/// 3. Various property naming patterns

// Example 1: Basic User structure with custom JSON key mapping
// 예제 1: 커스텀 JSON 키 매핑이 있는 기본 User 구조체
@AutoCodingKeys
struct User {
    @JsonKey("user_name") let name: String  // Maps to "user_name" in JSON
    let age: Int                            // Maps to "age" in JSON (default)
}

// Example 2: Structure that already conforms to Codable
// 예제 2: 이미 Codable을 채택한 구조체
@AutoCodingKeys
struct A: Codable {
    @JsonKey("Making") let making: String   // Maps to "Making" in JSON
    @JsonKey("CODINGKEY") let codingkey: String  // Maps to "CODINGKEY" in JSON
}

// Example 3: Structure with only Encodable conformance (Decodable will be added automatically)
// 예제 3: Encodable만 채택한 구조체 (Decodable이 자동으로 추가됨)
@AutoCodingKeys
struct B: Encodable, Hashable {
    @JsonKey("is") let IS: String          // Maps to "is" in JSON
    @JsonKey("Finish") let finish: String  // Maps to "Finish" in JSON
}
