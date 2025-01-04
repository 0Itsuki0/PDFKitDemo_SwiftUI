//
//  WidgetView.swift
//  PDFEditor
//
//  Created by Itsuki on 2025/01/01.
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
        pdfView.document = pdfDocument

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let page = pdfView.currentPage {
            let bounds = page.bounds(for: pdfView.displayBox)
            // text widget
            let textAnnotationTitle = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 100, width: 200, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationTitle.contents = "Text Widget"
            addTextAnnotation(textAnnotationTitle, to: page)

            let textAnnotationBasic = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 160, width: 96, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationBasic.contents = "Basic"
            addTextAnnotation(textAnnotationBasic, to: page)


            let basicTextWidget = PDFAnnotation(bounds: CGRect(x: 120, y: bounds.height - 160, width: 240, height: 48), forType: .widget, withProperties: nil)
            basicTextWidget.isReadOnly = true
            addTextWidget(basicTextWidget, to: page)

            
            let textAnnotationComb = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 220, width: 156, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationComb.contents = "hasComb"
            addTextAnnotation(textAnnotationComb, to: page)

            
            let widgetAnnotationComb = PDFAnnotation(bounds: CGRect(x: 172, y: bounds.height - 220, width: 240, height: 48), forType: .widget, withProperties: nil)
            widgetAnnotationComb.maximumLength = 4
            widgetAnnotationComb.hasComb = true
            addTextWidget(widgetAnnotationComb, to: page)
            
            
            let textAnnotationMultiLine = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 280, width: 156, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationMultiLine.contents = "MultiLine"
            addTextAnnotation(textAnnotationMultiLine, to: page)

            let widgetAnnotationMultiLine = PDFAnnotation(bounds: CGRect(x: 172, y: bounds.height - 320, width: 240, height: 96), forType: .widget, withProperties: nil)
            widgetAnnotationMultiLine.isMultiline = true
            addTextWidget(widgetAnnotationMultiLine, to: page)

            
            let textAnnotationButton = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 380, width: 120, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationButton.contents = "Button"
            addTextAnnotation(textAnnotationButton, to: page)
            
            
            let textAnnotationRadio = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 440, width: 120, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationRadio.contents = "Radio"
            addTextAnnotation(textAnnotationRadio, to: page)


            let textAnnotationRadioTrue = PDFAnnotation(bounds: CGRect(x: 140, y: bounds.height - 440, width: 80, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationRadioTrue.contents = "True"
            addTextAnnotation(textAnnotationRadioTrue, to: page)

            let radioButtonWidgetTrue = PDFAnnotation(bounds: CGRect(x: 240, y: bounds.height - 440, width: 24, height: 48), forType: .widget, withProperties: nil)
            radioButtonWidgetTrue.widgetFieldType = .button
            radioButtonWidgetTrue.widgetControlType = .radioButtonControl
            radioButtonWidgetTrue.buttonWidgetStateString = "True"
            radioButtonWidgetTrue.fieldName = "radioButton"
            page.addAnnotation(radioButtonWidgetTrue)

            let textAnnotationRadioFalse = PDFAnnotation(bounds: CGRect(x: 300, y: bounds.height - 440, width: 80, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationRadioFalse.contents = "False"
            addTextAnnotation(textAnnotationRadioFalse, to: page)


            let radioButtonWidgetFalse = PDFAnnotation(bounds: CGRect(x: 400, y: bounds.height - 440, width: 24, height: 48), forType: .widget, withProperties: nil)
            radioButtonWidgetFalse.widgetFieldType = .button
            radioButtonWidgetFalse.widgetControlType = .radioButtonControl
            radioButtonWidgetFalse.fieldName = "radioButton"
            radioButtonWidgetFalse.buttonWidgetStateString = "False"
            page.addAnnotation(radioButtonWidgetFalse)
            
            
            let textAnnotationCheck = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 500, width: 160, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationCheck.contents = "CheckBox"
            addTextAnnotation(textAnnotationCheck, to: page)


            let checkWidget = PDFAnnotation(bounds: CGRect(x: 200, y: bounds.height - 495, width: 32, height: 32), forType: .widget, withProperties: nil)
            checkWidget.widgetFieldType = .button
            checkWidget.widgetControlType = .checkBoxControl
            checkWidget.buttonWidgetState = .onState
            page.addAnnotation(checkWidget)
            
            
            let textAnnotationPush = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 560, width: 120, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationPush.contents = "Push"
            addTextAnnotation(textAnnotationPush, to: page)


            let resetPushWidget = PDFAnnotation(bounds: CGRect(x: 200, y: bounds.height - 560, width: 120, height: 48), forType: .widget, withProperties: nil)
            resetPushWidget.widgetFieldType = .button
            resetPushWidget.widgetControlType = .pushButtonControl
            resetPushWidget.caption = "Reset"
            resetPushWidget.font = UIFont.systemFont(ofSize: 36)
            
            let resetFormAction = PDFActionResetForm()
            resetFormAction.fields = ["radioButton"]
            resetFormAction.fieldsIncludedAreCleared = false
            resetPushWidget.action = resetFormAction
            page.addAnnotation(resetPushWidget)
            
            
            let textAnnotationChoice = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 620, width: 120, height: 48), forType: .freeText, withProperties: nil)
            textAnnotationChoice.contents = "Choice"
            addTextAnnotation(textAnnotationChoice, to: page)

            let choiceWidget = PDFAnnotation(bounds: CGRect(x: 200, y: bounds.height - 620, width: 160, height: 48), forType: .widget, withProperties: nil)
            choiceWidget.widgetFieldType = .choice
            choiceWidget.isListChoice = false
            choiceWidget.choices = ["Option 1", "Option 2", "Option 3"]
            choiceWidget.values = ["1", "2", "3"]
            choiceWidget.font = UIFont.systemFont(ofSize: 36)
            choiceWidget.backgroundColor = .blue.withAlphaComponent(0.2)
            page.addAnnotation(choiceWidget)
            
            
//            let textAnnotationSignature = PDFAnnotation(bounds: CGRect(x: 10, y: bounds.height - 680, width: 156, height: 48), forType: .freeText, withProperties: nil)
//            textAnnotationSignature.contents = "Signature"
//            addTextAnnotation(textAnnotationSignature, to: page)

//            let signatureWidget = PDFAnnotation(bounds: CGRect(x: 200, y: bounds.height - 680, width: 160, height: 48), forType: .widget, withProperties: nil)
//            signatureWidget.widgetFieldType = .signature
//            signatureWidget.shouldPrint = true
//            signatureWidget.shouldDisplay = true
//            signatureWidget.backgroundColor = .blue.withAlphaComponent(0.2)
//            page.addAnnotation(signatureWidget)
        }
        
//        Task {
//            print(URL.documentsDirectory.appending(path: "test.pdf"))
//            pdfView.document?.write(to: URL.documentsDirectory.appending(path: "test.pdf"))
//        }
    }
    
    private func addTextAnnotation(_ text: PDFAnnotation, to page: PDFPage) {
        text.font = UIFont.systemFont(ofSize: 36)
        text.fontColor = .red
        page.addAnnotation(text)
    }
    
    private func addTextWidget(_ widget: PDFAnnotation, to page: PDFPage) {
        widget.widgetFieldType = .text
        widget.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        widget.font = UIFont.systemFont(ofSize: 36)
        page.addAnnotation(widget)
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

struct WidgetView: View {
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
            if let url = Bundle.main.url(forResource: "blank", withExtension: "pdf") {
                self.pdfData = try? Data(contentsOf: url)
            }
        }
    }
}

#Preview {
    WidgetView( )
}
