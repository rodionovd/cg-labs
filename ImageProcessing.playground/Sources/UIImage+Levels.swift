import UIKit

public extension UIImage
{
    public var MIPLevels: [UIImage]
    {
        let factors: [CGFloat] = [2, 4, 8, 16, 32]
        return [self] + factors.map {
            let size = CGSize(width: self.size.width / $0, height: self.size.height / $0)

            let cgImage = self.cgImage!
            let width = cgImage.width / Int($0)
            let height = cgImage.height / Int($0)
            let bitsPerComponent = cgImage.bitsPerComponent
            let bytesPerRow = cgImage.bytesPerRow
            let colorSpace = cgImage.colorSpace
            let bitmapInfo = cgImage.bitmapInfo

            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)

            context!.interpolationQuality = .high
            context!.draw(cgImage, in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
            
            return context!.makeImage().flatMap({ UIImage(cgImage: $0) })!
        }
    }
}

