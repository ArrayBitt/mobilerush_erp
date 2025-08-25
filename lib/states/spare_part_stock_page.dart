import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // ✅ เพิ่มสำหรับเรียก API
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
  String? mstStockId; // ✅ เก็บค่า mststockid

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

  // ✅ ดึง mststockid จากเลขเอกสาร
  Future<void> _fetchMstStockId(String docNo) async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/mststocks/getInventoryCheckCar?keyword=$docNo&token=${widget.token}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            mstStockId = data[0]['mststockid'].toString();
          });
        } else {
          mstStockId = null;
        }
      } else {
        print('Failed to fetch mststockid. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching mststockid: $e');
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
                _savePreference("selectedBranch", value);
              },
              selectedProduct: selectedProduct,
              onProductChanged: (value) {
                setState(() => selectedProduct = value);
                _savePreference("selectedProduct", value);
              },
              selectedDocument: selectedDocument,
              onDocumentChanged: (value) async {
                setState(() => selectedDocument = value);
                _savePreference("selectedDocument", value);
                if (value != null && value.isNotEmpty) {
                  await _fetchMstStockId(value); // ✅ ดึง mststockid
                }
              },
              selectedStorage: selectedStorage,
              storageList: storageList,
              onStorageChanged: (value) {
                setState(() => selectedStorage = value);
                _savePreference("selectedStorage", value);
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

                      final payload = {
                        "stockno": selectedDocument ?? '',
                        "mststockid": mstStockId,
                        "branchname": selectedBranch ?? '',
                        "emp_fname": widget.empName,
                        "stockItems":
                            stockData
                                .map(
                                  (e) => {
                                    "stockno": e['รหัสสินค้า'],
                                    "location": e['ที่เก็บ'],
                                    "qtycount":
                                        int.tryParse(e['จำนวน'] ?? '0') ?? 0,
                                  },
                                )
                                .toList(),
                      };

                      try {
                        // 1️⃣ saveStock API
                        final success = await api.saveStock(payload);
                        if (!success) {
                          _showCustomPopup(
                            title: 'ล้มเหลว',
                            message: 'ไม่สามารถบันทึกข้อมูลได้',
                            success: false,
                          );
                          return;
                        }

                        // 2️⃣ PATCH updateInventoryCheck
                        final patchUrl = Uri.parse(
                          'https://erp-dev.somjai.app/api/mststocks/updateInventoryCheck/?token=${widget.token}',
                        );
                        final patchBody = jsonEncode({
                          "mststockid": mstStockId,
                          "stockItems":
                              stockData
                                  .map(
                                    (e) => {
                                      "stockno": e['รหัสสินค้า'],
                                      "location": e['ที่เก็บ'],
                                      "qtycount":
                                          int.tryParse(e['จำนวน'] ?? '0') ?? 0,
                                    },
                                  )
                                  .toList(),
                        });

                        final patchResponse = await http.patch(
                          patchUrl,
                          headers: {'Content-Type': 'application/json'},
                          body: patchBody,
                        );

                        if (patchResponse.statusCode == 200) {
                          _showCustomPopup(
                            title: 'สำเร็จ',
                            message: 'บันทึกและอัปเดตข้อมูลเรียบร้อยแล้ว',
                            success: true,
                          );
                          setState(() {
                            stockData.clear();
                            mstStockId = null;
                          });
                        } else {
                          _showCustomPopup(
                            title: 'ล้มเหลว',
                            message:
                                'บันทึกสำเร็จแต่ updateInventoryCheck ไม่สำเร็จ: ${patchResponse.statusCode}',
                            success: false,
                          );
                        }
                      } catch (e) {
                        _showCustomPopup(
                          title: 'ข้อผิดพลาด',
                          message: 'เกิดข้อผิดพลาด: $e',
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
                  )

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

