import DoraKit


@AutoCodingKeys
struct User {
    @jsonKey("user_name") let name: String
    let age: Int
}

@AutoCodingKeys
struct A: Codable {
    @jsonKey("Making") let making: String
    @jsonKey("CODINGKEY") let codingkey: String
}

@AutoCodingKeys
struct B: Encodable, Hashable {
    @jsonKey("is") let IS: String
    @jsonKey("Finish") let finish: String
}
