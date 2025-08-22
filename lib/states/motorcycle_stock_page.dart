import 'dart:convert';
import 'package:erp/wisget/branch_product_card.dart';
import 'package:erp/wisget/record_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ เพิ่ม import

import '../dialog/save_dialog.dart';
import '../service/api_service.dart';

class MotorcycleStockPage extends StatefulWidget {
  final String token;
  final String empName;

  const MotorcycleStockPage({
    Key? key,
    required this.token,
    required this.empName,
  }) : super(key: key);

  @override
  State<MotorcycleStockPage> createState() => _MotorcycleStockPage();
}

class _MotorcycleStockPage extends State<MotorcycleStockPage> {
  String selectedOption = 'ค้นหาจาก';
  final List<String> options = ['ค้นหาจาก', 'รหัส', 'ชื่อ', 'หมวดหมู่'];

  String? selectedBranchMotor;
  String? selectedProductMotor;
  String? selectedDocumentMotor;
  String? selectedStorageMotor;
  List<String> storageListMotor = [];

  List<Map<String, String>> stockDataM = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBranchMotor = prefs.getString("selectedBranch");
      selectedProductMotor = prefs.getString("selectedProduct");
      selectedDocumentMotor = prefs.getString("selectedDocument");
      selectedStorageMotor = prefs.getString("selectedStorage");
    });

    // โหลด stockData
    final stockJson = prefs.getString('stockData');
    if (stockJson != null) {
      final List<dynamic> decoded = jsonDecode(stockJson);
      setState(() {
        stockDataM =
            decoded
                .map<Map<String, String>>((e) => Map<String, String>.from(e))
                .toList();
      });
    }
  }

  Future<void> _savePreference(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final api = ApiService(widget.token);

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
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            const Text(
              'Motorcycle stock',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 1.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            BranchProductCardMotor(
              selectedBranchMotor: selectedBranchMotor,
              onBranchChangedMotor: (value) {
                setState(() => selectedBranchMotor = value);
                _savePreference("selectedBranch", value); // ✅ บันทึกค่า
              },
              selectedProductMotor: selectedProductMotor,
              onProductChangedMotor: (value) {
                setState(() => selectedProductMotor = value);
                _savePreference("selectedProduct", value); // ✅ บันทึกค่า
              },
              selectedDocumentMotor: selectedDocumentMotor,
              onDocumentChangedMotor: (value) {
                setState(() => selectedDocumentMotor = value);
                _savePreference("selectedDocument", value); // ✅ บันทึกค่า
              },
              selectedStorageMotor: selectedStorageMotor,
              storageListMotor: storageListMotor,
              onStorageChangedMotor: (value) {
                setState(() => selectedStorageMotor = value);
                _savePreference("selectedStorage", value); // ✅ บันทึกค่า
              },
              apiToken: widget.token,
              onAddItemMotor: (stockList) async {
                setState(() {
                  stockDataM = List<Map<String, String>>.from(stockList);
                });

                // บันทึกลง SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('stockData', jsonEncode(stockDataM));
              },
            ),

            const SizedBox(height: 16),
            RecordCardMotor(
              employeeName: widget.empName,
              initialRecordDate: todayStr,
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                  ElevatedButton(
                    onPressed: () async {
                      if (stockDataM.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('กรุณาเพิ่มสินค้าก่อนบันทึก'),
                          ),
                        );
                        return;
                      }

                      // สร้าง payload สำหรับ API
                      final payload = {
                        "stockno": selectedDocumentMotor ?? '',
                        "branchname": selectedBranchMotor ?? '',
                        "emp_fname": widget.empName,
                        "stockItems":
                            stockDataM
                                .map(
                                  (e) => {
                                    "submodel_code": e['เลขถัง'],
                                    "location": e['ที่เก็บ'],
                                    "qtycount":
                                        int.tryParse(e['จำนวน'] ?? '0') ?? 0,
                                  },
                                )
                                .toList(),
                      };

                      // ✅ เพิ่ม log
                      print('---Payload for saveStock---');
                      print(jsonEncode(payload));
                      print('---------------------------');
                      try {
                        final success = await api.saveStock(payload);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                            ),
                          );
                          setState(() {
                            stockDataM.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('บันทึกไม่สำเร็จ')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                        );
                      }
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
