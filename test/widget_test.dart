import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blog/main.dart';

void main() {
  testWidgets('App bisa dibuka dan menampilkan judul My Blog', (WidgetTester tester) async {
    await tester.pumpWidget(const MyBlogApp());

    expect(find.text('My Blog'), findsOneWidget);
  });
}