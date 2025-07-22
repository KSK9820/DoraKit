// The Swift Programming Language
// https://docs.swift.org/swift-book



// MARK: - JSON Key Mapping
/// A macro that marks a property with a custom key name to be used
/// during JSON encoding or decoding.
///
/// Apply this macro to individual properties that need custom JSON key mapping.
/// The macro acts as a marker and doesn't generate code by itself, but provides
/// metadata for other macros like `@AutoCodingKeys`.
///
/// For example:
/// ```swift
/// struct User: Codable {
///     @jsonKey("user_name") var name: String
///     @jsonKey("user_age") var age: Int
/// }
/// ```
///
/// This tells an external macro (e.g. `@AutoCodingKeys`) to map the `name`
/// property to `"user_name"` and `age` property to `"user_age"` in the
/// generated `CodingKeys` enum.
///
/// - Parameter key: The custom JSON key name to use for this property
/// - Note: The key must be a non-empty string literal
/// - Warning: Cannot be applied to the same property multiple times

@attached(peer)
public macro jsonKey(_ key: String) = #externalMacro(
    module: "DoraKitMacros",
    type: "JsonKeyMacro"
)


// MARK: - Auto generate CodingKeys
/// A macro that automatically generates a `CodingKeys` enum for Codable types.
///
/// Apply this macro to a struct or class that conforms to `Codable`. The macro
/// will scan all stored properties and generate an appropriate `CodingKeys` enum:
/// - Properties marked with `@jsonKey` will use the specified custom key
/// - Properties without `@jsonKey` will use their property name as the key
///
/// For example:
/// ```swift
/// @AutoCodingKeys
/// struct User: Codable {
///     @jsonKey("user_name") let name: String
///     @jsonKey("user_age") let age: Int
///     let email: String        // uses "email" as key
///     let isActive: Bool       // uses "isActive" as key
/// }
/// ```
///
/// This generates:
/// ```swift
/// enum CodingKeys: String, CodingKey {
///     case name = "user_name"
///     case age = "user_age"
///     case email
///     case isActive
/// }
/// ```
///
/// - Note: Only works with stored properties (let/var declarations)
/// - Note: Computed properties are automatically ignored
/// - Warning: All JSON keys must be unique within the same type
/// - Warning: Can only be applied to struct or class declarations

@attached(member, names: named(CodingKeys))
public macro AutoCodingKeys() = #externalMacro(
    module: "DoraKitMacros",
    type: "AutoCodingKeysMacro"
)
