
# Demo for using PDFKit with SwiftUI

## Generate New PDF
[Demo Code](./PDFEditor/NewPDFView.swift)

Related Blog: [SwiftUI: Create PDF 2 Ways]()


![](./ReadmeAssets/newPDF.gif)



## Display PDF
Display PDF with PDFKit with
- current page number, total page count, and scale
- controls for paging and modifying scale from SwiftUI View
- Two way PDF Thumbnails (displaying a thumbnail PDFPage Contents as well as controlling which page is displayed)

[Demo Code](./PDFEditor/DisplayPDFView.swift)

Related Blog: [SwiftUI: Display PDF with PDFKit](https://medium.com/gitconnected/swiftui-display-pdf-with-pdfkit-864a4cc9a89e)


![](./ReadmeAssets/displayPDF.gif)




## Static Annotation

Add Static Annotations by
- using `PDFAnnotation` class
- creating custom subclass of `PDFAnnotation` for adding custom graphics

Add Page graphics such as watermark by
- subclassing `PDFPage`

[Demo Code](./PDFEditor/AnnotationView.swift)

Related Blog: [SwiftUI: Add Static Annotations & Page Graphics to PDF](https://medium.com/@itsuki.enjoy/swiftui-add-static-annotations-page-graphics-to-pdf-905f37af6a30)


![](./ReadmeAssets/staticAnnotation.gif)




## Interactive Form Elements

Add Interactive Form Elements (Widget annotation) to PDF
- TextField Input
- Button
- Choices

[Demo Code](./PDFEditor/WidgetView.swift)

Related Blog: [SwiftUI: Add Interactive Form Elements to PDF]()

![](./ReadmeAssets/widgetAnnotation.gif)




# Custom Drawing Annotation

Add/Edit/Erase custom drawing annotation to/from PDF.

Can be used for
- adding/editing custom mark ups
- adding signature field
to PDF.


[Demo Code](./PDFEditor/DrawingView.swift)

Related Blog: [SwiftUI: Add, Erase and Save Custom Drawing Annotations to PDF]()

![](./ReadmeAssets/customDrawing.gif)
