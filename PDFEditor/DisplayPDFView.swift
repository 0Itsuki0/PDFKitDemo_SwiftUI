//
//  PDFView.swift
//  PDFEditor
//
//  Created by Itsuki on 2024/12/30.
//
import SwiftUI
import PDFKit

private struct PDFViewRepresentable: UIViewRepresentable {
    let pdfView = PDFView()

    @Binding private var currentPage: Int
    @Binding private var totalPages: Int
    @Binding private var scale: CGFloat

    init(
        data: Data,
        currentPage: Binding<Int>, totalPages: Binding<Int>, scale: Binding<CGFloat>,
        autoScales: Bool = true,
        userPageViewController: Bool = true,
        backgroundColor: UIColor = .yellow.withAlphaComponent(0.2),
        displayDirection: PDFDisplayDirection = .horizontal,
        pageBreakMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    ) {
        self._currentPage = currentPage
        self._totalPages = totalPages
        self._scale = scale
        
        pdfView.autoScales = autoScales
        pdfView.usePageViewController(userPageViewController)
        pdfView.backgroundColor = backgroundColor
        pdfView.displayDirection = displayDirection
        pdfView.pageBreakMargins = pageBreakMargins
        pdfView.document = PDFDocument(data: data)
    }
    

    func makeUIView(context: Context) -> PDFView {
//        var thumbnails = [UIImage]()
//        for i in 0..<(pdfView.document?.pageCount ?? 0) {
//            guard let page = pdfView.document?.page(at: i) else { continue }
//            let uiImage = page.thumbnail(of: CGSize(width: 100, height: 100), for: pdfView.displayBox)
//            thumbnails.append(uiImage)
//        }
        
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(context.coordinator.handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: self.pdfView)
        
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(context.coordinator.handleScaleChange(notification:)), name: Notification.Name.PDFViewScaleChanged, object: self.pdfView)

        DispatchQueue.main.async {
            self.currentPage = 1
            self.totalPages = pdfView.document?.pageCount ?? 0
            self.scale = pdfView.scaleFactor
        }
        return pdfView
    }

     
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = pdfView.document, let page = document.page(at: currentPage - 1) {
            pdfView.go(to: page)
        }
        pdfView.scaleFactor = scale
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PDFViewRepresentable

        init(_ parent: PDFViewRepresentable) {
            self.parent = parent
        }
        
    
        @objc func handlePageChange(notification: Notification) {
            let currentPageIndex = if let currentPage = parent.pdfView.currentPage, let document = parent.pdfView.document {
                 document.index(for: currentPage)
            } else {
                0
            }
            DispatchQueue.main.async {
                self.parent.scale = self.parent.pdfView.scaleFactor
                self.parent.currentPage = currentPageIndex + 1
            }
        }
        
        @objc func handleScaleChange(notification: Notification) {
            DispatchQueue.main.async {
                self.parent.scale = self.parent.pdfView.scaleFactor
            }
        }
    }
}


struct PDFThumbnailViewRepresentable: UIViewRepresentable {
    private let thumbnailView: PDFThumbnailView
    
    init(
        pdfView: PDFView,
        thumbnailSize: CGSize =  CGSize(width: 80, height: 80),
        layoutMode: PDFThumbnailLayoutMode = .horizontal
    ) {
        let thumbnailView = PDFThumbnailView()
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = thumbnailSize
        thumbnailView.layoutMode = layoutMode
        self.thumbnailView = thumbnailView
    }

    func makeUIView(context: Context) -> PDFThumbnailView {
        return thumbnailView
    }
     
    func updateUIView(_ pdfView: PDFThumbnailView, context: Context) {}
}


struct DisplayPDFView: View {
    @State private var pdfData: Data?
    @State private var totalPages: Int = 0
    @State private var currentPage: Int = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {

        VStack {
            if let pdfData {
                let pdfViewRepresentable = PDFViewRepresentable(data: pdfData, currentPage: $currentPage, totalPages: $totalPages, scale: $scale)
                pdfViewRepresentable
                    .overlay(alignment: .top, content: {
                        PDFThumbnailViewRepresentable(pdfView: pdfViewRepresentable.pdfView)
                            .frame(height: 120)
                            .padding(.top, 128)
                    })
            } else {
                Text("PDF not available!")
            }
        }
        .ignoresSafeArea(.all)
        .overlay(alignment: .topLeading, content: {
            HStack {
                Image(systemName: "sidebar.left")
                Text("Page \(currentPage)/\(totalPages)")
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))
            .padding()
        })
        .overlay(alignment: .topTrailing, content: {
            HStack {
                Image(systemName: scale >= 1 ? "plus.magnifyingglass" : "minus.magnifyingglass")
                Text("\(String(format: "%.0f", scale*100))%")
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))
            .padding()
        })
        .overlay(alignment: .bottom, content: {
            HStack {
                Button(action: {
                    currentPage -= 1
                }, label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(currentPage <= 1 ? .gray : .black )
                })
                .disabled(currentPage <= 1)
                
                Text("\(currentPage)/\(totalPages)")
                
                Button(action: {
                    currentPage += 1
                }, label: {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(currentPage == totalPages ? .gray : .black )
                })
                .disabled(currentPage == totalPages)
                
                Spacer()
                    .frame(width: 40)
                
                Button(action: {
                    scale -= 0.1
                    
                }, label: {
                    Image(systemName: "minus.magnifyingglass")
                })
                
                Text("\(String(format: "%.0f", scale*100))%")

                Button(action: {
                    scale += 0.1
                }, label: {
                    Image(systemName: "plus.magnifyingglass")
                })
                
            }
            .foregroundStyle(.black )
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.5)))
            .padding()
        })
        .onAppear {
            if let url = Bundle.main.url(forResource: "pikachus", withExtension: "pdf") {
                self.pdfData = try? Data(contentsOf: url)
            }
        }
    }
}


#Preview {
    DisplayPDFView()
}
