// Copyright 2016 Marius Horga
// https://github.com/mhorga/ImageProcessing
import UIKit

public struct Pixel {
    var value: UInt32
    var red: UInt8 {
        get { return UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    var green: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    var alpha: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }

    public static func +(lhs: Pixel, rhs: Pixel) -> Pixel
    {
//        return Pixel(value: lhs.value + rhs.value)
        var result = Pixel(value: lhs.value)
        result.red = UInt8(min(255, UInt16(lhs.red) + UInt16(rhs.red)))
        result.green = UInt8(min(255, UInt16(lhs.green) + UInt16(rhs.green)))
        result.blue = UInt8(min(255, UInt16(lhs.blue) + UInt16(rhs.blue)))
        result.alpha = UInt8(min(255, UInt16(lhs.alpha) + UInt16(rhs.alpha)))
        return result
    }

    public static func *(lhs: Pixel, rhs: Float) -> Pixel
    {
        var result = Pixel(value: lhs.value)
        result.red = UInt8(min(255, Float(lhs.red) * rhs))
        result.green = UInt8(min(255, Float(lhs.green) * rhs))
        result.blue = UInt8(min(255, Float(lhs.blue) * rhs))
        result.alpha = UInt8(min(255, Float(lhs.alpha) * rhs))
        return result
    }
}

public struct RGBA {
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var width: Int
    var height: Int

    public subscript(x: Int, y: Int) -> Pixel {
        get {
            let index = y * width + x
            return pixels[index]
        }
        set {
            let index = y * width + x
            pixels[index] = newValue
        }
    }
    
    init?(image: UIImage, size: CGSize? = nil) {
        guard let cgImage = image.cgImage else { return nil }
        width = Int(size?.width ?? image.size.width)
        height = Int(size?.height ?? image.size.height)
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint(x: 0,y :0), size: size ?? image.size))
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        guard let cgImage = imageContext!.makeImage() else {return nil}
        let image = UIImage(cgImage: cgImage)
        return image
    }
}

public func contrast(image: UIImage) -> RGBA {
    let rgba = RGBA(image: image)!
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            totalRed += Int(pixel.red)
            totalGreen += Int(pixel.green)
            totalBlue += Int(pixel.blue)
        }
    }
    
    let pixelCount = rgba.width * rgba.height
    let avgRed = totalRed / pixelCount
    let avgGreen = totalGreen / pixelCount
    let avgBlue = totalBlue / pixelCount
    
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            var pixel = rgba.pixels[index]
            let redDelta = Int(pixel.red) - avgRed
            let greenDelta = Int(pixel.green) - avgGreen
            let blueDelta = Int(pixel.blue) - avgBlue
            pixel.red = UInt8(max(min(255, avgRed + 3 * redDelta), 0))
            pixel.green = UInt8(max(min(255, avgGreen + 3 * greenDelta), 0))
            pixel.blue = UInt8(max(min(255, avgBlue + 3 * blueDelta), 0))
            rgba.pixels[index] = pixel
        }
    }
    return rgba
}
