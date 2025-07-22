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


public struct AutoCodingKeysMacro {}

extension AutoCodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // 1. Ensure it's applied to a struct declaration
        // 1. 구조체인지 확인
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroExpansionError.notStruct
        }
        
        // 2. Check if CodingKeys already exists to prevent duplication
        // 2. 이미 CodingKeys가 존재하는지 확인해서 중복 생성 방지
        if hasCodingKeysDeclaration(in: structDecl) {
            throw MacroExpansionError.codingKeysAlreadyExists
        }
        
        // 3. Extract all stored properties from the struct
        // 3. 구조체에서 모든 저장 프로퍼티 추출
        let properties = try extractStoredProperties(from: structDecl)
        
        // 4. Generate the CodingKeys enum based on collected properties
        // 4. 수집된 프로퍼티를 기반으로 CodingKeys enum 생성
        let codingKeysEnum = try generateCodingKeysEnum(from: properties)
        
        return [DeclSyntax(codingKeysEnum)]
    }
    
    /// Check if CodingKeys declaration already exists in the struct
    /// 구조체 내부에 이미 CodingKeys 선언이 있는지 확인
    private static func hasCodingKeysDeclaration(in structDecl: StructDeclSyntax) -> Bool {
        for member in structDecl.memberBlock.members {
            // Check for enum CodingKeys declaration
            // enum CodingKeys 선언 확인
            if let enumDecl = member.decl.as(EnumDeclSyntax.self),
               enumDecl.name.text == "CodingKeys" {
                return true
            }
            
            // Check for typealias CodingKeys declaration (in case user aliased another type as CodingKeys)
            // typealias CodingKeys 선언 확인 (사용자가 다른 타입을 CodingKeys로 alias한 경우)
            if let typealiasDecl = member.decl.as(TypeAliasDeclSyntax.self),
               typealiasDecl.name.text == "CodingKeys" {
                return true
            }
        }
        return false
    }
    
    // PropertyInfo 구조체 정의
    struct PropertyInfo {
        let name: String
        let jsonKey: String?
        
        var codingKeyName: String {
            return jsonKey ?? name
        }
    }

    private static func extractStoredProperties(from structDecl: StructDeclSyntax) throws -> [PropertyInfo] {
        var properties: [PropertyInfo] = []
        var usedJsonKeys: Set<String> = []
        
        // Iterate through all members of the struct
        // 구조체의 모든 멤버를 순회
        for member in structDecl.memberBlock.members {
            // Only process variable declarations (let/var) and exclude computed properties
            // 변수 선언(let/var)만 처리하고 계산 프로퍼티는 제외
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self),
                  // stored property만 처리 (computed property 제외)
                  variableDecl.bindings.first?.accessorBlock == nil else {
                continue
            }
            
            // Extract property name from the pattern
            // 패턴에서 프로퍼티 이름 추출
            guard let binding = variableDecl.bindings.first,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }
            
            let propertyName = pattern.identifier.text
            
            // Check for @jsonKey attribute and extract its value
            // @jsonKey 어트리뷰트 확인 및 값 추출
            let jsonKey = extractJsonKey(from: variableDecl)
            
            // Check for duplicate keys to prevent conflicts
            // 중복 키 검사로 충돌 방지
            let finalKey = jsonKey ?? propertyName
            if usedJsonKeys.contains(finalKey) {
                throw MacroExpansionError.duplicateJsonKeyValue(finalKey)
            }
            usedJsonKeys.insert(finalKey)
            
            properties.append(PropertyInfo(name: propertyName, jsonKey: jsonKey))
        }
        
        return properties
    }

    private static func extractJsonKey(from variableDecl: VariableDeclSyntax) -> String? {
        // Search through all attributes on the variable declaration
        // 변수 선언의 모든 어트리뷰트를 검색
        for attribute in variableDecl.attributes {
            // Check if it's a jsonKey attribute with proper syntax
            // jsonKey 어트리뷰트이고 올바른 문법인지 확인
            guard let attributeSyntax = attribute.as(AttributeSyntax.self),
                  attributeSyntax.attributeName.trimmedDescription == "jsonKey",
                  let arguments = attributeSyntax.arguments?.as(LabeledExprListSyntax.self),
                  let firstArg = arguments.first?.expression,
                  let stringLiteral = firstArg.as(StringLiteralExprSyntax.self) else {
                continue
            }
            
            // Return the string literal value
            // 문자열 리터럴 값 반환
            return stringLiteral.representedLiteralValue
        }
        return nil
    }
    
    private static func generateCodingKeysEnum(from properties: [PropertyInfo]) throws -> EnumDeclSyntax {
        // Create the CodingKeys enum using the simpler syntax
        // 더 간단한 문법을 사용해서 CodingKeys enum 생성
        let enumDecl = try EnumDeclSyntax("enum CodingKeys: String, CodingKey") {
            // Generate enum cases for each property
            // 각 프로퍼티에 대한 enum case 생성
            for property in properties {
                if let jsonKey = property.jsonKey {
                    // Generate case with custom raw value: case name = "json_key"
                    // 커스텀 raw value가 있는 case 생성: case name = "json_key"
                    try EnumCaseDeclSyntax("case \(raw: property.name) = \(literal: jsonKey)")
                } else {
                    // Generate simple case without raw value: case name
                    // raw value 없는 단순 case 생성: case name
                    try EnumCaseDeclSyntax("case \(raw: property.name)")
                }
            }
        }
        
        return enumDecl
    }
}


@main
struct DoraKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonKeyMacro.self,
        AutoCodingKeysMacro.self,
    ]
}
