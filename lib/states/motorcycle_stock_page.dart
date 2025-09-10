import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:stock_count/wisget/branch_product_card.dart';
import 'package:stock_count/wisget/record_card.dart';
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

  String? selectedBranch;
  String? selectedProduct;
  String? selectedDocument;
  String? selectedStorage;
  List<Map<String, dynamic>> storageList = [];

  List<Map<String, String>> stockData = [];

  List<String> productListWithChassis = [];
  String? mstStockId;
  String? inventoryCheckId;

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

            // ✅ ทำให้ unique ด้วย Set<String>
            final uniqueSet =
                inventoryList.map((item) {
                  final loc = item['location'];
                  final locCode =
                      loc != null
                          ? loc['location']?.toString() ?? 'unknown'
                          : 'unknown';
                  final locName =
                      loc != null ? loc['locationname']?.toString() ?? '' : '';
                  return '$locCode|$locName'; // บีบเป็น String
                }).toSet();

            // ✅ แปลงกลับเป็น List<Map<String, dynamic>>
            final locations =
                uniqueSet.map((str) {
                  final parts = str.split('|');
                  return {
                    'location': parts[0],
                    'locationname': parts.length > 1 ? parts[1] : '',
                  };
                }).toList();

            setState(() {
              storageList = List<Map<String, dynamic>>.from(locations);
              // ถ้าต้องการให้ UI อัปเดตค่า selectedStorage เป็น null เมื่อเปลี่ยนเอกสาร:
              selectedStorage = null;
            });

            print("🔔 _fetchMstStockId: mstStockId = $mstStockId");
            print("🔔 _fetchMstStockId: inventoryCheckId = $inventoryCheckId");
            print(
              "🔔 _fetchMstStockId: storageList.length = ${storageList.length}",
            );
            print("🔔 _fetchMstStockId: storageList = $storageList");

            print('เอกสาร $docNo มีที่เก็บทั้งหมด: ${locations.length} อัน');
            print('รายการที่เก็บ: $storageList');
          } else {
            inventoryCheckId = null;
            setState(() {
              storageList = [];
            });
            print('เอกสาร $docNo ไม่มีข้อมูลที่เก็บ');
          }

          setState(() {});
        } else {
          mstStockId = null;
          inventoryCheckId = null;
          setState(() {
            storageList = [];
          });
          print('ไม่พบข้อมูลเอกสาร $docNo');
        }
      } else {
        print('Failed to fetch stock data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

  Future<List<String>> _getProductsWithChassis(
    String mstStockId,
    String location,
  ) async {
    final url = Uri.parse(
      'https://erp-uat.somjai.app/api/inventory-check/getdatainventorycheckcar'
      '?mststockid=$mstStockId&location=$location&chassisno=&token=${widget.token}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print("❌ Failed to fetch data. Status: ${response.statusCode}");
        return [];
      }

      final data = jsonDecode(response.body);
      if (data is! List) return [];

      final products = <String>{};

      for (var item in data) {
        final chassisNo = item['stockitem']?['chassisno']?.toString() ?? '';

        if (chassisNo.isNotEmpty) {
          products.add(chassisNo); // <-- เอาแค่ chassisNo
          print("📋 chassis: $chassisNo");
        }
      }

      return products.toList();
    } catch (e) {
      print("❌ Exception in _getProductsWithChassis: $e");
      return [];
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
              'Motorcyclestock',
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
              selectedBranchMortor: selectedBranch,
              onBranchChangedMortor: (value) {
                setState(() => selectedBranch = value);
                _savePreference("selectedBranch", value);
              },
              selectedProductMortor: selectedProduct,
              productListMortor: productListWithChassis, // <-- ใส่ตรงนี้
              onProductChangedMortor: (value) {
                setState(() => selectedProduct = value);
                _savePreference("selectedProduct", value);
              },
              selectedDocumentMortor: selectedDocument,
              onDocumentChangedMortor: (value) async {
                setState(() => selectedDocument = value);
                _savePreference("selectedDocument", value);

                if (value != null && value.isNotEmpty) {
                  await _fetchMstStockId(value); // ดึง mstStockId
                  selectedProduct = null; // <-- รีเซ็ต product
                  productListWithChassis = []; // <-- ล้าง list เดิม
                }
              },
              selectedStorageMortor: selectedStorage,
              storageListMortor: storageList,

              onStorageChangedMortor: (value) async {
                setState(() => selectedStorage = value);
                await _savePreference("selectedStorage", value);

                if (value == null || value.isEmpty) return;

                final locationCode = value.split(' - ').first.trim();
                if (mstStockId == null) return;

                final productsWithChassis = await _getProductsWithChassis(
                  mstStockId!,
                  locationCode,
                );

                print("🔔 Products fetched: ${productsWithChassis.length}");
                print("🔔 Products list: $productsWithChassis");

                setState(() {
                  productListWithChassis = List<String>.from(
                    productsWithChassis,
                  ); // ✅ บังคับเป็น List<String>
                  selectedProduct = null; // รีเซ็ต dropdown
                });
                print(
                  "🔔 Storage $locationCode มี chassisno ทั้งหมด: ${productsWithChassis.length}",
                );
              },

              apiToken: widget.token,
              onAddItem: (stockList) async {
                setState(() {
                  stockData = List<Map<String, String>>.from(stockList);
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('stockData', jsonEncode(stockData));
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

                      if (stockData.isEmpty) {
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
                          stockData
                              .map((e) {
                                final qty = int.tryParse(
                                  e['จำนวน']?.trim() ?? '',
                                );
                                if (qty == null || qty <= 0) return null;
                                return {
                                  "inventory_check_id":
                                      inventoryCheckId, // ✅ เพิ่มเข้าไปในแต่ละ item
                                  "chassisno": e['เลขถัง']?.trim(),
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
                            stockData.clear();
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
