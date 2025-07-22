// The Swift Programming Language
// https://docs.swift.org/swift-book



/// A macro that marks a property with a custom key name to be used
/// during JSON encoding or decoding.
///
/// For example:
/// ```swift
/// struct User {
///     @jsonKey("user_name") var name: String
/// }
/// ```
///
/// This tells an external macro (e.g. `@CodingKeyed`) to map the `name`
/// property to `"user_name"` in the generated `CodingKeys` enum.

@attached(peer)
public macro jsonKey(_ key: String) = #externalMacro(
    module: "DoraKitMacros",
    type: "JsonKeyMacro"
)
