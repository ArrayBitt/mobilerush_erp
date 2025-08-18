// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:erp/dialog/save_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../widgets/branch_and_product_card.dart';
import '../widgets/record_info_card.dart';
import '../widgets/search_bar_section.dart';
import '../widgets/stock_table_card.dart';

class SparePartStockPage extends StatefulWidget {
  final String token;
  final String employeeName;

  const SparePartStockPage({
    Key? key,
    required this.token,
    required this.employeeName,
  }) : super(key: key);

  @override
  State<SparePartStockPage> createState() => _SparePartStockPageState();
}

class _SparePartStockPageState extends State<SparePartStockPage> {
  String selectedOption = 'ค้นหาจาก';
  final List<String> options = ['ค้นหาจาก', 'รหัส', 'ชื่อ', 'หมวดหมู่'];

  String? selectedBranch;

  List<String> productList = [];
  String? selectedProduct;

  String? selectedDocument;

  List<String> storageList = [];
  String? selectedStorage;

  final List<Map<String, String>> stockData = List.generate(
    10,
    (index) => {'No.': '${index + 1}'},
  );

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    // fetchBranches ลบออกเพราะ BranchAndProductCard handle เอง
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://erp-dev.somjai.app/api/submodels/getAllBysearchSparecheckstock?keyword=',
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          productList =
              data
                  .map((e) => '${e['submodel_code']} : ${e['meaning']}')
                  .toList();
          if (productList.isNotEmpty) selectedProduct = productList.first;
        });
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.keyboard_double_arrow_left,
                color: Color.fromARGB(255, 249, 0, 0),
                size: 28,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'ตรวจสอบข้อมูล STOCK อะไหล่',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 1.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color.fromARGB(255, 249, 0, 0),
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBarSection(
              selectedOption: selectedOption,
              options: options,
              onOptionChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              searchController: searchController,
            ),
            BranchAndProductCard(
              selectedBranch: selectedBranch,
              onBranchChanged:
                  (value) => setState(() => selectedBranch = value),
              selectedProduct: selectedProduct,
              productList: productList,
              onProductChanged:
                  (value) => setState(() => selectedProduct = value),
              selectedDocument: selectedDocument,
              onDocumentChanged:
                  (value) => setState(() => selectedDocument = value),
              selectedStorage: selectedStorage,
              storageList: storageList,
              onStorageChanged:
                  (value) => setState(() => selectedStorage = value),
              apiToken: widget.token,
            ),
            const SizedBox(height: 16),
            StockTableCard(stockData: stockData),
            const SizedBox(height: 16),
            RecordInfoCard(
              employeeName: widget.employeeName,
              initialRecordDate: todayStr,
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่ม ยกเลิก
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBF0000)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(color: Color(0xFFBF0000), fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ปุ่ม บันทึก
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SaveDialog(
                            onCancel: () {
                              Navigator.of(context).pop();
                            },
                            onConfirm: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                                ),
                              );
                              print('บันทึกข้อมูลการตรวจนับสต๊อกเรียบร้อย');
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBF0000),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'บันทึก',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
