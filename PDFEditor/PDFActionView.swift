//
//  PDFActionView.swift
//  PDFEditor
//
//  Created by Itsuki on 2025/01/05.
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
        displayDirection: PDFDisplayDirection = .vertical,
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
        pdfView.document = pdfDocument
        pdfView.go(to: pdfView.document!.page(at: 3)!)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let page = pdfView.document?.page(at: 3) {
            addGotoURL(to: page)
            addGotoActionButton(to: page)
            addNamedAction(to: page)
            addGotoActionLink(to: page)
            addResetAction(to: page)
        }

    }
    
    private func addTextAnnotation(_ text: PDFAnnotation, to page: PDFPage) {
        text.font = UIFont.systemFont(ofSize: 36)
        text.fontColor = .red
        page.addAnnotation(text)
    }
    
    private func addGotoURL(to page: PDFPage) {
        let bounds = page.bounds(for: pdfView.displayBox)

        let urlWidget = PDFAnnotation(bounds: CGRect(x: bounds.width - 240, y: bounds.height - 100, width: 220, height: 48), forType: .widget, withProperties: nil)
        urlWidget.widgetFieldType = .button
        urlWidget.widgetControlType = .pushButtonControl
        urlWidget.caption = "To Google"
        urlWidget.font = UIFont.systemFont(ofSize: 36)

        let urlAction = PDFActionURL(url: URL(string: "https://www.google.com")!)
        urlWidget.action = urlAction

        page.addAnnotation(urlWidget)
    }
    
    private func addNamedAction(to page: PDFPage) {
        let bounds = page.bounds(for: pdfView.displayBox)

        let namedWidget = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 160, width: 280, height: 48), forType: .widget, withProperties: nil)
        namedWidget.widgetFieldType = .button
        namedWidget.widgetControlType = .pushButtonControl
        namedWidget.caption = "Named: FirstPage"
        namedWidget.font = UIFont.systemFont(ofSize: 36)

        let action =  PDFActionNamed(name: .firstPage)
        namedWidget.action = action
        page.addAnnotation(namedWidget)
    }
    
    private func addGotoActionButton(to page: PDFPage) {
        let bounds = page.bounds(for: pdfView.displayBox)

        let gotoWidget = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 100, width: 280, height: 48), forType: .widget, withProperties: nil)
        gotoWidget.widgetFieldType = .button
        gotoWidget.widgetControlType = .pushButtonControl
        gotoWidget.caption = "Goto: FirstPage"
        gotoWidget.font = UIFont.systemFont(ofSize: 36)

        guard let firstPage = pdfView.document?.page(at: 0) else { return }
        let gotoDestination = PDFDestination(page: firstPage, at: .zero)
        let gotoAction = PDFActionGoTo(destination: gotoDestination)
        gotoWidget.action = gotoAction
        
        page.addAnnotation(gotoWidget)

    }
    
    private func addGotoActionLink(to page: PDFPage) {
        let bounds = page.bounds(for: pdfView.displayBox)

        guard let firstPage = pdfView.document?.page(at: 0) else { return }
        let gotoDestination = PDFDestination(page: firstPage, at: .zero)
        let gotoAction = PDFActionGoTo(destination: gotoDestination)

        let linkAnnotation = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 220, width: 240, height: 48), forType: .link, withProperties: nil)
        let textAnnotation = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 220, width: 240, height: 48), forType: .freeText, withProperties: nil)
        
        textAnnotation.contents = "Link: First Page"
        textAnnotation.font = UIFont.systemFont(ofSize: 36)
        textAnnotation.fontColor = .blue
        
        linkAnnotation.action = gotoAction
        // Or assigning the destination directly to the `destination` property
        // linkAnnotation.destination = gotoDestination
        page.addAnnotation(textAnnotation)
        page.addAnnotation(linkAnnotation)
    }
    
    private func addResetAction(to page: PDFPage) {
        let bounds = page.bounds(for: pdfView.displayBox)

        // Reset Action Demo
        let resetFieldName = "TO_RESET"
        
        let resetText = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 280, width: 200, height: 48), forType: .freeText, withProperties: nil)
        resetText.contents = "Input Reset"
        addTextAnnotation(resetText, to: page)


        let resetWidget = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 340, width: 240, height: 48), forType: .widget, withProperties: nil)
        resetWidget.widgetFieldType = .text
        resetWidget.fieldName = resetFieldName
        resetWidget.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        resetWidget.font = UIFont.systemFont(ofSize: 36)

        page.addAnnotation(resetWidget)

        let noResetText = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 400, width: 240, height: 48), forType: .freeText, withProperties: nil)
        noResetText.contents = "Input Not Reset"
        addTextAnnotation(noResetText, to: page)

        
        let noResetWidget = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 460, width: 240, height: 48), forType: .widget, withProperties: nil)
        noResetWidget.widgetFieldType = .text
        noResetWidget.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        noResetWidget.font = UIFont.systemFont(ofSize: 36)
        page.addAnnotation(noResetWidget)

        let resetPushWidget = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 520, width: 120, height: 48), forType: .widget, withProperties: nil)
        resetPushWidget.widgetFieldType = .button
        resetPushWidget.widgetControlType = .pushButtonControl
        resetPushWidget.caption = "Reset"
        resetPushWidget.font = UIFont.systemFont(ofSize: 36)
        
        let resetFormAction = PDFActionResetForm()
        resetFormAction.fields = [resetFieldName]
        resetFormAction.fieldsIncludedAreCleared = true
        resetPushWidget.action = resetFormAction
        page.addAnnotation(resetPushWidget)

    }
    
   
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PDFViewRepresentable
        
        init(_ parent: PDFViewRepresentable) {
            self.parent = parent
        }
    }
}

struct PDFActionView: View {
    @State private var pdfData: Data?

    var body: some View {
        VStack {
            if let pdfData {
                PDFViewRepresentable(data: pdfData)
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
    PDFActionView()
}
