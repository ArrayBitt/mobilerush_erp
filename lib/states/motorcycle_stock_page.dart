import 'dart:convert';
import 'package:stock_count/wisget/branch_product_card.dart';
import 'package:stock_count/wisget/record_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ เพิ่ม import
import 'package:http/http.dart' as http;
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
  String? mstStockId;
  String? inventoryCheckId;

  final TextEditingController searchController = TextEditingController();

  late String _apiToken; // ✅ local variable สำหรับ ApiService

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
    _ensureToken(); // ✅ เพิ่มตรงนี้
  }

  /// โหลด token จาก SharedPreferences ถ้า widget.token ว่าง
  Future<void> _ensureToken() async {
    if (widget.token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('apiToken') ?? '';
      if (savedToken.isNotEmpty) {
        setState(() {
          _apiToken = savedToken;
        });
      } else {
        print('ERROR: No API token found!');
        _apiToken = '';
      }
    } else {
      _apiToken = widget.token;
    }
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

  Future<void> _fetchMstStockId(String docNo) async {
    final url = Uri.parse(
      'https://erp-uat.somjai.app/api/mststocks/getInventoryCheckCar?keyword=$docNo&token=${widget.token}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final first = data[0];

          mstStockId = first['mststockid'].toString();

          final inventoryList = first['inventoryCheck'] as List?;
          if (inventoryList != null && inventoryList.isNotEmpty) {
            inventoryCheckId =
                inventoryList.first['inventory_check_id'].toString();
          } else {
            inventoryCheckId = null;
          }

          setState(() {});
        } else {
          mstStockId = null;
          inventoryCheckId = null;
        }
      } else {
        print('Failed to fetch stock data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final api = ApiService(_apiToken); 

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
              apiToken: _apiToken, 
              selectedBranchMotor: selectedBranchMotor,
              onBranchChangedMotor: (value) {
                setState(() => selectedBranchMotor = value);
                _savePreference("selectedBranch", value);
              },
              selectedChasisnoMotor: selectedProductMotor,
              onChasisnoChangedMotor: (value) {
                setState(() => selectedProductMotor = value);
                _savePreference("selectedProduct", value);
              },
              selectedDocumentMotor: selectedDocumentMotor,
              onDocumentChangedMotor: (value) {
                setState(() => selectedDocumentMotor = value);
                _savePreference("selectedDocument", value);
              },
              selectedStorageMotor: selectedStorageMotor,
              storageListMotor: storageListMotor,
              onStorageChangedMotor: (value) {
                setState(() => selectedStorageMotor = value);
                _savePreference("selectedStorage", value);
              },
              onAddItemMotor: (stockList) async {
                setState(() {
                  stockDataM = List<Map<String, String>>.from(stockList);
                });
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
                      final timestamp = DateTime.now().toIso8601String();

                      if (stockDataM.isEmpty) {
                        _showCustomPopup(
                          title: 'แจ้งเตือน',
                          message: 'กรุณาเพิ่มสินค้าก่อนบันทึก',
                          success: false,
                        );
                        return;
                      }

                      if (mstStockId == null) {
                        _showCustomPopup(
                          title: 'แจ้งเตือน',
                          message: 'ไม่พบ mststockid สำหรับเลขเอกสารนี้',
                          success: false,
                        );
                        return;
                      }

                      final inventoryCheck =
                          stockDataM
                              .map((e) {
                                final qty = int.tryParse(
                                  e['จำนวน']?.trim() ?? '',
                                );
                                if (qty == null || qty <= 0) return null;
                                return {
                                  "inventory_check_id":
                                      inventoryCheckId, // ✅ เพิ่มเข้าไปในแต่ละ item
                                  "submodel_code": e['รหัสสินค้า']?.trim(),
                                  "location": e['ที่เก็บ']?.trim() ?? '00',
                                  "qtycount": qty,
                                };
                              })
                              .where((e) => e != null)
                              .cast<Map<String, dynamic>>()
                              .toList();

                      print("DEBUG: stockItemsPatch = $inventoryCheck");

                      if (inventoryCheck.isEmpty) {
                        _showCustomPopup(
                          title: 'แจ้งเตือน',
                          message: 'ไม่มีข้อมูลที่จะอัปเดต',
                          success: false,
                        );
                        return;
                      }

                      try {
                        final api = ApiService(widget.token);

                        final success = await api.patchInventoryCheckUpdate(
                          mstStockId!,
                          inventoryCheck,
                        );

                        if (success) {
                          _showCustomPopup(
                            title: 'สำเร็จ',
                            message: 'บันทึกและอัปเดตข้อมูลเรียบร้อยแล้ว',
                            success: true,
                          );
                          setState(() {
                            stockDataM.clear();
                            mstStockId = null;
                          });
                        }
                      } catch (e) {
                        print(
                          "[$timestamp] PATCH request exception ❌ Error: $e",
                        );
                        _showCustomPopup(
                          title: 'ล้มเหลว',
                          message: 'updateInventoryCheck ไม่สำเร็จ: $e',
                          success: false,
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
  void _showCustomPopup({
    required String title,
    required String message,
    required bool success,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: success ? Colors.green : Colors.red,
                      child: Icon(
                        success ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: success ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: success ? Colors.green : Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'ตกลง',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
  
}
