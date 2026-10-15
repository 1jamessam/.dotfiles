// Write a retina PNG of labelled tick marks for a MIN..MAX slider, e.g. the pomodoro
// slider (150pt wide, 15-60 min, ticks at 15/25/45/60):
//   swift make_slider_ticks.swift pomodoro_ticks.png 150 15 60 15 25 45 60
// The image is drawn behind the slider, vertically centered on its track, so ticks and
// numbers go in the lower half and the upper half stays empty.
import AppKit

let args = CommandLine.arguments
let out = args[1]
let width = Double(args[2])!, lo = Double(args[3])!, hi = Double(args[4])!
let values = args[5...].map { Double($0)! }

let scale = 2.0, height = 44.0
let mid = height / 2  // the track's centre line
let rep = NSBitmapImageRep(
  bitmapDataPlanes: nil, pixelsWide: Int(width * scale), pixelsHigh: Int(height * scale),
  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: width, height: height)  // draw in points

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let grey = NSColor(srgbRed: 0x93 / 255, green: 0x9A / 255, blue: 0xB7 / 255, alpha: 1)  // GREY
let attrs: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: 9, weight: .semibold), .foregroundColor: grey,
]

for v in values {
  let x = (v - lo) / (hi - lo) * (width - 1) + 0.5  // matches where the knob lands
  grey.setFill()
  NSRect(x: x - 0.5, y: mid - 8, width: 1, height: 4).fill()  // 4pt tick, 4pt below centre
  let text = NSAttributedString(string: String(Int(v)), attributes: attrs)
  let size = text.size()
  let left = min(max(x - size.width / 2, 0), width - size.width)  // keep end labels inside
  text.draw(at: NSPoint(x: left, y: mid - 10 - size.height))
}
NSGraphicsContext.restoreGraphicsState()

try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
