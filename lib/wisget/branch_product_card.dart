import 'dart:convert';

import 'package:stock_count/dialog/edit_stock_dialog.dart';
import 'package:stock_count/dialog/scan_result_dialog.dart';
import 'package:stock_count/states/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'dart:async';

class BranchProductCardMotor extends StatefulWidget {
  final String? selectedBranchMortor;
  final ValueChanged<String?> onBranchChangedMortor;

  final String? selectedProductMortor;
  final ValueChanged<String?> onProductChangedMortor;

  final String? selectedDocumentMortor;
  final ValueChanged<String?> onDocumentChangedMortor;

  final String? selectedStorageMortor;

  final List<Map<String, dynamic>> storageListMortor;

  final ValueChanged<String?> onStorageChangedMortor;

  final void Function(List<Map<String, String>> stockDataM)? onAddItem;

  final String? selectedLocationMortor;

  final ValueChanged<String?>? onLocationChangedMortor;

  final Future<void> Function(String docNo)? fetchMstStockIdCallback;

  final List<String> productListMortor;

  final String apiToken;

  const BranchProductCardMotor({
    super.key,
    required this.selectedBranchMortor,
    required this.onBranchChangedMortor,
    required this.selectedProductMortor,
    required this.onProductChangedMortor,
    required this.selectedDocumentMortor,
    required this.onDocumentChangedMortor,
    required this.selectedStorageMortor,
    required this.storageListMortor,
    required this.onStorageChangedMortor,
    required this.apiToken,
    this.onAddItem,
    this.selectedLocationMortor,
    this.onLocationChangedMortor,
    this.fetchMstStockIdCallback,
    required this.productListMortor,
  });

  @override
  State<BranchProductCardMotor> createState() => _BranchProductCardMotorState();
}

class _BranchProductCardMotorState extends State<BranchProductCardMotor> {
  late ApiService apiService;

  String? currentDocument;
  String? currentBranch;
  String? currentBranchDisplay;
  String? currentLocation;
  String? currentProduct;

  List<String> documentList = [];
  List<String> branchList = [];
  List<String> locationList = [];




  List<Map<String, String>> stockDataM = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService(widget.apiToken);

    currentDocument = widget.selectedDocumentMortor;
    currentBranch = widget.selectedBranchMortor;
    currentBranchDisplay =
        widget.selectedBranchMortor != null
            ? widget.selectedBranchMortor
            : null;
    currentLocation = widget.selectedLocationMortor;
    currentProduct = widget.selectedProductMortor;

    fetchLocationsFromApi(); // ✅ เพิ่ม: โหลด location
   

