//
//  MacroExpansionError.swift
//  DoraKit
//
//  Created by 김수경 on 7/20/25.
//

import Foundation

/// An error type representing failure points in macro expansion.
/// An error type representing validation failures during macro expansion.
enum MacroExpansionError: Error, CustomStringConvertible {
    
    /// The macro was attached to a declaration that is not a variable.
    case notVariable

    /// The macro was applied outside of a `struct` or `class` type.
    case notInsideStructOrClass

    /// The macro argument is not a valid string literal.
    case notStringLiteral
    
    
    /// The macro argument has empty value like ""
    case emptyString

    /// The variable has multiple @jsonKey attributes attached.
    case duplicateJsonKeyAttribute

    /// A fallback for unexpected or unknown macro expansion issues.
    case unknown(String)

    /// Returns a human-readable description of the error to be shown during macro expansion.
    var description: String {
        switch self {
        case .notVariable:
            return "`@jsonKey` can only be attached to a variable declared with `let` or `var`."
        case .notInsideStructOrClass:
            return "`@jsonKey` must be used inside a `struct` or `class` type."
        case .notStringLiteral:
            return "`@jsonKey` requires a string literal as its argument. For example: `@jsonKey(\"custom_key\")`."
        case .emptyString:
            return "`@jsonKey` argument string cannot be empty."
        case .duplicateJsonKeyAttribute:
            return "A variable can have only one `@jsonKey` attribute."
        case .unknown(let reason):
            return "Unknown macro expansion error: \(reason)"
        }
    }
}
