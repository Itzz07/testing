import 'dart:html';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:core';
// import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

// ...

Future<void> main() async {
  runApp(const PdfGenerator());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PdfGenerator extends StatelessWidget {
  const PdfGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   // title: const Text('Loan Statement PDF Generator'),
        // ),
        body: PdfGeneratorScreen(),
      ),
    );
  }
}

class PdfGeneratorScreen extends StatefulWidget {
  const PdfGeneratorScreen({super.key});

  @override
  _PdfGeneratorScreenState createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  Uint8List? pdfBytes;
  String uid = 'UJqHl0E907Usg5jXjLiH6MVP5ES2';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.blueAccent,
          ],
        ),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Loan Statement PDF Generator',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue)),
            const SizedBox(
              height: 35,
            ),
            const Text('Before proceeding to generate the loan statement,',
                style: TextStyle(fontSize: 17, color: Colors.white)),
            const Text(
                'please ensure that all collections have been entered accurately.',
                style: TextStyle(fontSize: 17, color: Colors.white)),
            const SizedBox(
              height: 35,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.lightBlueAccent, // foreground color
                fixedSize: const Size(350, 50), // specify the size
              ),
              onPressed: () async {
                AlertDialog loadingDialog = AlertDialog(
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );

                showDialog(
                  context: context,
                  builder: (_) => loadingDialog,
                );
                try {
                  pdfBytes = await _generatePdf(uid);
                  if (pdfBytes != null) {
                    Navigator.of(context).pop(); // dismiss the loading dialog
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: PdfPreview(
                            build: (format) => pdfBytes!,
                            canDebug: false,
                            allowPrinting: true,
                            allowSharing: true,
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            actionBarTheme: const PdfActionBarTheme(
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
              child: const Center(
                child: Text('Generate and Print Loan Statement',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         ElevatedButton(
  //           // calling the generating function
  //           onPressed: () async {
  //             try {
  //               pdfBytes = await _generatePdf(uid);
  //               if (pdfBytes != null) {
  //                 await showDialog(
  //                   context: context,
  //                   builder: (_) => AlertDialog(
  //                     content: SizedBox(
  //                       width: MediaQuery.of(context).size.width * 0.8,
  //                       height: MediaQuery.of(context).size.height * 0.9,
  //                       child: PdfPreview(
  //                         build: (format) => pdfBytes!,
  //                         canDebug: false,
  //                         allowPrinting: true,
  //                         allowSharing: true,
  //                         canChangeOrientation: false,
  //                         canChangePageFormat: false,
  //                         actionBarTheme: PdfActionBarTheme(
  //                             backgroundColor: Colors.lightBlueAccent),
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               }
  //             } catch (e) {
  //               print('Error generating PDF: $e');
  //             }
  //           },
  //           child: Center(child: const Text('Generate and Share PDF')),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  double accruedInterest(
    double dif,
    double intR,
    int dim,
  ) {
    double result = (dif * pow(1 + (intR / 100), dim)) - dif;
    return double.parse(result.toStringAsFixed(2));
  }

  double interest(
    int daysUntilNextPMECDate,
    double intRate,
    double loanAmount,
    int loanTenure,
  ) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    double interest = (intRate / 100) * loanAmount * (loanTenure - 1) +
        (intRate / 100) * loanAmount * daysUntilNextPMECDate / 30;
    interest = double.parse(interest.toStringAsFixed(2));
    return interest;

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  int difInMonths(
    DateTime dueDate,
    DateTime closingDate,
  ) {
    // // return the number of months between two dates
    // if (dueDate == null || closingDate == null) {
    //   return null;
    // }
    int months = (dueDate.year - closingDate.year) * 12;
    months += dueDate.month - closingDate.month;
    return months.abs();
  }

  DateTime nextPMECDate() {
    // Calculate date of the 5th day in the next month, starting from the current date
    DateTime currentDate = DateTime.now();
    DateTime nextMonth = DateTime(currentDate.year, currentDate.month + 1, 1);
    DateTime fifthDay = DateTime(nextMonth.year, nextMonth.month, 5);
    return fifthDay;

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  DateTime currentDate() {
    DateTime currentDay = DateTime.now();
    return currentDay;
  }

  int daysBetween(
    DateTime from,
    DateTime to,
  ) {
    // if (from == null || to == null) {
    //   return null;
    // }

    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  double monthlyDifference(
    double monExpDed,
    double collectedAmount,
    double otherCollectedAmount,
  ) {
    double difference = monExpDed - (collectedAmount + otherCollectedAmount);

    if (difference < 0) {
      difference = 0;
    }

    return difference;
  }

  double totalPaymentsCopy(
    double loanAmt,
    double totalInterest,
    double totalAccruedInterest,
  ) {
// loanAmt + totalInterest + totalAccruedInterest return the value to 2 decimal points
    double total = (loanAmt) + (totalInterest) + (totalAccruedInterest);
    return double.parse(total.toStringAsFixed(2));
  }

  double percentageRecoveredToDate(
    double totalDue,
    double totalPaidtoDate,
    double totalAccrued,
  ) {
    double totalDueAmount = totalDue;
    double totalPaidAmount = totalPaidtoDate;
    double totalAccruedAmount = totalAccrued;
    double totalAmount = totalDueAmount + totalAccruedAmount;
    if (totalAmount == 0) {
      return 0.0;
    }
    double percentage = (totalPaidAmount / totalAmount) * 100;
    return double.parse(percentage.toStringAsFixed(2));
  }

  double totalPayments(
    double loanAmt,
    double totalInterest,
  ) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    // ( loanAmt + totalInterest) return the value to 2 decimal points
    final total = (loanAmt) + (totalInterest);
    return double.parse(total.toStringAsFixed(2));

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  double netPayableToCloseAccount(
    double totalExpectedPerSchedule,
    double totalAccruedInterest,
    double totalPaid,
    double loanAmount,
    double adminPercent,
  ) {
    double adminFee = adminPercent * loanAmount;
    double netPayable =
        totalAccruedInterest + totalExpectedPerSchedule + adminFee - totalPaid;

    double roundedNetPayable = double.parse(netPayable.toStringAsFixed(2));
    return roundedNetPayable;
  }

  double closingAdminPercent(DateTime appDate) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    // if its equal or more than 90 days from the appDate, return 0.1, else return 0.15
    final now = DateTime.now();
    final difference = now.difference(appDate).inDays;
    if (difference >= 90) {
      return 0.15;
    } else {
      return 0.20;
    }

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  double totalPaymentsAtClosure(
    double loanAmt,
    double totalInterest,
  ) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    double total = (loanAmt) + (totalInterest);
    return double.parse(total.toStringAsFixed(2));

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  double interestRateAtClosing(
    DateTime paidDate,
    DateTime currentDate,
    double originalInterestRate,
  ) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    // Return 18 if the difference between two  is less or equal to 90 days, else return the original rate
    final daysDifference = currentDate.difference(paidDate).inDays;
    if (daysDifference <= 90) {
      return 20;
    } else {
      return originalInterestRate;
    }

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

  DateTime pastNextPMECDate(DateTime applicationDate) {
    /// MODIFY CODE ONLY BELOW THIS LINE

    // Return the 5th day of the next month from the applicationDate
    final nextMonth = DateTime(applicationDate.year, applicationDate.month + 1);
    final fifthDay = DateTime(nextMonth.year, nextMonth.month, 5);
    return fifthDay;

    /// MODIFY CODE ONLY ABOVE THIS LINE
  }

//generating pdf function
  Future<Uint8List?> _generatePdf(uid) async {
    final pdf = pw.Document();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // final repaymentQuerySnapshot =
      //     await firestore.collection('repayment').doc(uid).get();
      final DocumentReference docRef =
          firestore.collection('loanLog').doc('$uid');
      final CollectionReference refColl =
          docRef.collection('monthlyRepayments');
      final QuerySnapshot refQuerySnapshot =
          await refColl.orderBy('collectedDate', descending: false).get();
      final DocumentSnapshot docSnapshot = await docRef.get();

      // for the first table
      final appDate = docSnapshot.get('appDate');
      final dateTime = appDate.toDate(); // convert timestamp to DateTime
      final formattedAppDate = DateFormat('dd/MM/yyyy').format(dateTime);
      final String firstName = docSnapshot.get('firstName');
      final String surName = docSnapshot.get('surName');
      final String employeeNumber = docSnapshot.get('employeeNumber');
      final String branch = docSnapshot.get('branch');

      // for the second table
      final double loanAmountDouble =
          docSnapshot['loanAmount']['currency'] ?? 0.0;
      final formatter =
          NumberFormat("#,##0.00"); // format with commas and two decimal places
      final loanAmount = formatter.format(loanAmountDouble);
      final double monthlyDeductionPmecDouble =
          docSnapshot['monthlyDeductionPmec']['currency'] ?? 0.0;
      final monthlyDeductionPmec = formatter.format(monthlyDeductionPmecDouble);
      final String loanTenure = docSnapshot['loanTenure']?.toString() ?? '';
      final loanStartDate = docSnapshot.get('loanStartDate');
      final loanStartDateTime =
          loanStartDate.toDate(); // convert timestamp to DateTime
      final formattedloanStartDate =
          DateFormat('dd MMM, yyyy').format(loanStartDateTime);

      // other variables
      final double intRate = docSnapshot['intRate'] ?? 0.0;
      final doubeLoanTenure = docSnapshot['loanTenure'] ?? 0.0;

      // Process ref data
      final List<pw.TableRow> refRows = [];
      for (final refDoc in refQuerySnapshot.docs) {
        // final refData = refDoc.data();
        final refData = refDoc.data() as Map<String, dynamic>?;

        // Print the data for each document in the 'ref' subcollection
        print('ref document ID: ${refDoc.id}');
        // print('ref data: $refData');

        if (refData != null) {
          // Null check for each field for the repayment table
          // final appDate = docSnapshot.get('appDate');
          final collectedDate = refData['collectedDate'];
          final collectedDateTime =
              collectedDate.toDate(); // convert timestamp to DateTime
          final formattedcollectedDate =
              DateFormat('dd MMM, yyyy').format(collectedDateTime);
          final double monthlyEqualDeductionDouble =
              refData['monthlyEqualDeduction']['currency'] ?? 0.0;
          final monthlyEqualDeduction =
              formatter.format(monthlyEqualDeductionDouble);

          final double collectedAmountDouble =
              refData['collectedAmount']['currency'] ?? 0.0;
          final collectedAmount = formatter.format(collectedAmountDouble);

          final double otherCollectedAmountsDouble =
              refData['otherCollectedAmounts']['currency'] ?? 0.0;
          final otherCollectedAmounts =
              formatter.format(otherCollectedAmountsDouble);

          final differenceAmount = max(
              0,
              monthlyEqualDeductionDouble -
                  (collectedAmountDouble + otherCollectedAmountsDouble));
          final difference = formatter.format(differenceAmount);
          var intrate = refData['intrateRef'];

          // AccruedInterest
          final calAccruedInterest = accruedInterest(
            monthlyDifference(monthlyEqualDeductionDouble,
                collectedAmountDouble, otherCollectedAmountsDouble),
            intrate ?? 0.0,
            difInMonths(collectedDateTime, nextPMECDate()),
          );

          refRows.add(pw.TableRow(children: [
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text(formattedcollectedDate,
                    style: const pw.TextStyle(fontSize: 7))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text('ZMW ${monthlyEqualDeduction.toString()}',
                    style: const pw.TextStyle(fontSize: 7))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text('ZMW ${collectedAmount.toString()}',
                    style: const pw.TextStyle(fontSize: 7))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text('ZMW ${otherCollectedAmounts.toString()}',
                    style: const pw.TextStyle(fontSize: 7))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text('ZMW ${difference.toString()}',
                    style: const pw.TextStyle(fontSize: 7))),
            pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: pw.Text('ZMW ${calAccruedInterest.toString()}',
                    style: const pw.TextStyle(fontSize: 7))),
          ]));
        }
      }
      // other variables
      final totalPaid = docSnapshot['totalPaid']['currency'] ?? 0.0;
      final finalTotalPaid = formatter.format(totalPaid).toString();
      final totalAccruedInterest =
          docSnapshot['totalAccruedInterest']['currency'] ?? 0.0;
      final finalTotalAccruedInterest =
          formatter.format(totalAccruedInterest).toString();

      final nextPMEC = docSnapshot.get('nextPMECDate');
      final nextPMECDateTime = nextPMEC.toDate();

      final paidDate = docSnapshot.get('paidDate');
      final paidDateTime = paidDate.toDate();

      final calTotalDue = totalPaymentsCopy(
          loanAmountDouble,
          interest(
              daysBetween(
                dateTime,
                nextPMECDateTime,
              ),
              intRate,
              loanAmountDouble,
              doubeLoanTenure),
          totalAccruedInterest);
      final totalDue = double.parse(calTotalDue.toStringAsFixed(2));
      final finalTotalDue = formatter.format(totalDue).toString();

      final loanBalance = ((totalDue + totalAccruedInterest) - totalPaid);
      final finalLoanBalance = formatter.format(loanBalance).toString();

      final calPercent = percentageRecoveredToDate(
          totalPayments(
            loanAmountDouble,
            interest(
                daysBetween(
                  dateTime,
                  nextPMECDateTime,
                ),
                intRate,
                loanAmountDouble,
                doubeLoanTenure),
          ),
          totalPaid,
          totalAccruedInterest);
      final finalCalPercent = formatter.format(calPercent).toString();

      final calNetPayable = netPayableToCloseAccount(
        totalPaymentsAtClosure(
          loanAmountDouble,
          interest(
              daysBetween(
                currentDate(),
                nextPMECDate(),
              ),
              interestRateAtClosing(paidDateTime, currentDate(), intRate),
              loanAmountDouble,
              difInMonths(paidDateTime, pastNextPMECDate(currentDate()))),
        ),
        totalAccruedInterest,
        totalPaid,
        loanAmountDouble,
        closingAdminPercent(dateTime),
      );
      final finalCalNetPayable = formatter.format(calNetPayable).toString();

      final calDaysBetween = daysBetween(
        currentDate(),
        nextPMECDate(),
      );
      final finalCalDaysBetween = calDaysBetween.toString();

      // Use a custom font
      var font = await PdfGoogleFonts.openSansRegular();
      // declaring a logo image
      final image = (await rootBundle.load('assets/assets/Frontierlogo.png'))
          .buffer
          .asUint8List();
      final pageTheme = await _myPageTheme(PdfPageFormat.a4);
      if (refRows.isNotEmpty) {
        // Add a page to the PDF document
        pdf.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            // pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              // Add content to the page
              return [
                pw.Column(
                  children: [
                    pw.SizedBox(height: 10),
                    // statement
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('LOAN STATEMENT',
                            style: pw.TextStyle(
                                fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('STRICTLY WITHOUT PREJUDICE',
                            style: const pw.TextStyle(fontSize: 6)),
                      ],
                    ),

                    pw.SizedBox(height: 65),
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
                                  child: pw.Text('Date of issue',
                                      style: pw.TextStyle(
                                          fontSize: 7,
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  child: pw.Text(formattedAppDate,
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
                                  child: pw.Text('$firstName $surName',
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
                                  child: pw.Text(employeeNumber,
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
                                  child: pw.Text(branch,
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
                                decoration: const pw.BoxDecoration(
                                    color: PdfColors.grey400),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('PRINCIPAL LOAN AMOUNT',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN TENURE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('MONTHLY DUE AMOUNT',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN START DATE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                ]),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text('ZMW ${loanAmount.toString()}',
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text('$loanTenure MONTHS',
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(
                                      'ZMW ${monthlyDeductionPmec.toString()}',
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: pw.Text(formattedloanStartDate,
                                      style: const pw.TextStyle(fontSize: 7)),
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
                                decoration: const pw.BoxDecoration(
                                    color: PdfColors.grey400),
                                // the heading row of the table
                                children: [
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('DUE DATE',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('MONTHLY REPAYMENT AMOUNT',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('AMOUNT COLLECTED (PMEC)',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('AMOUNT COLLECTED (CASH)',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('DIFFERENCE',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('ACCRUED INTEREST',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold))),
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
                                decoration: const pw.BoxDecoration(
                                    color: PdfColors.grey500),
                                // the heading row of the table
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL PAID TO DATE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL ACCRUED',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('LOAN BALANCE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('TOTAL DUE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Center(
                                      child: pw.Text('PERCENTAGE RECOVERED',
                                          style: pw.TextStyle(
                                              fontSize: 6,
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('NET PAYABLE TO CLOSE',
                                        style: pw.TextStyle(
                                            fontSize: 6,
                                            fontWeight: pw.FontWeight.bold)),
                                  ),
                                ]),
                            pw.TableRow(children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('ZMW $finalTotalPaid',
                                    style: const pw.TextStyle(fontSize: 7)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('ZMW $finalTotalAccruedInterest',
                                    style: const pw.TextStyle(fontSize: 7)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('ZMW $finalLoanBalance',
                                    style: const pw.TextStyle(fontSize: 7)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('ZMW $finalTotalDue',
                                    style: const pw.TextStyle(fontSize: 7)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Center(
                                  child: pw.Text('$finalCalPercent %',
                                      style: const pw.TextStyle(fontSize: 7)),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: pw.Text('ZMW $finalCalNetPayable',
                                    style: const pw.TextStyle(fontSize: 7)),
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 25),
                    // NOTE
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          child: pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                    text: 'NOTE: ',
                                    style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold)),
                                const pw.TextSpan(
                                    text:
                                        'Please note that this Loan Statement is ',
                                    style: pw.TextStyle(fontSize: 9)),
                                pw.TextSpan(
                                    text: 'ONLY ',
                                    style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold)),
                                const pw.TextSpan(
                                    text: 'valid for ',
                                    style: pw.TextStyle(fontSize: 9)),
                                pw.TextSpan(
                                    text: '$finalCalDaysBetween DAYS ',
                                    style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold)),
                                const pw.TextSpan(
                                    text:
                                        'from the date of issue. Beyond that, it will be rendered ',
                                    style: pw.TextStyle(fontSize: 9)),
                                pw.TextSpan(
                                    text: 'null and void.',
                                    style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ];
            },
            header: (pw.Context context) =>
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
            footer: (pw.Context context) =>
                // firth table: static table
                pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 300,
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // pw.TableRow(
                      //   children: [
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.symmetric(
                      //           horizontal: 5, vertical: 2),
                      //       child: pw.Text('Airtel Mobile Money Account',
                      //           style: pw.TextStyle(
                      //               fontSize: 6,
                      //               fontWeight: pw.FontWeight.bold)),
                      //     ),
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.symmetric(
                      //           horizontal: 5, vertical: 2),
                      //       child: pw.Text('+260 97 2 113 178',
                      //           style: const pw.TextStyle(
                      //             fontSize: 6,
                      //           )),
                      //     ),
                      //   ],
                      // ),
                      // pw.TableRow(
                      //   children: [
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.symmetric(
                      //           horizontal: 5, vertical: 2),
                      //       child: pw.Text('MTN Mobile Money Account',
                      //           style: pw.TextStyle(
                      //               fontSize: 6,
                      //               fontWeight: pw.FontWeight.bold)),
                      //     ),
                      //     pw.Padding(
                      //       padding: const pw.EdgeInsets.symmetric(
                      //           horizontal: 5, vertical: 2),
                      //       child: pw.Text('+260 76 8 823 007',
                      //           // ignore: prefer_const_constructors
                      //           style: pw.TextStyle(
                      //             fontSize: 6,
                      //           )),
                      //     ),
                      //   ],
                      // ),
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
                            child: pw.Text('Zambia National Bank (ZANACO)',
                                style: const pw.TextStyle(
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
                            child: pw.Text('Northmead',
                                style: const pw.TextStyle(
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
                                  fontSize: 6, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: pw.Text(
                              '5942675500175',
                              style: const pw.TextStyle(
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
                            child: pw.Text('01-00-75',
                                style: const pw.TextStyle(
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
                            child: pw.Text('ZNCOMLU',
                                style: const pw.TextStyle(
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

  Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/watermark.png')).buffer.asUint8List(),
    );
    return pw.PageTheme(
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 0.5 * PdfPageFormat.cm,
        vertical: 0.5 * PdfPageFormat.cm,
      ), // pw.EdgeInsets.symmetric
      textDirection: pw.TextDirection.ltr,
      orientation: pw.PageOrientation.portrait,
      buildBackground: (final context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Watermark(
          angle: 0,
          child: pw.Opacity(
            opacity: 0.2,
            child: pw.Image(
              alignment: pw.Alignment.center,
              logoImage,
              fit: pw.BoxFit.cover,
            ), // pw.Image
          ), // pw.opacity
        ), // pw.Watermark
      ), // pw.FullPage
    ); // pw.PageTheme
  }
}
