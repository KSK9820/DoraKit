import DoraKit


@AutoCodingKeys
struct User {
    @jsonKey("user_name") let name: String
    let age: Int
}

@AutoCodingKeys
struct A: Codable {
    @jsonKey("aa") let a: String
}

@AutoCodingKeys
struct B: Encodable {
    @jsonKey("bb") let b: String
}

