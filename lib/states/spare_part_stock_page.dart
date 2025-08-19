import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/branch_and_product_card.dart';
import '../widgets/record_info_card.dart';
import '../widgets/search_bar_section.dart';

import '../dialog/save_dialog.dart';

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


  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color.fromARGB(255, 249, 0, 0),
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBarSection(
              selectedOption: selectedOption,
              options: options,
              onOptionChanged:
                  (value) => setState(() => selectedOption = value!),
              searchController: searchController,
            ),
            const SizedBox(height: 16),
            BranchAndProductCard(
              selectedBranch: selectedBranch,
              onBranchChanged:
                  (value) => setState(() => selectedBranch = value),
              selectedProduct: selectedProduct,
              onProductChanged: (value) {
                setState(() => selectedProduct = value);
                if (value != null) {
                  final code = value.split(' : ')[0];
                
                }
              },
              selectedDocument: selectedDocument,
              onDocumentChanged:
                  (value) => setState(() => selectedDocument = value),
              selectedStorage: selectedStorage,
              storageList: storageList,
              onStorageChanged:
                  (value) => setState(() => selectedStorage = value),
              apiToken: widget.token,
              onAddItem: (productCode, location) {

              },
            ),
            const SizedBox(height: 16),
   
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => SaveDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              onConfirm: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                                  ),
                                );
                                print('บันทึกข้อมูลการตรวจนับสต๊อกเรียบร้อย');
                              },
                            ),
                      );
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
