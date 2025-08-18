import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dialog/edit_stock_dialog.dart';

class StockTableCard extends StatefulWidget {
  final List<Map<String, String>>? stockData;

  const StockTableCard({super.key, this.stockData});

  @override
  State<StockTableCard> createState() => _StockTableCardState();
}

class _StockTableCardState extends State<StockTableCard> {
  int selectedPage = 1;
  final List<int> pageOptions = [1, 2, 3, 4, 5];
  int itemsPerPage = 5;

  late List<Map<String, String>> displayData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('stock_display_data');

    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      displayData =
          decoded
              .map<Map<String, String>>((e) => Map<String, String>.from(e))
              .toList();
    } else {
      displayData =
          widget.stockData ??
          List.generate(
            10,
            (index) => {'รหัสสินค้า': '', 'จำนวน': '0', 'ที่เก็บ': ''},
          );
    }
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stock_display_data', jsonEncode(displayData));
  }

  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (await Permission.camera.request().isGranted) return true;
    return false;
  }

  int getTotalQuantity() {
    int total = 0;
    for (var item in displayData) {
      total += int.tryParse(item['จำนวน'] ?? '0') ?? 0;
    }
    return total;
  }

  Future<void> _editQuantity(int index) async {
    var data = displayData[index];
    final productCode = data['รหัสสินค้า'] ?? '-';
    final currentQty = int.tryParse(data['จำนวน'] ?? '0') ?? 0;

    final newQuantity = await showDialog<int>(
      context: context,
      builder:
          (context) => EditStockDialog(
            productCode: productCode,
            currentQuantity: currentQty,
          ),
    );

    if (newQuantity != null) {
      setState(() {
        displayData[index]['จำนวน'] = newQuantity.toString();
      });
      await _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('แก้ไขจำนวนสินค้า $productCode เป็น $newQuantity'),
        ),
      );
    }
  }

  Future<void> _scanQRCode(int index) async {
    if (!await _checkCameraPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ต้องให้สิทธิ์กล้องเพื่อสแกน')),
      );
      return;
    }

    String? scannedCode;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('สแกน QR/Barcode')),
              body: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final code = barcodes.first.rawValue;
                    if (code != null && scannedCode == null) {
                      scannedCode = code;
                      Future.delayed(Duration.zero, () {
                        if (mounted) Navigator.of(context).pop();
                      });
                    }
                  }
                },
              ),
            ),
      ),
    );

    if (scannedCode != null && mounted) {
      setState(() {
        displayData[index]['รหัสสินค้า'] = scannedCode!;
      });
      await _saveData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สแกนสำเร็จ: $scannedCode')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuantity = getTotalQuantity();
    final totalPages = (displayData.length / itemsPerPage).ceil();

    final startIndex = (selectedPage - 1) * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage > displayData.length)
            ? displayData.length
            : startIndex + itemsPerPage;
    final pageData = displayData.sublist(startIndex, endIndex);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Column(
              children: [
                // Header
                Container(
                  color: const Color(0xFFBF0000),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.white),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'รหัสสินค้า',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.white),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'ที่เก็บ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.white),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'จำนวน',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.white),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'scan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),

                // Rows
                ...pageData.asMap().entries.map((entry) {
                  int index = entry.key + startIndex;
                  var data = entry.value;
                  return Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['รหัสสินค้า'] ?? '',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () async {
                              final newLocation = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(
                                    text: data['ที่เก็บ'] ?? '',
                                  );
                                  return AlertDialog(
                                    title: const Text('แก้ไขที่เก็บ'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: 'ระบุที่เก็บ',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(
                                              context,
                                              controller.text,
                                            ),
                                        child: const Text('บันทึก'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (newLocation != null) {
                                setState(() {
                                  displayData[index]['ที่เก็บ'] = newLocation;
                                });
                                await _saveData();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['ที่เก็บ'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () => _editQuantity(index),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['จำนวน'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.black87,
                            ),
                            onPressed: () => _scanQRCode(index),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),

                // Total quantity
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'จำนวนสินค้าทั้งหมด : ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          if (displayData.isEmpty) return;
                          _editQuantity(0);
                        },
                        child: Container(
                          width: 80,
                          height: 36,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            totalQuantity.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pagination
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'รายการ/หน้า :',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${((selectedPage - 1) * itemsPerPage) + 1} - ${((selectedPage * itemsPerPage) > displayData.length ? displayData.length : (selectedPage * itemsPerPage))} จาก ${displayData.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed:
                          selectedPage > 1
                              ? () {
                                setState(() {
                                  selectedPage--;
                                });
                              }
                              : null,
                      icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed:
                          selectedPage < totalPages
                              ? () {
                                setState(() {
                                  selectedPage++;
                                });
                              }
                              : null,
                      icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
