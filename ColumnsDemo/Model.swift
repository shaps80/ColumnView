import UIKit

struct Contact {
    
    struct KeyValue {
        var key: String
        var value: String
    }
    
    var id: Int
    var color: UIColor
    var name: String
    var email: String
    var kind: String = "Contact"
    var created = Date()
    var modified = Date()
    
    init(id: Int) {
        self.id = id
        self.name = Lorem.fullName
        self.email = Lorem.emailAddress
        color = .random
    }
    
    var keyValuePairs: [KeyValue] {
        return [
            ("kind", kind),
            ("name", name),
            ("email", email),
            ("created", "\(created)"),
            ("modified", "\(modified)"),
        ].map { KeyValue(key: $0.0, value: $0.1) }
    }
    
}

struct Folder {
    
    var id: Int
    var color: UIColor
    var name: String
    var contacts: [Contact]
    
    init(id: Int) {
        self.id = id
        name = Lorem.title
        color = .random
        
        contacts = (0..<50)
            .map { Contact(id: $0) }
    }
    
}

struct Model {
    
    var folders: [Folder]
    
    init() {
        folders = (0..<20)
            .map { Folder(id: $0) }
    }
    
}
