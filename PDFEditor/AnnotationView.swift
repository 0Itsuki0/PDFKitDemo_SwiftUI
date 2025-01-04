//
//  AnnotationView.swift
//  PDFEditor
//
//  Created by Itsuki on 2024/12/31.
//

import SwiftUI
import PDFKit

private struct PDFViewRepresentable: UIViewRepresentable {
    private let pdfView = PDFView()
    let data: Data
    init(
        data: Data,
        autoScales: Bool = true,
        usePageViewController: Bool = true,
        backgroundColor: UIColor = .yellow.withAlphaComponent(0.2),
        displayDirection: PDFDisplayDirection = .horizontal,
        pageBreakMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    ) {
        
        pdfView.autoScales = autoScales
        pdfView.usePageViewController(usePageViewController)
        pdfView.backgroundColor = backgroundColor
        pdfView.displayDirection = displayDirection
        pdfView.pageBreakMargins = pageBreakMargins
        
        self.data = data
    }
    
    
    func makeUIView(context: Context) -> PDFView {
        let pdfDocument = PDFDocument(data: data)
        pdfDocument?.delegate = context.coordinator
        pdfView.document = pdfDocument

        if let page = pdfView.currentPage {
            // text
            let textAnnotation = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 120, height: 80), forType: .freeText, withProperties: nil)
            let border = PDFBorder()
            border.lineWidth = 5.0
            textAnnotation.border = border
            textAnnotation.contents = "Hey!"
            textAnnotation.font = UIFont.systemFont(ofSize: 56)
            textAnnotation.fontColor = .red
            page.addAnnotation(textAnnotation)
            
            // shape
            let inkAnnotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
            inkAnnotation.border = border
            inkAnnotation.color = .blue
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 100))
            path.addCurve(to: CGPoint(x: 100, y: 100), controlPoint1: CGPoint(x: 0, y: 200), controlPoint2: CGPoint(x: 100, y: 200))
            inkAnnotation.add(path)
            page.addAnnotation(inkAnnotation)
            
            
            let starAnnotation = StarAnnotation()
            starAnnotation.bounds = CGRect(x: page.bounds(for: pdfView.displayBox).maxX-200, y: page.bounds(for: pdfView.displayBox).maxY-200, width: 160, height: 160)
            starAnnotation.border = border
            starAnnotation.color = .red
            starAnnotation.backgroundColor = .yellow
            page.addAnnotation(starAnnotation)

        }

        return pdfView
    }

    
    func updateUIView(_ pdfView: PDFView, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFDocumentDelegate {
        var parent: PDFViewRepresentable
        
        init(_ parent: PDFViewRepresentable) {
            self.parent = parent
        }
        
        func classForPage() -> AnyClass {
            return PikachuWatermark.self
        }
        
    }
}

private class PikachuWatermark: PDFPage {
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        
        UIGraphicsPushContext(context)
        context.saveGState()

        // translate and scale for different coordinate system
        // (0, 0) at top left corner
        let pageBounds = self.bounds(for: box)
        context.translateBy(x: 0, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        
        if let heart = UIImage(systemName: "heart.fill") {
            heart.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        }
        
        context.rotate(by: CGFloat.pi/6.0)

        let string: NSString = "Pikachu! 2025/01/01"
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 64)
        ]

        string.draw(at: CGPoint(x: 250, y: 100), withAttributes: attributes)

        context.restoreGState()
        UIGraphicsPopContext()
    }
}



private class StarAnnotation: PDFAnnotation {
    static let annotationType = "star"
    override var hasAppearanceStream: Bool { true }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        // Draw original content under the new content.
        super.draw(with: box, in: context)
        UIGraphicsPushContext(context)
        context.saveGState()
        
        // translate and scale for different coordinate system
        // (0, 0) at top left corner
        let pageBounds = page?.bounds(for: box)  ?? .zero
        context.translateBy(x: 0, y: pageBounds.height)
        context.scaleBy(x: 1.0, y: -1.0)
        let targetRect = CGRect(
            x: bounds.origin.x,
            y: -bounds.origin.y+pageBounds.height-bounds.height,
            width: bounds.width,
            height: bounds.height)
        
        let cgPath = Star(corners: 5, smoothness: 0.5).path(in: targetRect).cgPath
        
//        let cgPath = Star(corners: 5, smoothness: 0.5).path(in: bounds).cgPath

        let path = UIBezierPath(cgPath: cgPath)
        let fillColor = backgroundColor ?? .clear
        fillColor.setFill()
        path.fill()
        
        path.lineWidth = border?.lineWidth ?? 2.0
        color.setStroke()
        path.stroke()

        context.restoreGState()
        UIGraphicsPopContext()
    }
}

private struct Star: Shape {
    let corners: Int
    let smoothness: Double

    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        let corners = Int(corners)

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / Double(corners * 2)
        let innerX = center.x * smoothness
        let innerY = center.y * smoothness
        var path = Path()
        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))
        var bottomEdge: Double = 0

        // loop over all our points/inner points
        for corner in 0..<corners * 2  {
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: Double
            if corner.isMultiple(of: 2) {
                bottom = center.y * sinAngle
                path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
            } else {
                bottom = innerY * sinAngle
                path.addLine(to: CGPoint(x: innerX * cosAngle, y: bottom))
            }
            if bottom > bottomEdge {
                bottomEdge = bottom
            }
            currentAngle += angleAdjustment
        }
        path.closeSubpath()

        let unusedSpace = (rect.height/2 - bottomEdge) / 2
        //  shift for unused space
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        path = path.applying(transform)
        // shift for origin
        path = path.applying(CGAffineTransform(translationX: rect.minX , y: rect.minY))

        return path
    }
}



struct AnnotationView: View {
    @State private var pdfData: Data?

    var body: some View {
        VStack {
            if let pdfData {
                PDFViewRepresentable(data: pdfData, usePageViewController: true, displayDirection: .vertical, pageBreakMargins: UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32))
            } else {
                Text("PDF not available!")
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            if let url = Bundle.main.url(forResource: "pikachus", withExtension: "pdf") {
                self.pdfData = try? Data(contentsOf: url)
            }
        }
    }
}


#Preview {
    AnnotationView( )
}
