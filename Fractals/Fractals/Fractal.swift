//
//  Fractal.swift
//  Fractals
//
//  Created by Dmitry Rodionov on 07/11/2016.
//  Copyright © 2016 Internals Exposed. All rights reserved.
//

import Foundation

struct Fractal {
    let step: CGFloat
    let angle: CGFloat
    let source: String

    typealias Rule = (lhs: String, rhs: String)

    init (axiom: String, rules: [Rule], angle: CGFloat, stepSize: CGFloat, iterations: Int)
    {
        self.angle = angle
        self.step = stepSize
        self.source = fractalSource(fromAxiom: axiom, rules: rules, iterations: iterations)
    }
}

private func fractalSource(fromAxiom axiom: String, rules: [Fractal.Rule], iterations: Int) -> String
{
    var result = axiom
    for _ in 0..<iterations {
        result = transform(input: result, usingRules: rules)
    }
    return result
}

private func transform(input: String, usingRules rules: [Fractal.Rule]) -> String
{
    var result = ""
    for (_, c) in input.characters.enumerated() {

        switch c {
        case "+":
            result += "+"
        case "-":
            result += "-"
        case "[":
            result += "["
        case "]":
            result += "]"
        default:
            if let rule = rules.first(where: { return $0.lhs == String(c) }) {
                result += rule.rhs
            } else {
                result += String(c)
            }
        }
    }
    return result
//    return rules.reduce(input) {
//        return $0.replacingOccurrences(of: $1.lhs, with: $1.rhs)
//    }
}
