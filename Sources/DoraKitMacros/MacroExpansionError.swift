//
//  MacroExpansionError.swift
//  DoraKit
//
//  Created by 김수경 on 7/20/25.
//

import Foundation

/// An error type representing validation failures during macro expansion.
/// 매크로 확장 과정에서 발생하는 유효성 검사 실패를 나타내는 에러 타입
enum MacroExpansionError: Error, CustomStringConvertible {
    
    /// The macro was attached to a declaration that is not a variable.
    /// 매크로가 변수가 아닌 선언에 부착된 경우
    case notVariable
    
    /// The macro was applied outside of a `struct` or `class` type.
    /// 매크로가 `struct` 또는 `class` 타입 외부에서 적용된 경우
    case notStruct
    
    /// The macro argument is not a valid string literal.
    /// 매크로 인자가 유효한 문자열 리터럴이 아닌 경우
    case notStringLiteral
    
    /// The macro argument has empty value like ""
    /// 매크로 인자가 ""와 같은 빈 값을 가지는 경우
    case emptyString
    
    /// The variable has multiple @JsonKey attributes attached.
    /// 변수에 여러 개의 @JsonKey 어트리뷰트가 부착된 경우
    case duplicateJsonKeyAttribute
    
    /// Duplicate JSON key values found across different properties.
    /// 서로 다른 프로퍼티에서 중복된 JSON 키 값이 발견된 경우
    case duplicateJsonKeyValue(String)
    
    /// No stored properties found to generate CodingKeys from.
    /// CodingKeys를 생성할 저장 프로퍼티가 없는 경우
    case noStoredProperties
    
    /// CodingKeys enum already exists in the target type.
    /// 대상 타입에 CodingKeys enum이 이미 존재하는 경우
    case codingKeysAlreadyExists
    
    /// A fallback for unexpected or unknown macro expansion issues.
    /// 예상치 못한 또는 알 수 없는 매크로 확장 문제에 대한 대체 케이스
    case unknown(String)
    
    /// Returns a human-readable description of the error to be shown during macro expansion.
    /// 매크로 확장 중에 표시될 사용자가 읽기 쉬운 에러 설명을 반환
    var description: String {
        switch self {
        case .notVariable:
            return "`@JsonKey` can only be attached to a variable declared with `let` or `var`."
        case .notStruct:
            return "`@AutoCodingKeys` can only be applied to struct declarations."
        case .notStringLiteral:
            return "`@JsonKey` requires a string literal as its argument. For example: `@JsonKey(\"custom_key\")`."
        case .emptyString:
            return "`@JsonKey` argument string cannot be empty."
        case .duplicateJsonKeyAttribute:
            return "A variable can have only one `@JsonKey` attribute."
        case .duplicateJsonKeyValue(let key):
            return "Duplicate JSON key '\(key)' found. Each property must have a unique JSON key."
        case .noStoredProperties:
            return "No stored properties found to generate `CodingKeys`."
        case .codingKeysAlreadyExists:
            return "`CodingKeys` enum already exists. Remove `@AutoCodingKeys` or remove the existing `CodingKeys` declaration."
        case .unknown(let reason):
            return "Unknown macro expansion error: \(reason)"
        }
    }
}
