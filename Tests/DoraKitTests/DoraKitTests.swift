import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(DoraKitMacros)
import DoraKitMacros

let testMacros: [String: Macro.Type] = [
    "jsonKey": JsonKeyMacro.self,
]
#endif

final class DoraKitTests: XCTestCase {
    func test_jsonKey_onProperty_shouldSucceed() {
           #if canImport(DoraKitMacros)
           assertMacroExpansion(
               """
               struct User: Codable {
                   @jsonKey("user_name") let name: String
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
    
    /// 1. 변수 선언이 아님
        func test_jsonKey_onNonVariable_shouldFail() {
            #if canImport(DoraKitMacros)
            assertMacroExpansion(
                """
                func foo() {
                    @jsonKey("invalid") print("Hello")
                }
                """,
                expandedSource: "",
                diagnostics: [
                    DiagnosticSpec(
                        message: "`@jsonKey` can only be attached to a variable declared with `let` or `var`.",
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

        /// 2. 문자열 리터럴이 아님
        func test_jsonKey_withNonStringArgument_shouldFail() {
            #if canImport(DoraKitMacros)
            assertMacroExpansion(
                """
                struct User {
                    @jsonKey(123) let name: String
                }
                """,
                expandedSource: "",
                diagnostics: [
                    DiagnosticSpec(
                        message: "`@jsonKey` requires a string literal as its argument. For example: `@jsonKey(\"custom_key\")`.",
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

        /// 3. 빈 문자열
        func test_jsonKey_withEmptyString_shouldFail() {
            #if canImport(DoraKitMacros)
            assertMacroExpansion(
                """
                struct User {
                    @jsonKey("") let name: String
                }
                """,
                expandedSource: "",
                diagnostics: [
                    DiagnosticSpec(
                        message: "`@jsonKey` argument string cannot be empty.",
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

        /// 4. 같은 변수에 중복 @jsonKey
        func test_jsonKey_duplicateOnSameVariable_shouldFail() {
            #if canImport(DoraKitMacros)
            assertMacroExpansion(
                """
                struct User {
                    @jsonKey("name_1") @jsonKey("name_2") let name: String
                }
                """,
                expandedSource: "",
                diagnostics: [
                    DiagnosticSpec(
                        message: "A variable can have only one `@jsonKey` attribute.",
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
}


