import UIKit
import ImageIO

public struct AffineTransform
{
    public let matrix: AffineTransformMatrix

    public init(matrix: AffineTransformMatrix)
    {
        self.matrix = matrix
    }

    public func apply(toImage image: UIImage) -> UIImage?
    {
        if matrix.scale >= 0.99 {
            return applyBilinear(toImage: image)
        } else {
            return applyTrilinear(toImage: image)
        }
    }

    private func applyBilinear(toImage image: UIImage) -> UIImage?
    {
        guard let invertedMatrix = matrix.inverted else {
            return nil
        }

        let size = matrix.sizeOfTransformed(rectOfSize: image.size)
        guard var rgba = RGBA(image: image, size: size), let original = RGBA(image: image) else {
            return nil
        }

        for x in 0..<Int(rgba.width) {
            for y in 0..<Int(rgba.height) {
                // Transform a point on the destination image back to a point on the source image
                let (xf, yf) = invertedMatrix.apply(toPoint: (Float(x), Float(y)))
                if (xf < 0.0 || ceilf(xf) >= Float(original.width) || yf < 0.0 || ceilf(yf) >= Float(original.height)) {
                    rgba[x, y] = Pixel(value: 0)
                    continue
                }
                // Calculate a pixel to be drawn here
                rgba[x, y] = billinearFilter(x: xf, y: yf, from: original)
            }
        }
        return rgba.toUIImage()
    }

    private func billinearFilter(x: Float, y: Float, from image: RGBA) -> Pixel
    {
        let xl = floorf(x), xh = xl + 1
        let yl = floorf(y), yh = yl + 1

        return (image[Int(xl), Int(yl)] * (xh - x) + image[Int(xh), Int(yl)] * (x - xl)) * (yh - y)
             + (image[Int(xl), Int(yh)] * (xh - x) + image[Int(xh), Int(yh)] * (x - xl)) * (y - yl)
    }

    private func applyTrilinear(toImage image: UIImage) -> UIImage?
    {
        guard let invertedMatrix = matrix.inverted else {
            return nil
        }

        let size = matrix.sizeOfTransformed(rectOfSize: image.size)
        guard var rgba = RGBA(image: image, size: size), let original = RGBA(image: image) else {
            return nil
        }

        let levels = image.MIPLevels.flatMap { RGBA(image: $0) }

        for x in 0..<Int(rgba.width) {
            for y in 0..<Int(rgba.height) {
                let (xf, yf) = invertedMatrix.apply(toPoint: (Float(x), Float(y)))
                if (xf < 0.0 || ceilf(xf) >= Float(original.width) || yf < 0.0 || ceilf(yf) >= Float(original.height)) {
                    rgba[x, y] = Pixel(value: 0)
                    continue
                }
                //
                let (xn, yn) = (x+1 < Int(rgba.width) ? x+1 : x-1, y+1 < Int(rgba.height) ? y+1 : y-1)
                let (xnf, ynf) = invertedMatrix.apply(toPoint: (Float(xn), Float(yn)))
                //
                let kx = abs(xf - xnf) / Float(abs(x - xn))
                let ky = abs(yf - ynf) / Float(abs(y - yn))
                //
                let k = (kx + ky) / 2
                if abs(k - 1.0) < 0.01 {
                    rgba[x, y] = original[Int(xf), Int(yf)]
                    continue
                }
                let m  = Int(pow(2, floor(log2(k-1))))
                let m2 = m * 2
                //
                let im  = levels[Int(log2f(Float(m)))][Int(xf)/m, Int(yf)/m]
                let im2 = levels[Int(log2f(Float(m2)))][Int(xf)/m2, Int(yf)/m2]
                //
                let h1 = im  * (Float((m2 - Int(k))) / Float(m))
                let h2 = im2 * (Float((Int(k) - m)) / Float(m))
                rgba[x, y] = h1 + h2
            }
        }
        return rgba.toUIImage()
    }
}
