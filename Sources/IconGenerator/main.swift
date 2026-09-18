import CoreGraphics
import Foundation
import ImageIO
import UnportCore
import UniformTypeIdentifiers

// Renders the PNGs of an .iconset directory; `iconutil` turns that into AppIcon.icns.

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: IconGenerator <output.iconset>\n".utf8))
    exit(64)
}

let iconset = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func renderIcon(pixels: Int) -> CGImage {
    let side = CGFloat(pixels)
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let context = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!

    // macOS icon grid: the rounded tile is inset ~10% from the canvas.
    let tile = CGRect(x: 0, y: 0, width: side, height: side).insetBy(dx: side * 0.098, dy: side * 0.098)
    context.addPath(CGPath(roundedRect: tile, cornerWidth: tile.width * 0.225, cornerHeight: tile.width * 0.225, transform: nil))
    context.clip()
    let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [CGColor(red: 0.16, green: 0.20, blue: 0.29, alpha: 1), CGColor(red: 0.05, green: 0.07, blue: 0.11, alpha: 1)] as CFArray,
        locations: [0, 1]
    )!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: tile.maxY), end: CGPoint(x: 0, y: tile.minY), options: [])

    context.addPath(EthernetPortIcon.path(in: tile.insetBy(dx: tile.width * 0.17, dy: tile.width * 0.17)))
    context.setFillColor(CGColor(red: 0.36, green: 0.89, blue: 0.62, alpha: 1))
    context.fillPath(using: .evenOdd)

    return context.makeImage()!
}

for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let name = scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
        let destination = CGImageDestinationCreateWithURL(
            iconset.appendingPathComponent(name) as CFURL, UTType.png.identifier as CFString, 1, nil
        )!
        CGImageDestinationAddImage(destination, renderIcon(pixels: points * scale), nil)
        guard CGImageDestinationFinalize(destination) else {
            FileHandle.standardError.write(Data("failed to write \(name)\n".utf8))
            exit(1)
        }
    }
}
