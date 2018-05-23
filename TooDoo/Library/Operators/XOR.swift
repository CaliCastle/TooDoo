//
//  XOR.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

precedencegroup BooleanPrecedence { associativity: left }
infix operator ^^ : BooleanPrecedence
/**
 Swift Logical XOR operator
 ```
 true  ^^ true   // false
 true  ^^ false  // true
 false ^^ true   // true
 false ^^ false  // false
 ```
 - parameter lhs: First value.
 - parameter rhs: Second value.
 */
func ^^(lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}
