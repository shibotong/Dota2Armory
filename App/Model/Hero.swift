//
//  Hero.swift
//  Dota Portfolio
//
//  Created by Shibo Tong on 5/7/21.
//

import Foundation
import UIKit

class Hero: Identifiable, Decodable {
    var id: Int
    var name: String
    var localizedName: String
    var primaryAttr: String
    var attackType: String
    var roles: [String]
    var legs: Int
    var img: String
    var icon: String
    
    var baseHealth: Int
    var baseHealthRegen: Double
    var baseMana: Int
    var baseManaRegen: Double
    var baseArmor: Double
    var baseMr: Int
    var baseAttackMin: Int
    var baseAttackMax: Int
    var baseStr: Int
    var baseAgi: Int
    var baseInt: Int
    var strGain: Double
    var agiGain: Double
    var intGain: Double
    
    var attackRange: Int
    var projectileSpeed: Int
    var attackRate: Double
    var moveSpeed: Int
    var cmEnabled: Bool
    var turnRate: Double?
    
    static let sample = loadSampleHero()!
    
    var heroNameLowerCase: String {
        return self.name.replacingOccurrences(of: "npc_dota_hero_", with: "")
    }
    
    static let strMaxHP = 20
    static let strHPRegen = 0.1
    
    static let agiArmor = 0.16666666666666667
    static let agiAttackSpeed = 1
    
    static let intMaxMP = 12
    static let intManaRegen = 0.05

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localizedName = "localized_name"
        case primaryAttr = "primary_attr"
        case attackType = "attack_type"
        case roles
        case legs
        case img
        case icon
        
        case baseHealth = "base_health"
        case baseHealthRegen = "base_health_regen"
        case baseMana = "base_mana"
        case baseManaRegen = "base_mana_regen"
        case baseArmor = "base_armor"
        case baseMr = "base_mr"
        case baseAttackMin = "base_attack_min"
        case baseAttackMax = "base_attack_max"
        case baseStr = "base_str"
        case baseAgi = "base_agi"
        case baseInt = "base_int"
        case strGain = "str_gain"
        case agiGain = "agi_gain"
        case intGain = "int_gain"
        
        case attackRange = "attack_range"
        case projectileSpeed = "projectile_speed"
        case attackRate = "attack_rate"
        case moveSpeed = "move_speed"
        case cmEnabled = "cm_enabled"
        case turnRate = "turn_rate"
    }
    
    var calculateHP: Int {
        let hp = self.baseHealth + self.baseStr * Hero.strMaxHP
        return hp
    }
    var calculateHPRegen: Double {
        let regen = self.baseHealthRegen + Double(self.baseStr) * Hero.strHPRegen
        return regen
    }
    
    var calculateMP: Int {
        let mp = self.baseMana + self.baseInt * Hero.intMaxMP
        return mp
    }
    var calculateMPRegen: Double {
        let regen = self.baseManaRegen + Double(self.baseInt) * Hero.intManaRegen
        return regen
    }
    
    var calculatedAttackMin: Int {
        let mainAttributes = self.mainAttributes
        return self.baseAttackMin + mainAttributes
    }
    
    var calculatedAttackMax: Int {
        let mainAttributes = self.mainAttributes
        return self.baseAttackMax + mainAttributes
    }
    
    var calculateArmor: Double {
        let armor = self.baseArmor + Hero.agiArmor * Double(self.baseAgi)
        return armor
    }
    
    var mainAttributes: Int {
        switch self.primaryAttr {
        case "str":
            return self.baseStr
        case "agi":
            return self.baseAgi
        case "int":
            return self.baseInt
        default:
            return 0
        }
    }
    
    var mainAttributesGain: Double {
        switch self.primaryAttr {
        case "str":
            return self.strGain
        case "agi":
            return self.agiGain
        case "int":
            return self.intGain
        default:
            return 0.0
        }
    }
    
    func calculateHPLevel(level: Double) -> Int {
        // 17, 19, 21, 22, 23, 24, 26 +2 all attributes
        var totalStr = self.baseStr + Int((level - 1) * self.strGain)
        if level >= 17 {
            totalStr += 2
        }
        if level >= 19 {
            totalStr += 2
        }
        if level >= 21 {
            totalStr += 2
        }
        if level >= 22 {
            totalStr += 2
        }
        if level >= 23 {
            totalStr += 2
        }
        if level >= 24 {
            totalStr += 2
        }
        if level >= 26 {
            totalStr += 2
        }
        let hp = self.baseHealth + totalStr * Hero.strMaxHP
        return hp
    }
    
    func calculateManaLevel(level: Double) -> Int {
        var totalInt = self.baseInt + Int((level - 1) * self.intGain)
        if level >= 17 {
            totalInt += 2
        }
        if level >= 19 {
            totalInt += 2
        }
        if level >= 21 {
            totalInt += 2
        }
        if level >= 22 {
            totalInt += 2
        }
        if level >= 23 {
            totalInt += 2
        }
        if level >= 24 {
            totalInt += 2
        }
        if level >= 26 {
            totalInt += 2
        }
        let hp = self.baseMana + totalInt * Hero.intMaxMP
        return hp
    }
    
    func calculateHPRegenLevel(level: Double) -> Double {
        let regen = self.baseHealthRegen + Double(self.baseStr) * (level - 1) * Hero.strHPRegen
        return regen
    }
}

class HeroAbility: Decodable {
    var abilities: [String]
    var talents: [Talent]
    
    static let sample = loadSampleHeroAbility()!
}

struct Talent: Decodable {
    var name: String
    var level: Int
}

struct HeroScepter: Decodable {
    var name: String
    var id: Int
    var scepterDesc: String
    var scepterSkillName: String
    var scepterNewSkill: Bool
    var shardDesc: String
    var shardSkillName: String
    var shardNewSkill: Bool
    
    enum CodingKeys: String, CodingKey {
        case name = "hero_name"
        case id = "hero_id"
        case scepterDesc = "scepter_desc"
        case scepterSkillName = "scepter_skill_name"
        case scepterNewSkill = "scepter_new_skill"
        case shardDesc = "shard_desc"
        case shardSkillName = "shard_skill_name"
        case shardNewSkill = "shard_new_skill"
    }
}

