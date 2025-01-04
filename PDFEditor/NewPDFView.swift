//
//  ContentView.swift
//  PDFEditor
//
//  Created by Itsuki on 2024/12/28.
//

import SwiftUI

struct NewPDFView: View {
    @State private var pdfURL: URL?
    @State private var error: Error?

    var body: some View {
        
        let pageOne: some View = VStack {
            Text("PDF page 1")
                .font(.title3)
                .foregroundColor(.secondary)
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
            Text("Hello\nfrom\nItsuki!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .fontWeight(.bold)
        }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.3)))
        
        let pageTwo: some View = VStack {
            Text("PDF page 2")
                .font(.title3)
                .foregroundColor(.blue)
            Image(systemName: "sun.max.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
        }
            .padding(.all, 32)
            .background(RoundedRectangle(cornerRadius: 8).fill(.yellow.opacity(0.3)))


        VStack(spacing: 32) {
            VStack {
                Text("Generate PDF!")
                    .font(.title2)

                HStack {
                    Button(action: {
                        do {
                            let url = try generatePDFMethod1([AnyView(pageOne), AnyView(pageTwo)])
                            self.pdfURL = url
                        } catch(let error) {
                            self.error = error
                        }
                    }, label: {
                        Text("Method 1")
                    })
                    Divider()
                        .background(.link)
                        .frame(height: 24)
                    
                    Button(action: {
                        do {
                            let url = try generatePDFMethod2([AnyView(pageOne), AnyView(pageTwo)])
                            self.pdfURL = url
                        } catch(let error) {
                            self.error = error
                        }
                    }, label: {
                        Text("Method 2")
                    })
                }
            }
            
            VStack {
                Text("Views to save as PDF")
                pageOne
                pageTwo
            }
            
            if let pdfURL {
                HStack {
                    Text("PDF Generated!")
                    ShareLink(item: pdfURL)
                }
            }
            
            if let error {
                Text("Error while creating PDF: \(error.localizedDescription)")
            }
            
        }
        .padding()
        .padding(.top, 120)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray.opacity(0.2))
    }
    
    private func generatePDFMethod1(_ views: [AnyView]) throws -> URL {
        let destinationURL = URL.documentsDirectory.appendingPathComponent("temp.pdf")
        if FileManager.default.fileExists(atPath: destinationURL.path()) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        guard let pdf = CGContext(destinationURL as CFURL, mediaBox: nil, nil) else {
            throw PDFError.creationFailed
        }

        for view in views {
            let renderer = ImageRenderer(content: view)
            renderer.render(renderer: { size, context in
                var box = CGRect(x: 0, y: 0, width: size.width * 4, height: size.height * 4)
                pdf.beginPage(mediaBox: &box)
                
                pdf.draw(UIImage(systemName: "heart")!.cgImage!, in: CGRect(x: 50, y: 50, width: 50, height: 50))
                
                pdf.translateBy(x: box.size.width / 2 - size.width / 2, y: box.size.height / 2 - size.height / 2)
                context(pdf)

                pdf.endPDFPage()
            })
        }
        pdf.closePDF()

        return destinationURL
    }
    
    private func generatePDFMethod2(_ views: [AnyView]) throws -> URL {
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 400, height: 600))
        let destinationURL = URL.documentsDirectory.appendingPathComponent("temp.pdf")
        if FileManager.default.fileExists(atPath: destinationURL.path()) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try pdfRenderer.writePDF(to: destinationURL) { pdf in
            
            for view in views {
                let renderer = ImageRenderer(content: view)
                guard let uiImage = renderer.uiImage else { continue }
                
                let box = CGRect(x: 0, y: 0, width: uiImage.size.width * 4, height: uiImage.size.height * 4)

                pdf.beginPage(withBounds: box, pageInfo: [:])
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
                ]
                let text = "PDF by Itsuki!"
                text.draw(at: CGPoint(x: 50, y: 50), withAttributes: attributes)

                uiImage.draw(in: CGRect(x: box.size.width / 2 - uiImage.size.width / 2, y: box.size.height / 2 - uiImage.size.height / 2, width: uiImage.size.width, height: uiImage.size.height) )
            }
        }
        
        return destinationURL
    }
}

enum PDFError: Error {
    case creationFailed
}

#Preview {
    NewPDFView()
}
