import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
// 매크로 구현은 호스트용으로 빌드되므로, 크로스 컴파일 시 해당 모듈을 사용할 수 없습니다.
// 크로스 컴파일된 테스트는 end-to-end 테스트에서 매크로 자체를 사용할 수 있습니다.
#if canImport(DoraKitMacros)
import DoraKitMacros

// Test macros mapping
// 테스트 매크로 매핑
let testMacros: [String: Macro.Type] = [
    "jsonKey": JsonKeyMacro.self,
    "AutoCodingKeys": AutoCodingKeysMacro.self,
]
#endif

final class DoraKitTests: XCTestCase {
    // MARK: - JsonKey Macro Tests / JsonKey 매크로 테스트
    
    // Test: @JsonKey on property should succeed
    // 테스트: 프로퍼티에 @JsonKey 사용 시 성공
    func test_jsonKey_onProperty_shouldSucceed() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            struct User: Codable {
                @JsonKey("user_name") let name: String
            }
            """,
            expandedSource: """
            struct User: Codable {
                let name: String
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // Test 1: Not attached to a variable declaration
    // 테스트 1: 변수 선언이 아닌 곳에 사용
    func test_jsonKey_onNonVariable_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            func foo() {
                @JsonKey("invalid") print("Hello")
            }
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    message: "`@JsonKey` can only be attached to a variable declared with `let` or `var`.",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test 2: Non-string literal argument
    // 테스트 2: 문자열 리터럴이 아닌 인자 사용
    func test_jsonKey_withNonStringArgument_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            struct User {
                @JsonKey(123) let name: String
            }
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    message: "`@JsonKey` requires a string literal as its argument. For example: `@JsonKey(\"custom_key\")`.",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test 3: Empty string argument
    // 테스트 3: 빈 문자열 인자
    func test_jsonKey_withEmptyString_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            struct User {
                @JsonKey("") let name: String
            }
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    message: "`@JsonKey` argument string cannot be empty.",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test 4: Duplicate @JsonKey on same variable
    // 테스트 4: 같은 변수에 중복된 @JsonKey 사용
    func test_jsonKey_duplicateOnSameVariable_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            struct User {
                @JsonKey("name_1") @JsonKey("name_2") let name: String
            }
            """,
            expandedSource: "",
            diagnostics: [
                DiagnosticSpec(
                    message: "A variable can have only one `@JsonKey` attribute.",
                    line: 2,
                    column: 19
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: - AutoCodingKeys Member Macro Tests / AutoCodingKeys 멤버 매크로 테스트
    
    // Test: Should generate correct CodingKeys with mixed properties
    // 테스트: 혼합된 프로퍼티로 올바른 CodingKeys 생성
    func test_autoCodingKeys_shouldGenerateCorrectCodingKeys() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Codable {
                @JsonKey("user_name") let name: String
                @JsonKey("user_age") let age: Int
                let email: String
                let isActive: Bool
            }
            """,
            expandedSource: """
            struct User: Codable {
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
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // Test: All properties have @JsonKey
    // 테스트: 모든 프로퍼티가 @JsonKey를 가진 경우
    func test_autoCodingKeys_withOnlyJsonKeyProperties() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct Product: Codable {
                @JsonKey("product_id") let id: String
                @JsonKey("product_name") let name: String
            }
            """,
            expandedSource: """
            struct Product: Codable {
                let id: String
                let name: String
            
                enum CodingKeys: String, CodingKey {
                    case id = "product_id"
                    case name = "product_name"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test: No properties have @JsonKey
    // 테스트: @JsonKey가 없는 프로퍼티만 있는 경우
    func test_autoCodingKeys_withNoJsonKeyProperties() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct Settings: Codable {
                let theme: String
                let notifications: Bool
            }
            """,
            expandedSource: """
            struct Settings: Codable {
                let theme: String
                let notifications: Bool
            
                enum CodingKeys: String, CodingKey {
                    case theme
                    case notifications
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test: CodingKeys already exists - should fail
    // 테스트: CodingKeys가 이미 존재하는 경우 - 실패해야 함
    func test_autoCodingKeys_withExistingCodingKeys_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Codable {
                @JsonKey("user_name") let name: String
                let age: Int
                
                enum CodingKeys: String, CodingKey {
                    case name = "user_name"
                    case age
                }
            }
            """,
            expandedSource: """
            @AutoCodingKeys
            struct User: Codable {
                @JsonKey("user_name") let name: String
                let age: Int
                
                enum CodingKeys: String, CodingKey {
                    case name = "user_name"
                    case age
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "`CodingKeys` enum already exists. Remove `@AutoCodingKeys` or remove the existing `CodingKeys` declaration.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // Test: CodingKeys typealias already exists - should fail
    // 테스트: CodingKeys typealias가 이미 존재하는 경우 - 실패해야 함
    func test_autoCodingKeys_withExistingCodingKeysTypealias_shouldFail() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Codable {
                @JsonKey("user_name") let name: String
                let age: Int
                
                typealias CodingKeys = String
            }
            """,
            expandedSource: """
            @AutoCodingKeys
            struct User: Codable {
                @JsonKey("user_name") let name: String
                let age: Int
                
                typealias CodingKeys = String
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "`CodingKeys` enum already exists. Remove `@AutoCodingKeys` or remove the existing `CodingKeys` declaration.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: - AutoCodingKeys Extension Macro Tests / AutoCodingKeys Extension 매크로 테스트
    
    // Test 1: Default behavior - automatically adopt Codable
    // 테스트 1: 기본 동작 - Codable 자동 채택
    func test_autoCodingKeys_shouldAddCodableConformance() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User {
                let name: String
                let age: Int
            
                enum CodingKeys: String, CodingKey {
                    case name
                    case age
                }
            }
            
            extension User: Codable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // Test 2: Already conforms to Codable - should not add extension
    // 테스트 2: 이미 Codable을 채택한 경우 - extension 생성하지 않음
    func test_autoCodingKeys_withExistingCodable_shouldNotAddExtension() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Codable {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User: Codable {
                let name: String
                let age: Int
            
                enum CodingKeys: String, CodingKey {
                    case name
                    case age
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // Test 3: Only has Encodable - should add Decodable
    // 테스트 3: Encodable만 있는 경우 - Decodable만 추가
    func test_autoCodingKeys_withEncodableOnly_shouldAddDecodable() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Encodable {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User: Encodable {
                let name: String
                let age: Int
            
                enum CodingKeys: String, CodingKey {
                    case name
                    case age
                }
            }
            
            extension User: Decodable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // Test 4: Only has Decodable - should add Encodable
    // 테스트 4: Decodable만 있는 경우 - Encodable만 추가
    func test_autoCodingKeys_withDecodableOnly_shouldAddEncodable() {
        #if canImport(DoraKitMacros)
        assertMacroExpansion(
            """
            @AutoCodingKeys
            struct User: Decodable {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User: Decodable {
                let name: String
                let age: Int
            
                enum CodingKeys: String, CodingKey {
                    case name
                    case age
                }
            }
            
            extension User: Encodable {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
