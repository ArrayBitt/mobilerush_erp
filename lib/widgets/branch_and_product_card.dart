import 'dart:convert';

import 'package:erp/dialog/edit_stock_dialog.dart';
import 'package:erp/dialog/scan_result_dialog.dart';
import 'package:erp/states/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'dart:async';

class BranchAndProductCard extends StatefulWidget {
  final String? selectedBranch;
  final ValueChanged<String?> onBranchChanged;

  final String? selectedProduct;
  final ValueChanged<String?> onProductChanged;

  final String? selectedDocument;
  final ValueChanged<String?> onDocumentChanged;

  final String? selectedStorage;
  final List<String> storageList;
  final ValueChanged<String?> onStorageChanged;

  final void Function(List<Map<String, String>> stockData)? onAddItem;

  final String? selectedLocation;
  final ValueChanged<String?>? onLocationChanged;

  final String apiToken;

  const BranchAndProductCard({
    super.key,
    required this.selectedBranch,
    required this.onBranchChanged,
    required this.selectedProduct,
    required this.onProductChanged,
    required this.selectedDocument,
    required this.onDocumentChanged,
    required this.selectedStorage,
    required this.storageList,
    required this.onStorageChanged,
    required this.apiToken,
    this.onAddItem,
    this.selectedLocation,
    this.onLocationChanged,
  });

  @override
  State<BranchAndProductCard> createState() => _BranchAndProductCardState();
}

class _BranchAndProductCardState extends State<BranchAndProductCard> {
  late ApiService apiService;

  String? currentDocument;
  String? currentBranch;
  String? currentBranchDisplay;
  String? currentLocation;
  String? currentProduct;

  List<String> documentList = [];
  List<String> branchList = [];
  List<String> locationList = [];
  List<String> productList = [];

  List<Map<String, String>> stockData = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService(widget.apiToken);

    currentDocument = widget.selectedDocument;
    currentBranch = widget.selectedBranch;
    currentBranchDisplay =
        widget.selectedBranch != null ? widget.selectedBranch : null;
    currentLocation = widget.selectedLocation;
    currentProduct = widget.selectedProduct;

    fetchLocationsFromApi();
    fetchProductsFromApi();

    loadStockData();
  }

  // โหลด stockData จาก SharedPreferences
  Future<void> loadStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('stockData');
    if (jsonData != null) {
      final List<dynamic> decoded = jsonDecode(jsonData);
      setState(() {
        stockData =
            decoded
                .map<Map<String, String>>((e) => Map<String, String>.from(e))
                .toList();
      });
      _notifyParent();
    }
  }

  // บันทึก stockData ลง SharedPreferences
  Future<void> saveStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(stockData);
    await prefs.setString('stockData', jsonData);
  }

  Future<void> fetchProductsFromApi() async {
    try {
      final products = await apiService.fetchProducts();
      setState(() {
        productList = products;
      });
      print('Fetched products: $productList');
    } catch (e) {
      print('Error fetching products: $e');
    }
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
      widget.onAddItem!(List<Map<String, String>>.from(stockData));
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
                      selectedItem: currentDocument,
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
                          currentDocument = value;
                        });
                        widget.onDocumentChanged(value);

                        if (value != null) {
                          final branchFull = await fetchBranchByDocument(value);
                          if (branchFull != null) {
                            setState(() {
                              currentBranchDisplay =
                                  branchFull; // แสดง dropdown
                              currentBranch =
                                  branchFull
                                      .split(' - ')
                                      .last; // ส่ง branch name
                              branchList = [branchFull]; // list ของ dropdown
                            });
                            widget.onBranchChanged(currentBranch);
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
                      value: currentBranchDisplay,
                      list: branchList,
                      hint: 'เลือกสาขา',
                      onChanged: (value) {
                        setState(() {
                          currentBranchDisplay = value;
                          currentBranch = value?.split(' - ').last.trim();
                        });
                        widget.onBranchChanged(currentBranch);
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
                      value: currentLocation,
                      list: locationList,
                      hint: 'เลือกที่เก็บ',
                      onChanged: (value) {
                        setState(() {
                          currentLocation = value;
                        });
                        widget.onLocationChanged?.call(value);
                      },
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
                    _buildDropdown(
                      value: currentProduct,
                      list: productList,
                      hint: 'เลือกสินค้า',
                      onChanged: (value) {
                        setState(() {
                          currentProduct = value;
                        });
                        widget.onProductChanged(value);
                      },
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
                              stockData.add({
                                'รหัสสินค้า': currentProduct!,
                                'ที่เก็บ': onlyLocation,
                                'จำนวน': '0',
                              });
                              currentProduct = null;
                              currentLocation = null;
                            });

                            saveStockData(); // <-- เพิ่มตรงนี้
                            _notifyParent();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'เพิ่มสินค้า ${stockData.last['รหัสสินค้า']} สำเร็จ',
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
            if (stockData.isNotEmpty)
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
                    ...stockData.asMap().entries.map((entry) {
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
                              child: InkWell(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('ลบสินค้า'),
                                          content: Text(
                                            'คุณต้องการลบสินค้า ${data['รหัสสินค้า']} หรือไม่?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('ยกเลิก'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('ลบ'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    setState(() {
                                      stockData.removeAt(index);
                                    });
                                    saveStockData();
                                    _notifyParent();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
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
                                      stockData[index]['จำนวน'] =
                                          newQty.toString();
                                    });
                                    saveStockData();
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
                                        i < stockData.length;
                                        i++
                                      ) {
                                        if (stockData[i]['รหัสสินค้า'] ==
                                            scannedCode) {
                                          final qtyCount =
                                              int.tryParse(
                                                stockData[i]['จำนวน'] ?? '0',
                                              ) ??
                                              0;
                                          stockData[i]['จำนวน'] =
                                              (qtyCount + 1).toString();
                                          found = true;
                                          break; // เพิ่มแถวเดียวที่ตรง
                                        }
                                      }
                                    });

                                    await saveStockData();
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