    loadStockData();
  }

 

  Future<void> loadStockData() async {
    // ✅ เพิ่ม
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
      _notifyParent(); // ✅ เพิ่ม: แจ้ง parent
    }
  }

  Future<void> saveStockData() async {
    // ✅ เพิ่ม
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(stockDataM);
    await prefs.setString('stockDataM', jsonData);
  }



  


  Future<List<String>> fetchDocuments(String filter) async {
    try {
      final docs = await apiService.fetchDocuments(filter);
      documentList = docs;
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
        locationList = locations;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _notifyParent() {
    if (widget.onAddItem != null) {
      widget.onAddItem!(List<Map<String, String>>.from(stockDataM));
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
                        'ข้อมูล STOCK รถยนต์',
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
                      selectedItem: currentDocument,
                      asyncItems: fetchDocuments,
                      filterFn: (item, filter) {
                        if (filter.isEmpty) return true;
                        final last4 =
                            item.length >= 4
                                ? item.substring(item.length - 4)
                                : item;
                        return last4.contains(filter);
                      },
                      onChanged: (value) async {
                        setState(() {
                          currentDocument = value;
                        });
                        widget.onDocumentChangedMortor(value);

                        if (value != null) {
                          // เรียก callback จาก parent
                          await widget.fetchMstStockIdCallback?.call(value);

                          final branchFull = await fetchBranchByDocument(value);
                          if (branchFull != null) {
                            setState(() {
                              currentBranchDisplay = branchFull;
                              currentBranch = branchFull.split(' - ').last;
                              branchList = [branchFull];
                            });
                            widget.onBranchChangedMortor(currentBranch);
                          }
                        }
                      },

                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'พิมพ์เลข 4 ตัวท้ายเอกสาร',
                            fillColor: Colors.white,
                            filled: true,
                          ),
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
                      value: currentBranchDisplay,
                      list: branchList,
                      hint: 'เลือกสาขา',
                      onChanged: (value) {
                        setState(() {
                          currentBranchDisplay = value;
                          currentBranch = value?.split(' - ').last.trim();
                        });
                        widget.onBranchChangedMortor(currentBranch);
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
                    DropdownSearch<String>(
                      selectedItem: currentLocation,
                      items:
                          widget.storageListMortor
                              .map(
                                (e) =>
                                    '${e['location']} - ${e['locationname']}',
                              )
                              .toList(),
                      onChanged: (value) async {
                        setState(() {
                          currentLocation = value;
                        });

                        final locationCode = value?.split(' - ').first.trim();
                        widget.onStorageChangedMortor(locationCode);
                      


                        print("📌 extracted onlyLocation -> $locationCode");
                      },

                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'พิมพ์เลข 2 ตัวท้ายที่เก็บ',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'เลือกที่เก็บ',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),

                    // รหัสสินค้า
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'รหัสสินค้า',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // รหัสสินค้า
                    // รหัสสินค้า
                  DropdownSearch<String>(
                      selectedItem: currentProduct,
                      items: widget.productListMortor, // ✅ ดึงจาก parent ตรง ๆ
                      filterFn: (item, filter) {
                        if (filter.isEmpty) return true;
                        final last4 =
                            item.length >= 4
                                ? item.substring(item.length - 4)
                                : item;
                        return last4.contains(filter);
                      },
                      onChanged: (value) {
                        setState(() {
                          currentProduct = value;
                        });
                        widget.onProductChangedMortor(value);
                      },
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'พิมพ์เลข 4 ตัวท้ายรหัสสินค้า',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'เลือกสินค้า',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),


                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (currentProduct != null &&
                              currentLocation != null) {
                            final onlyLocation =
                                currentLocation!.split(' - ').last.trim();
                            setState(() {
                              stockDataM.add({
                                'รหัสสินค้า': currentProduct!,
                                'ที่เก็บ': onlyLocation,
                                'จำนวน': '0',
                              });
                              currentProduct = null;
                              currentLocation = null;
                            });

                            saveStockData(); // ✅ เพิ่ม
                            _notifyParent();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'เพิ่มสินค้า ${stockDataM.last['รหัสสินค้า']} สำเร็จ',
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
                                'รหัสสินค้า',
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
                            // รหัสสินค้า (เดิม)
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
                                              'คุณต้องการลบสินค้า ${data['รหัสสินค้า']} หรือไม่?',
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
                                      saveStockData();
                                      _notifyParent();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        data['รหัสสินค้า'] ?? '',
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
                                          productCode: data['รหัสสินค้า'] ?? '',
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
                                          newQty.toString(); // 🔹 แก้ไข
                                    });
                                    saveStockData(); // ✅ เพิ่ม
                                    _notifyParent(); // ✅ เพิ่ม
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
                                        // 🔹 ตรวจสอบว่าแถวไหนตรงกับรหัสที่สแกน
                                        if (stockDataM[i]['รหัสสินค้า'] ==
                                            scannedCode) {
                                          // 🔹 อัปเดตจำนวน +1
                                          final qtyCount =
                                              int.tryParse(
                                                stockDataM[i]['จำนวน'] ?? '0',
                                              ) ??
                                              0;
                                          stockDataM[i]['จำนวน'] =
                                              (qtyCount + 1).toString();
                                          found = true;
                                          break; // 🔹 ออก loop หลังเจอแถวแรก
                                        }
                                      }
                                    });

                                    // ✅ บันทึกลง SharedPreferences
                                    await saveStockData();

                                    // ✅ แจ้ง parent widget ว่ามีการอัปเดต stockData
                                    _notifyParent();

                                    // ✅ แสดง popup ผลลัพธ์
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => ScanResultDialog(
                                            code: scannedCode,
                                            success:
                                                found, // แสดงว่าเจอสินค้าหรือไม่
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
