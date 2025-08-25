import 'dart:convert';

import 'package:erp/dialog/edit_stock_dialog.dart';
import 'package:erp/dialog/scan_result_dialog.dart';
import 'package:erp/states/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'dart:async';

class BranchProductCardMotor extends StatefulWidget {
  final String? selectedBranchMotor;
  final ValueChanged<String?> onBranchChangedMotor;

  final String? selectedChasisnoMotor;
  final ValueChanged<String?> onChasisnoChangedMotor;

  final String? selectedDocumentMotor;
  final ValueChanged<String?> onDocumentChangedMotor;

  final String? selectedStorageMotor;
  final List<String> storageListMotor;
  final ValueChanged<String?> onStorageChangedMotor;

  final void Function(List<Map<String, String>> stockDataM)? onAddItemMotor;

  final String? selectedLocationMotor;
  final ValueChanged<String?>? onLocationChangedMotor;

  final String apiToken;

  const BranchProductCardMotor({
    super.key,
    required this.selectedBranchMotor,
    required this.onBranchChangedMotor,
    required this.selectedChasisnoMotor,
    required this.onChasisnoChangedMotor,
    required this.selectedDocumentMotor,
    required this.onDocumentChangedMotor,
    required this.selectedStorageMotor,
    required this.storageListMotor,
    required this.onStorageChangedMotor,
    required this.apiToken,
    this.onAddItemMotor,
    this.selectedLocationMotor,
    this.onLocationChangedMotor,
  });

  @override
  State<BranchProductCardMotor> createState() => _BranchProductCardMotorState();
}

class _BranchProductCardMotorState extends State<BranchProductCardMotor> {
  late ApiService apiService;

  String? currentDocumentMotor;
  String? currentBranchMotor;
  String? currentBranchDisplayMotor;
  String? currentLocationMotor;
  String? currentChasisnoMotor;
  String? apiToken;

  List<String> documentListMotor = [];
  List<String> branchListMotor = [];
  List<String> locationListMotor = [];
  List<String> chasisnoListMotor = [];

  List<Map<String, String>> stockDataM = [];

  @override
  void initState() {
    super.initState();
    _initApiTokenAndFetch(); // ✅ เรียกโหลด token และ fetch api

    currentDocumentMotor = widget.selectedDocumentMotor;
    currentBranchMotor = widget.selectedBranchMotor;
    currentBranchDisplayMotor =
        widget.selectedBranchMotor != null ? widget.selectedBranchMotor : null;
    currentLocationMotor = widget.selectedLocationMotor;
    chasisnoListMotor =
        widget.selectedChasisnoMotor != null
            ? [widget.selectedChasisnoMotor!]
            : [];

    loadStockDataM(); // โหลด stockData จาก SharedPreferences
  }

  Future<void> _initApiTokenAndFetch() async {
    String token = widget.apiToken;

    // fallback จาก SharedPreferences เผื่อว่าง
    if (token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ?? '';
    }

    if (token.isEmpty) {
      print('ERROR: No API token found!');
      return; // ยังไม่เจอ token
    }

    print('DEBUG: Using apiToken = $token');

    apiToken = token;
    apiService = ApiService(apiToken!);

    // ดึงข้อมูลจาก API
    try {
      await fetchLocationsFromApi();
      await fetchProductsFromApi();
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  // โหลด stockData จาก SharedPreferences
  Future<void> loadStockDataM() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('stockDataM');
    if (jsonData != null) {
      final List<dynamic> decoded = jsonDecode(jsonData);
      setState(() {
        stockDataM =
            decoded
                .map<Map<String, String>>((e) => Map<String, String>.from(e))
                .toList();
      });
      _notifyParent();
    }
  }

  // บันทึก stockData ลง SharedPreferences
  Future<void> saveStockDataM() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(stockDataM);
    await prefs.setString('stockDataM', jsonData);
  }

