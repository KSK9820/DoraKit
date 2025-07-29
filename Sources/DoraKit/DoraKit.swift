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
/// A macro that automatically generates a `CodingKeys` enum for Codable types and ensures proper protocol conformance.
///
/// Apply this macro to a struct or class to automatically:
/// 1. Generate an appropriate `CodingKeys` enum based on stored properties
/// 2. Add missing Codable protocol conformance if needed
///
/// **CodingKeys Generation:**
/// - Properties marked with `@jsonKey` will use the specified custom key
/// - Properties without `@jsonKey` will use their property name as the key
/// - Only stored properties (let/var) are included; computed properties are ignored
///
/// **Protocol Conformance:**
/// - If no Codable-related protocols are adopted: adds `Codable`
/// - If only `Encodable` is adopted: adds `Decodable`
/// - If only `Decodable` is adopted: adds `Encodable`
/// - If `Codable` or both `Encodable & Decodable` are already adopted: no changes
///
/// **Example:**
/// ```swift
/// @AutoCodingKeys
/// struct User {  // No Codable needed - macro adds it automatically
///     @jsonKey("user_name") let name: String
///     @jsonKey("user_age") let age: Int
///     let email: String        // uses "email" as key
///     let isActive: Bool       // uses "isActive" as key
///
///     var fullName: String {   // ignored (computed property)
///         "\(name) (\(age))"
///     }
/// }
/// ```
///
/// **Generated code:**
/// ```swift
/// struct User {
///     // ... properties remain the same
///
///     enum CodingKeys: String, CodingKey {
///         case name = "user_name"
///         case age = "user_age"
///         case email
///         case isActive
///     }
/// }
///
/// extension User: Codable {
/// }
/// ```
///
/// - Note: Only works with stored properties (let/var declarations)
/// - Note: Computed properties are automatically ignored
/// - Warning: All JSON keys must be unique within the same type
/// - Warning: Can only be applied to struct or class declarations
/// - Warning: If `CodingKeys` already exists, no extension will be added either

@attached(member, names: named(CodingKeys))
@attached(extension, conformances: Codable, Decodable, Encodable)
public macro AutoCodingKeys() = #externalMacro(
   module: "DoraKitMacros",
   type: "AutoCodingKeysMacro"
)
