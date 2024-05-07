import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:core';
// import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ...

Future<void> main() async {
  runApp(PdfGenerator());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PdfGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Generator'),
        ),
        body: PdfGeneratorScreen(),
      ),
    );
  }
}

class PdfGeneratorScreen extends StatefulWidget {
  @override
  _PdfGeneratorScreenState createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  Uint8List? pdfBytes;
  String uid = '';

  @override
  void initState() {
    super.initState();
    getIdFromUrl();
  }

  // void getIdFromUrl() {
  //   Uri uri = Uri.parse(window.location.href);
  //   List<String> segments = uri.pathSegments;
  //   if (segments.isNotEmpty) {
  //     setState(() {
  //       uid = segments.last;
  //     });
  //   }
  // }

  void getIdFromUrl() {
    Uri uri = Uri.parse(window.location.href);
    Map<String, String> queryParameters = uri.queryParameters;
    if (queryParameters.containsKey('docRef')) {
      setState(() {
        uid = queryParameters['docRef']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            // calling the generating function
            onPressed: () async {
              try {
                pdfBytes = await _generatePdf(uid);
                if (pdfBytes != null) {
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: PdfPreview(
                          build: (format) => pdfBytes!,
                          canDebug: false,
                          allowPrinting: true,
                          allowSharing: true,
                          canChangeOrientation: true,
                          canChangePageFormat: true,
                          actionBarTheme: PdfActionBarTheme(
                              backgroundColor: Colors.lightBlueAccent),
                        ),
                      ),
                    ),
                  );
                }
              } catch (e) {
                print('Error generating PDF: $e');
              }
            },
            child: Center(child: const Text('Generate and Share PDF')),
          ),
        ],
      ),
    );
  }

  //generating pdf function
  Future<Uint8List?> _generatePdf(uid) async {
    final pdf = pw.Document();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // final repaymentQuerySnapshot =
      //     await firestore.collection('repayment').doc(uid).get();
      final DocumentReference docRef =
          firestore.collection('repayment').doc('$uid');
      final CollectionReference refColl = docRef.collection('ref');
      final QuerySnapshot refQuerySnapshot = await refColl.get();

      final DocumentSnapshot docSnapshot = await docRef.get();
      final String accruedInterest = docSnapshot.get('accruedInterest');
      final String amountCcollected =
          docSnapshot.get('amount collected(physical remittance)');
      final String amountcollectpmec = docSnapshot.get('amountcollectpmec');
      final String difference = docSnapshot.get('difference');
      final String dueDate = docSnapshot.get('due date');
      final String monthlyRepaymentAmount =
          docSnapshot.get('monthlyRepaymentAmount');

      // Process ref data
      final List<pw.TableRow> refRows = [];
      for (final refDoc in refQuerySnapshot.docs) {
        // final refData = refDoc.data();
        final refData = refDoc.data() as Map<String, dynamic>?;

        // Print the data for each document in the 'ref' subcollection
        print('ref document ID: ${refDoc.id}');
        print('ref data: $refData');

        if (refData != null) {
          // Null check for each field for the repayment table
          final String date = refData['date']?.toString() ?? '';
          final amount = refData['amount']?.toString() ?? '';
          final owe = refData['owe']?.toString() ?? '';
          final paid = refData['paid']?.toString() ?? '';
          final pay = refData['pay']?.toString() ?? '';
          final totalAmount = refData['totalAmount']?.toString() ?? '';

          refRows.add(pw.TableRow(children: [
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(date, style: pw.TextStyle(fontSize: 7)))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(amount, style: pw.TextStyle(fontSize: 7)))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(totalAmount,
                        style: pw.TextStyle(fontSize: 7)))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(owe, style: pw.TextStyle(fontSize: 7)))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(paid, style: pw.TextStyle(fontSize: 7)))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Center(
                    child: pw.Text(pay, style: pw.TextStyle(fontSize: 7)))),
          ]));
        }
      } // Null check for each field for the repayment table
      // final dueDate = data['due date']?.toString() ?? '';
      // final monthlyRepaymentAmount =
      //     data['monthlyRepaymentAmount']?.toString() ?? '';
      // final amountCollectPmec =
      //     data['amount collect (pmec)']?.toString() ?? '';
      // final amountCollectedPhysicalRemittance =
      //     data['amount collected(physical remittance)']?.toString() ?? '';
      // final difference = data['difference']?.toString() ?? '';
      // final accruedInterest = data['accruedInterest']?.toString() ?? '';

      // Use a custom font
      var font = await PdfGoogleFonts.openSansRegular();
      // declaring a logo image
      final image = (await rootBundle
              .load('assets/Frontier Finance Limited Logo-black wording.jpg'))
          .buffer
          .asUint8List();
      if (refRows.isNotEmpty) {
        // Add a page to the PDF document
        pdf.addPage(
          // pw.Page(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              // Add content to the page
              return [
                pw.Column(
                  children: [
                    // Logo
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          child: pw.Image(pw.MemoryImage((image)),
                              width: 200, height: 100),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 10),
                    // statement
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('LOAN STATEMENT',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('STRICTLY WITHOUT PREJUDICE',
                            style: const pw.TextStyle(fontSize: 5)),
                      ],
                    ),

                    pw.SizedBox(height: 40),
                    // first table
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 200, // Set the width to half of the page

                          child: pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              pw.TableRow(children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('Date',
                                      style: pw.TextStyle(
                                          fontSize: 7,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('DD/MM/YYYY',
                                      style: const pw.TextStyle(fontSize: 7)),
                                )
                              ]),
                              pw.TableRow(children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('Client Name',
                                      style: pw.TextStyle(
                                          fontSize: 7,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('hoel Phiri',
                                      style: const pw.TextStyle(
                                        fontSize: 7,
                                      )),
                                ),
                              ]),
                              pw.TableRow(children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('Employee Number',
                                      style: pw.TextStyle(
                                          fontSize: 7,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text(difference,
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                              ]),
                              pw.TableRow(children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('Branch',
                                      style: pw.TextStyle(
                                          fontSize: 7,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text('LSK',
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        // ),
                      ],
                    ),

                    pw.SizedBox(height: 15),
                    // second table
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        //title of the table
                        pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: pw.Text('LOAN DETAILS',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Table(
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                                decoration:
                                    pw.BoxDecoration(color: PdfColors.grey500),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('PRINCIPAL LOAN AMOUNT',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN TENURE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('MONTHLY DUE AMOUNT',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN START DATE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                ]),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(accruedInterest,
                                      style: pw.TextStyle(fontSize: 6)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(amountCcollected,
                                      style: pw.TextStyle(fontSize: 6)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(amountcollectpmec,
                                      style: pw.TextStyle(fontSize: 6)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(dueDate,
                                      style: pw.TextStyle(fontSize: 6)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),
                    // third table
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // table title
                        pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: pw.Text('REPAYMENT SUMMARY',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Table(
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                                decoration:
                                    pw.BoxDecoration(color: PdfColors.grey500),
                                // the heading row of the table
                                children: [
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text('DUE DATE',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text(
                                              'MONTHLY REPAYMENT AMOUNT',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text(
                                              'AMOUNT COLLECTED (PMEC)',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text(
                                              'AMOUNT COLLECTED (CASH)',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text('DIFFERENCE',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Center(
                                          child: pw.Text('ACCRUED INTEREST',
                                              style:
                                                  pw.TextStyle(fontSize: 6)))),
                                ]),
                            // ...repaymentRows,
                            ...refRows,
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),
                    // fourth table
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      // table title heading
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: pw.Text('ACCOUNT SUMMARY',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold))),
                        pw.Table(
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                                decoration:
                                    pw.BoxDecoration(color: PdfColors.grey500),
                                // the heading row of the table
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL PAID TO DATE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL ACCRUED',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN BALANCE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL DUE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Center(
                                      child: pw.Text('PERCENTAGE RECOVERED',
                                          style: pw.TextStyle(fontSize: 6)),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('NET PAYABLE TO CLOSE',
                                        style: pw.TextStyle(fontSize: 6)),
                                  ),
                                ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('Data F',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('Data G',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('Data H',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('Data I',
                                    style: pw.TextStyle(fontSize: 7)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Center(
                                  child: pw.Text('Data J',
                                      style: pw.TextStyle(fontSize: 6)),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('Data J',
                                    style: pw.TextStyle(fontSize: 6)),
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 50),
                    // firth table: static table
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 300,
                          child: pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text(
                                        'Airtel Mobile Money Account',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('+260 97 2 113 178',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('MTN Mobile Money Account',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('+260 76 8 823 007',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('Bank',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('United Bank of Africa',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('Branch',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('Cairo Road',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text(
                                      'Account Number',
                                      style: pw.TextStyle(
                                          fontSize: 6,
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text(
                                      '9030160001224',
                                      style: pw.TextStyle(
                                        fontSize: 6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('Sort Code',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('370003',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('Swift Code',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    child: pw.Text('UNAFZMLU',
                                        style: pw.TextStyle(
                                          fontSize: 6,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )
              ];
            },
          ),
        );

        // Save the PDF document to bytes
        return pdf.save();
      } else {
        print('No data found to generate PDF.');
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                pw.Text(
                  'No data found to generate PDF.',
                  style: pw.TextStyle(
                      fontSize: 30,
                      color: PdfColors.red,
                      fontWeight: pw.FontWeight.bold),
                )
              ];
            },
          ),
        );
        return pdf.save();
      }
    } catch (e) {
      print('Error generating PDF: $e');
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Text(
                '$e',
                style: pw.TextStyle(
                    fontSize: 30,
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold),
              )
            ];
          },
        ),
      );
      return pdf.save();
    }
  }
}