  Future<void> fetchProductsFromApi() async {
    try {
      final chasisno = await apiService.fetchchassisno();
      setState(() {
        chasisnoListMotor = chasisno;
      });
      print('Fetched products: $chasisnoListMotor');
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<List<String>> fetchDocuments(String filter) async {
    try {
      final docs = await apiService.fetchDocuments(filter);
      documentListMotor = docs;
      return docs;
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  Future<String?> fetchBranchByDocument(String stockno) async {
    try {
      final branch = await apiService.fetchBranchByDocument(stockno);
      return branch;
    } catch (e) {
      print('Error fetching branch: $e');
      return null;
    }
  }

  Future<void> fetchLocationsFromApi() async {
    try {
      final locations = await apiService.fetchLocations();
      setState(() {
        locationListMotor = locations;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _notifyParent() {
    if (widget.onAddItemMotor != null) {
      widget.onAddItemMotor!(List<Map<String, String>>.from(stockDataM));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            // Card หลัก
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF0000),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ข้อมูล STOCK สินค้าอะไหล่',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // เอกสาร
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'เอกสาร',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownSearch<String>(
                      selectedItem: currentDocumentMotor,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'พิมพ์เพื่อค้นหาเอกสาร',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                        menuProps: const MenuProps(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'เลือกเอกสาร',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      asyncItems: fetchDocuments,
                      onChanged: (value) async {
                        setState(() {
                          currentDocumentMotor = value;
                        });
                        widget.onDocumentChangedMotor(value);

                        if (value != null) {
                          final branchFull = await fetchBranchByDocument(value);
                          if (branchFull != null) {
                            setState(() {
                              currentBranchDisplayMotor =
                                  branchFull; // แสดง dropdown
                              currentBranchMotor =
                                  branchFull
                                      .split(' - ')
                                      .last; // ส่ง branch name
                              branchListMotor = [
                                branchFull,
                              ]; // list ของ dropdown
                            });
                            widget.onBranchChangedMotor(currentBranchMotor);
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'สาขา',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: currentBranchDisplayMotor,
                      list: branchListMotor,
                      hint: 'เลือกสาขา',
                      onChanged: (value) {
                        setState(() {
                          currentBranchDisplayMotor = value;
                          currentBranchMotor = value?.split(' - ').last.trim();
                        });
                        widget.onBranchChangedMotor(currentBranchMotor);
                      },
                      enabled: false,
                    ),

                    // ที่เก็บ
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'ที่เก็บ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: currentLocationMotor,
                      list: locationListMotor,
                      hint: 'เลือกที่เก็บ',
                      onChanged: (value) {
                        setState(() {
                          currentLocationMotor = value;
                        });
                        widget.onLocationChangedMotor?.call(value);
                      },
                    ),

                    // รหัสเลขถัง
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'เลขถัง',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: currentChasisnoMotor,
                      list: chasisnoListMotor,
                      hint: 'เลือกเลขถัง',
                      onChanged: (value) {
                        setState(() {
                          currentChasisnoMotor = value;
                        });
                        widget.onChasisnoChangedMotor(value);
                      },
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (currentChasisnoMotor != null &&
                              currentLocationMotor != null) {
                            final onlyLocation =
                                currentLocationMotor!.split(' - ').last.trim();
                            setState(() {
                              stockDataM.add({
                                'เลขถัง': currentChasisnoMotor!,
                                'ที่เก็บ': onlyLocation,
                                'จำนวน': '0',
                              });
                              currentChasisnoMotor = null;
                              currentLocationMotor = null;
                            });

                            saveStockDataM(); // <-- เพิ่มตรงนี้
                            _notifyParent();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'เพิ่มเลขถัง ${stockDataM.last['เลขถัง']} สำเร็จ',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณาเลือกสินค้าและที่เก็บ'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มเข้าตาราง'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBF0000),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ตาราง stockData
            if (stockDataM.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF0000),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'รายการสินค้าในสต็อก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Row(
                        children: const [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'เลขถัง',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'ที่เก็บ',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'จำนวน',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'สแกน',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...stockDataM.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;
                      return Container(
                        color:
                            index % 2 == 0
                                ? Colors.white
                                : Colors.grey.shade100,
                        child: Row(
                          children: [
                            // เลขถัง
                            Expanded(
                              child: Center(
                                child: InkWell(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'ลบสินค้า',
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Text(
                                              'คุณต้องการลบสินค้า ${data['เลขถัง']} หรือไม่?',
                                              textAlign: TextAlign.center,
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment
                                                    .center, // จัดปุ่มกลาง
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center, // จัดปุ่มกลาง
                                                children: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('ยกเลิก'),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    child: const Text('ลบ'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      setState(() {
                                        stockDataM.removeAt(index);
                                      });
                                      saveStockDataM();
                                      _notifyParent();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        data['เลขถัง'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ที่เก็บ (เดิม)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  data['ที่เก็บ'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            // จำนวน (แก้ใหม่ ให้เรียก dialog)
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final newQty = await showDialog<int>(
                                    context: context,
                                    builder:
                                        (_) => EditStockDialog(
                                          productCode: data['เลขถัง'] ?? '',
                                          currentQuantity:
                                              int.tryParse(
                                                data['จำนวน'] ?? '0',
                                              ) ??
                                              0,
                                        ),
                                  );

                                  if (newQty != null) {
                                    setState(() {
                                      stockDataM[index]['จำนวน'] =
                                          newQty.toString();
                                    });
                                    saveStockDataM();
                                    _notifyParent();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    data['จำนวน'] ?? '0',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // สแกน QR (เดิม) --> แก้เป็น:
                            Expanded(
                              child: IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                onPressed: () async {
                                  final scannedCode =
                                      await Navigator.push<String?>(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => const MobileScannerPage(),
                                        ),
                                      );

                                  if (scannedCode != null) {
                                    bool found = false;

                                    setState(() {
                                      for (
                                        int i = 0;
                                        i < stockDataM.length;
                                        i++
                                      ) {
                                        if (stockDataM[i]['เลขถัง'] ==
                                            scannedCode) {
                                          final qtyCount =
                                              int.tryParse(
                                                stockDataM[i]['จำนวน'] ?? '0',
                                              ) ??
                                              0;
                                          stockDataM[i]['จำนวน'] =
                                              (qtyCount + 1).toString();
                                          found = true;
                                          break; // เพิ่มแถวเดียวที่ตรง
                                        }
                                      }
                                    });

                                    await saveStockDataM();
                                    _notifyParent();

                                    // แสดง popup
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => ScanResultDialog(
                                            code: scannedCode,
                                            success: found,
                                          ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> list,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return DropdownSearch<String>(
      selectedItem: value,
      items: list,
      enabled: enabled,
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'ค้นหา',
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
