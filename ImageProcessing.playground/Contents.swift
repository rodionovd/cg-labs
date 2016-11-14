import Foundation
import UIKit
import CoreGraphics
import CoreImage
import GLKit

//let f = [Point(x: 1, y: 1), Point(x: 2, y: 3), Point(x: 3, y: 1)]
//let s = [Point(x: 1.9, y: 3.9), Point(x: 4.1, y: 3), Point(x: 4.5, y: 1.9)]
//
//let matrix = AffineTransformMatrix(from: f, to: s)

let matrix = AffineTransformMatrix(matrix: [
    [0.5, 0.1, 0.0],
    [-0.1, 0.25, 0.0],
    [0.0, 0.0, 1.0]
])
matrix.scale

let source = UIImage(named: "image2.jpg")!

let transform = AffineTransform(matrix: matrix)
let result = transform.apply(toImage: source)

let a = CGAffineTransform(a: CGFloat(matrix[0, 0]), b: CGFloat(matrix[0, 1]),
                          c: CGFloat(matrix[1, 0]), d: CGFloat(matrix[1, 1]),
                          tx: CGFloat(matrix[2, 0]), ty: CGFloat(matrix[2, 1]))
let sourceCI = CIImage(cgImage: source.cgImage!)
let check = UIImage(ciImage: sourceCI.applying(a))

//
source
//
result
//
check




