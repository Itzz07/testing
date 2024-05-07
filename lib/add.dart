import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() {
  final random = Random();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (int i = 0; i < 10; i++) {
    firestore.collection('repayment').add({
      'accruedInterest': random.nextDouble() * 1000,
      'amount collect (pmec)': random.nextInt(1000),
      'amount collected(physical remittance)': random.nextInt(1000),
      'difference': (random.nextInt(5000) + 100) * (random.nextInt(1000) + 1),
      'dueDate': DateTime.now().add(Duration(days: i * 30)).month.toString() +
          ', 2023',
      'monthlyRepaymentAmount': (random.nextInt(5000) + 100) *
          (random.nextInt(1000) + 1),
    });
  }
}