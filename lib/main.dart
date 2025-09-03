import 'package:stock_count/states/login.dart';
import 'package:stock_count/states/product_stock_page.dart';
import 'package:stock_count/states/spare_part_stock_page.dart';
import 'package:flutter/material.dart';

// เพิ่ม import สำหรับ localization
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home: const LoginPage(),
       //home: const ProductStockPage(),
      //home: const SparePartStockPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th'), // ภาษาไทย
        Locale('en'), // ภาษาอังกฤษ
      ],
    );
  }
}
