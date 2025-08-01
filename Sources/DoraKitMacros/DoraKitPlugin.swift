import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Main compiler plugin that registers all DoraKit macros
/// 모든 DoraKit 매크로를 등록하는 메인 컴파일러 플러그인
@main
struct DoraKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonKeyMacro.self,
        AutoCodingKeysMacro.self,
    ]
} 