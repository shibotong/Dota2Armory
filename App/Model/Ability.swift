//
//  Ability.swift
//  App
//
//  Created by Shibo Tong on 12/9/21.
//

import Foundation

struct Ability: Codable, Identifiable {
    var id = UUID()
    
    var img: String?
    var dname: String?
    var desc: String?
    var attributes: [AbilityAttribute]?
    var behavior: StringOrArray?
    var damageType: StringOrArray?
    var bkbPierce: StringOrArray?
    var lore: String?
    var manaCost: StringOrArray?  // mana cost can be String or [String]
    var dispellable: StringOrArray?
    var coolDown: StringOrArray?  // CD can be String or [String]
    var targetTeam: StringOrArray?
    var targetType: StringOrArray?
    
    enum CodingKeys: String, CodingKey {
        case img = "img"
        case dname
        case desc
        case attributes = "attrib"
        case behavior
        case damageType = "dmg_type"
        case bkbPierce = "bkbpierce"
        case lore
        case manaCost = "mc"
        case dispellable
        case coolDown = "cd"
        case targetTeam = "target_team"
        case targetType = "target_type"
    }
}

struct AbilityAttribute: Codable, Hashable {
    
    var key: String?
    var header: String?
    var value: StringOrArray?
    var generated: Bool?
    
    enum CodingKeys: String, CodingKey {
        case key
        case header
        case value
        case generated
    }
    
    static func == (lhs: AbilityAttribute, rhs: AbilityAttribute) -> Bool {
        return lhs.key == rhs.key
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

enum StringOrArray: Codable {
    case string(String)
    case array([String])
    
    init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let array = try? decoder.singleValueContainer().decode([String].self) {
            self = .array(array)
            return
        }
        throw Error.couldNotFindStringOrArray
    }
    
    enum Error: Swift.Error {
        case couldNotFindStringOrArray
    }
    
    func transformString() -> String {
        switch self {
        case .string(let string):
            return string
        case .array(let array):
            return array.joined(separator: "/")
        }
    }
}

struct AbilityContainer: Identifiable {
    var id = UUID()
    var ability: Ability
    var heroID: Int
    var abilityName: String
}
