import Foundation
import GLKit

public struct Point: Equatable
{
    public let x: Float
    public let y: Float

    public init (x: Float, y: Float)
    {
        self.x = x
        self.y = y
    }

    public static func ==(lhs: Point, rhs: Point) -> Bool
    {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

public struct AffineTransformMatrix: CustomDebugStringConvertible
{
    private let matrix: GLKMatrix3

    public var inverted: AffineTransformMatrix? {
        var isInvertible = false
        let invertedRaw = GLKMatrix3Invert(matrix, &isInvertible)
        guard isInvertible else {
            return nil
        }
        return AffineTransformMatrix(matrix: invertedRaw)
    }

    public var scaleX: Float {
        return self[0, 0]
    }

    public var scaleY: Float {
        return self[1, 1]
    }

    public func apply(toPoint point: (x: Float, y: Float)) -> (x: Float, y: Float)
    {
        return (
            point.x * self[0, 0] + point.y * self[1, 0] + self[2, 0],
            point.x * self[0, 1] + point.y * self[1, 1] + self[2, 1]
        )
    }

    public func sizeOfTransformed(rectOfSize size: CGSize) -> CGSize
    {
        let upleft = apply(toPoint: (0, 0))
        let upright = apply(toPoint: (Float(size.width), 0))
        let downleft = apply(toPoint: (0, Float(size.height)))
        let downright = apply(toPoint: (Float(size.width), Float(size.height)))

        let points = [upleft, upright, downleft, downright]
        let minX = points.sorted(by: { $0.x < $1.x }).first!.x
        let maxX = points.sorted(by: { $0.x > $1.x }).first!.x
        let minY = points.sorted(by: { $0.y < $1.y }).first!.y
        let maxY = points.sorted(by: { $0.y > $1.y }).first!.y

        return CGSize(width: CGFloat(ceilf(maxX - minX)), height: CGFloat(ceilf(maxY - minY)))
    }


    public var debugDescription: String {
        var d = ""
        d += "\(GLKMatrix3GetRow(matrix, 0).v.0) \(GLKMatrix3GetRow(matrix, 0).v.1) \(GLKMatrix3GetRow(matrix, 0).v.2), "
        d += "\(GLKMatrix3GetRow(matrix, 1).v.0) \(GLKMatrix3GetRow(matrix, 1).v.1) \(GLKMatrix3GetRow(matrix, 1).v.2), "
        d += "\(GLKMatrix3GetRow(matrix, 2).v.0) \(GLKMatrix3GetRow(matrix, 2).v.1) \(GLKMatrix3GetRow(matrix, 2).v.2)"
        return d
    }

    public subscript(row: Int, column: Int) -> Float
    {
        let rowValues = GLKMatrix3GetRow(matrix, Int32(row))
        switch column {
        case 0:
            return rowValues.v.0
        case 1:
            return rowValues.v.1
        case 2:
            return rowValues.v.2
        default:
            fatalError()
        }
    }

    // TODO: review this
    public var scale: Float {
        let x1 = self[0, 0]
        let y1 = self[1, 0]

        let x2 = self[0, 0] + self[0, 1] + self[0, 2]
        let y2 = self[1, 0] + self[1, 1] + self[1, 2]

        return Float(sqrt(pow(Double(x2 - x1), 2) + pow(Double(y2 - y1), 2)))
    }

    public init(from firstPoints: [Point], to secondPoints: [Point])
    {
        // RESULT = ORIGINAL * TRANSFORM
        // TRANSFORM = inverse(ORIGINAL) * RESULT
        var invertible = false
        let main = GLKMatrix3Invert(GLKMatrix3(m: (
            firstPoints[0].x, firstPoints[1].x, firstPoints[2].x,
            firstPoints[0].y, firstPoints[1].y, firstPoints[2].y,
                         1.0,              1.0,              1.0
        )), &invertible)
        precondition(invertible == true)

        let a = GLKMatrix3MultiplyVector3(main, GLKVector3(v: (secondPoints[0].x, secondPoints[1].x, secondPoints[2].x)))
        let b = GLKMatrix3MultiplyVector3(main, GLKVector3(v: (secondPoints[0].y, secondPoints[1].y, secondPoints[2].y)))

        self.matrix = GLKMatrix3(m: (
            a.v.0, a.v.1, a.v.2,
            b.v.0, b.v.1, b.v.2,
            0.0,     0.0,   1.0
        ))
    }

    public init(matrix: [[Float]])
    {
        self.matrix = GLKMatrix3(m: (
            matrix[0][0], matrix[0][1], matrix[0][2],
            matrix[1][0], matrix[1][1], matrix[1][2],
            matrix[2][0], matrix[2][1], matrix[2][2]
        ))
    }

    private init(matrix: GLKMatrix3)
    {
        self.matrix = matrix
    }
}


