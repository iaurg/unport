import CoreGraphics

public enum EthernetPortIcon {
    /// Front view of an RJ45 socket, in a y-up coordinate space. Fill with the even-odd rule.
    public static func path(in rect: CGRect) -> CGPath {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }

        let path = CGMutablePath()
        path.addRoundedRect(
            in: CGRect(origin: point(0.06, 0.06), size: CGSize(width: 0.88 * rect.width, height: 0.88 * rect.height)),
            cornerWidth: 0.16 * rect.width,
            cornerHeight: 0.16 * rect.height
        )

        // Socket opening: the top edge is a comb so the contact pins stay solid, the bottom steps in for the latch.
        let top: CGFloat = 0.76, pinTip: CGFloat = 0.58, shoulder: CGFloat = 0.40, bottom: CGFloat = 0.24
        path.move(to: point(0.20, top))
        for pinStart in [0.27, 0.40, 0.54, 0.67] as [CGFloat] {
            path.addLine(to: point(pinStart, top))
            path.addLine(to: point(pinStart, pinTip))
            path.addLine(to: point(pinStart + 0.06, pinTip))
            path.addLine(to: point(pinStart + 0.06, top))
        }
        path.addLine(to: point(0.80, top))
        path.addLine(to: point(0.80, shoulder))
        path.addLine(to: point(0.64, shoulder))
        path.addLine(to: point(0.64, bottom))
        path.addLine(to: point(0.36, bottom))
        path.addLine(to: point(0.36, shoulder))
        path.addLine(to: point(0.20, shoulder))
        path.closeSubpath()

        return path
    }
}
