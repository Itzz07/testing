// Define the Google font style
// pw.TextStyle googleFontStyle = GoogleFonts.openSans();

// Define a function to load the custom font synchronously
      // Future<pw.Font> loadCustomFont() async {
      //   final fontData = await rootBundle.load(
      //       'assets/google_fonts/open-sans.ttf'); // Adjust the path to your font file
      //   final font = pw.Font.ttf(fontData.buffer.asByteData());
      //   return font;
      // }

// Register the custom font with the PDF document
      // final customFont = await loadCustomFont();
// pdf.addFont(customFont);

 // PdfPreview(
              //   build: (format) => pdfBytes!,
              // );
              // if (pdfBytes != null) {
              //   await Printing.sharePdf(
              //     bytes: pdfBytes!,
              //     filename: 'generated_pdf.pdf',
              //   );
              // }



//  Future<Uint8List?> _generatePdf() async {
  //   WidgetsFlutterBinding.ensureInitialized();

  //   final firestore = FirebaseFirestore.instance;
  //   final querySnapshot = await firestore.collection('repayment').get();

  //   final pageSize = 50; // Number of rows per page
  //   final pageCount = (querySnapshot.docs.length / pageSize).ceil();

  //   for (var i = 0; i < pageCount; i++) {
  //     final start = i * pageSize;
  //     final end = (i + 1) * pageSize;
  //     final rows = querySnapshot.docs
  //         .sublist(start, end.clamp(0, querySnapshot.docs.length));

  //     final pdf = pw.Document();

  //     final pageRows = rows.map((doc) {
  //       final data = doc.data();
  //       final dueDate = data['due date']?.toString() ?? '';
  //       final monthlyRepaymentAmount =
  //           data['monthlyRepaymentAmount']?.toString() ?? '';
  //       final amountCollectPmec =
  //           data['amount collect (pmec)']?.toString() ?? '';
  //       final amountCollectedPhysicalRemittance =
  //           data['amount collected(physical remittance)']?.toString() ?? '';
  //       final difference = data['difference']?.toString() ?? '';
  //       final accruedInterest = data['accruedInterest']?.toString() ?? '';

  //       return pw.TableRow(children: [
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child: pw.Text(dueDate, style: pw.TextStyle(fontSize: 7)))),
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child: pw.Text(monthlyRepaymentAmount,
  //                     style: pw.TextStyle(fontSize: 7)))),
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child: pw.Text(amountCollectPmec,
  //                     style: pw.TextStyle(fontSize: 7)))),
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child: pw.Text(amountCollectedPhysicalRemittance,
  //                     style: pw.TextStyle(fontSize: 7)))),
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child:
  //                     pw.Text(difference, style: pw.TextStyle(fontSize: 7)))),
  //         pw.Padding(
  //             padding:
  //                 const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //             child: pw.Center(
  //                 child: pw.Text(accruedInterest,
  //                     style: pw.TextStyle(fontSize: 7)))),
  //       ]);
  //     }).toList();

  //     pdf.addPage(pw.MultiPage(
  //       // key: pw.UniqueKey(), // Adda unique key to avoid the "There are multiple root widgets" error
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) => [
  //         pw.Column(
  //           children: [
  //             pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Padding(
  //                   padding: const pw.EdgeInsets.symmetric(
  //                       horizontal: 5, vertical: 2),
  //                   child: pw.Text('REPAYMENT SUMMARY',
  //                       style: pw.TextStyle(
  //                           fontSize: 8, fontWeight: pw.FontWeight.bold)),
  //                 ),
  //                 pw.Table(
  //                   border: pw.TableBorder.all(),
  //                   children: [
  //                     pw.TableRow(
  //                       decoration: pw.BoxDecoration(color: PdfColors.grey500),
  //                       children: [
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text('DUE DATE',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text('MONTHLY REPAYMENT AMOUNT',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text('AMOUNT COLLECTED (PMEC)',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text(
  //                                 'AMOUNT COLLECTED (PHYSICAL REMITTANCE)',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text('DIFFERENCE',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 5),
  //                           child: pw.Center(
  //                             child: pw.Text('ACCRUED INTEREST',
  //                                 style: pw.TextStyle(fontSize: 6)),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     ...pageRows,
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ));

  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/example_page_${i + 1}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());

  //     print('PDF page ${i + 1} generated successfully. Path: $filePath');
  //   }
  // }
