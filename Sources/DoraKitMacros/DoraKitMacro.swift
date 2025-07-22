import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros



/// Implementation of the `@jsonKey` macro, which allows you to explicitly specify
/// a custom key name used during encoding/decoding for a specific property.
///
/// This macro acts as a **marker** (metadata-only) and does not generate code directly.
/// Instead, it is meant to be used alongside other macros (e.g. one that auto-generates
/// `CodingKeys`) that will inspect this attribute and map Swift property names to JSON keys.
///
/// Usage:
/// ```swift
/// struct User {
///     @jsonKey("user_name") let name: String
///     let age: Int
/// }
/// ```
///
/// This will guide a future macro to generate:
/// ```swift
/// enum CodingKeys: String, CodingKey {
///     case name = "user_name"
///     case age
/// }
/// ```
///
/// Constraints:
/// - Must be applied only to `let` or `var` declarations
/// - Must be used **inside** a `struct` or `class`
/// - Must take a single `String` literal as argument
/// - Only one `@jsonKey` may be applied per variable

public struct JsonKeyMacro {}

extension JsonKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // 1. Ensure it's attached to a variable declaration
        // 1. let/var 변수 선언에만 사용 가능
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw MacroExpansionError.notVariable
        }
        
        
        // 2. Ensure the argument is a string literal
        // 2. 인자는 반드시 문자열 리터럴이어야 함
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = arguments.first?.expression,
              let stringLiteral = firstArg.as(StringLiteralExprSyntax.self)
        else {
            throw MacroExpansionError.notStringLiteral
        }
        
        // 3. Ensure the argument is not empty value ""
        // 3. 빈 문자열 체크
        let jsonKeyValue = stringLiteral.representedLiteralValue ?? ""
        if jsonKeyValue.isEmpty {
            throw MacroExpansionError.emptyString
        }
        
        
        // 4. Check for duplicate @jsonKey on the same variable
        // 4. 하나의 변수에 @jsonKey가 두 번 이상 붙는 것 방지
        
        let count = variableDecl.attributes.filter {
            $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "jsonKey"
        }.count
        if count > 1 {
            throw MacroExpansionError.duplicateJsonKeyAttribute
        }
        
        return []
    }
}





@main
struct DoraKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonKeyMacro.self,
    ]
}
