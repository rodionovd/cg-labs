import Foundation
import UIKit
import CoreGraphics
import CoreImage
import GLKit

//let f = [                    Point(x: 2, y: 3),
//          Point(x: 1, y: 1),                    Point(x: 3, y: 1)]
//
//let s = [                    Point(x: 4.1, y: 3),
//          Point(x: 0.0, y: 0.5),                Point(x: 4.5, y: 0.5)]
////
//let matrix = AffineTransformMatrix(from: f, to: s)

//matrix

let f = CGFloat(10.0 * M_PI / 180)

let matrix = AffineTransformMatrix(matrix: [
    [Float(cos(f)), Float(sin(f)), 0.0],
    [Float(-sin(f)), Float(cos(f)), 0.0],
    [0.0, 0.0, 1.0]
])

//let matrix = AffineTransformMatrix(matrix: [
//    [2, 0, 0.0],
//    [0, 2, 0.0],
//    [0.0, 0.0, 1.0]
//])

let source = UIImage(named: "image.jpg")!

let transform = AffineTransform(matrix: matrix)
let result = transform.apply(toImage: source)

//
source
//
result
////
//let a = CGAffineTransform(a: CGFloat(matrix[0, 0]), b: CGFloat(matrix[0, 1]),
//                          c: CGFloat(matrix[1, 0]), d: CGFloat(matrix[1, 1]),
//                          tx: CGFloat(matrix[2, 0]), ty: CGFloat(matrix[2, 1]))
//let sourceCI = CIImage(cgImage: source.cgImage!)
//let check = UIImage(ciImage: sourceCI.applying(a))
//check




