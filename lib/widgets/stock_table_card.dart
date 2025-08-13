import 'package:flutter/material.dart';
import '../dialog/edit_stock_dialog.dart'; // import dialog ที่แยกไฟล์

class StockTableCard extends StatefulWidget {
  final List<Map<String, String>> stockData;

  const StockTableCard({super.key, required this.stockData});

  @override
  State<StockTableCard> createState() => _StockTableCardState();
}

class _StockTableCardState extends State<StockTableCard> {
  int selectedPage = 1;
  final List<int> pageOptions = [1, 2, 3, 4, 5];
  int itemsPerPage = 1;

  int getTotalQuantity() {
    int total = 0;
    for (var item in widget.stockData) {
      total += int.tryParse(item['จำนวน'] ?? '0') ?? 0;
    }
    return total;
  }

  Future<void> _editQuantity(int index) async {
    var data = widget.stockData[index];
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
        widget.stockData[index]['จำนวน'] = newQuantity.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('แก้ไขจำนวนสินค้า $productCode เป็น $newQuantity'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuantity = getTotalQuantity();
    final totalPages = (widget.stockData.length / itemsPerPage).ceil();

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
                            'ลำดับ',
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
                            'จำนวน',
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
                ...widget.stockData.asMap().entries.map((entry) {
                  int index = entry.key;
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
                              data['ลำดับ'] ?? '',
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
                          // รวมทั้งหมด (อัพเดตแถวแรกเป็นตัวอย่าง)
                          if (widget.stockData.isEmpty) return;
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
                    const Text(
                      'รายการ / หน้า : ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: itemsPerPage,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 24,
                        ),
                        underline: const SizedBox(),
                        items:
                            pageOptions.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            itemsPerPage = newValue!;
                            selectedPage = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${((selectedPage - 1) * itemsPerPage) + 1} - ${((selectedPage * itemsPerPage) > widget.stockData.length ? widget.stockData.length : (selectedPage * itemsPerPage))} จาก ${widget.stockData.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
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
