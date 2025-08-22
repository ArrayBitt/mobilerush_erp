import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ เพิ่ม import
import '../widgets/branch_and_product_card.dart';
import '../widgets/record_info_card.dart';
import '../dialog/save_dialog.dart';
import '../service/api_service.dart';

class SparePartStockPage extends StatefulWidget {
  final String token;
  final String empName;

  const SparePartStockPage({
    Key? key,
    required this.token,
    required this.empName,
  }) : super(key: key);

  @override
  State<SparePartStockPage> createState() => _SparePartStockPageState();
}

class _SparePartStockPageState extends State<SparePartStockPage> {
  String selectedOption = 'ค้นหาจาก';
  final List<String> options = ['ค้นหาจาก', 'รหัส', 'ชื่อ', 'หมวดหมู่'];

  String? selectedBranch;
  String? selectedProduct;
  String? selectedDocument;
  String? selectedStorage;
  List<String> storageList = [];

  List<Map<String, String>> stockData = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBranch = prefs.getString("selectedBranch");
      selectedProduct = prefs.getString("selectedProduct");
      selectedDocument = prefs.getString("selectedDocument");
      selectedStorage = prefs.getString("selectedStorage");
    });

    // โหลด stockData
    final stockJson = prefs.getString('stockData');
    if (stockJson != null) {
      final List<dynamic> decoded = jsonDecode(stockJson);
      setState(() {
        stockData =
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
              'SparePartStock',
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
            BranchAndProductCard(
              selectedBranch: selectedBranch,
              onBranchChanged: (value) {
                setState(() => selectedBranch = value);
                _savePreference("selectedBranch", value); // ✅ บันทึกค่า
              },
              selectedProduct: selectedProduct,
              onProductChanged: (value) {
                setState(() => selectedProduct = value);
                _savePreference("selectedProduct", value); // ✅ บันทึกค่า
              },
              selectedDocument: selectedDocument,
              onDocumentChanged: (value) {
                setState(() => selectedDocument = value);
                _savePreference("selectedDocument", value); // ✅ บันทึกค่า
              },
              selectedStorage: selectedStorage,
              storageList: storageList,
              onStorageChanged: (value) {
                setState(() => selectedStorage = value);
                _savePreference("selectedStorage", value); // ✅ บันทึกค่า
              },
              apiToken: widget.token,
              onAddItem: (stockList) async {
                setState(() {
                  stockData = List<Map<String, String>>.from(stockList);
                });

                // บันทึกลง SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('stockData', jsonEncode(stockData));
              },
            ),

            const SizedBox(height: 16),
            RecordInfoCard(
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
                      if (stockData.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('กรุณาเพิ่มสินค้าก่อนบันทึก'),
                          ),
                        );
                        return;
                      }

                      // สร้าง payload สำหรับ API
                      final payload = {
                        "stockno": selectedDocument ?? '',
                        "branchname": selectedBranch ?? '',
                        "emp_fname": widget.empName,
                        "stockItems":
                            stockData
                                .map(
                                  (e) => {
                                    "submodel_code": e['รหัสสินค้า'],
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
                            stockData.clear();
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
