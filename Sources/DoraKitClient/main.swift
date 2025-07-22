import DoraKit


struct User: Codable {
    @jsonKey("user_name") let name: String
    let age: Int
}

