import 'package:erp/dialog/save_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // เพิ่ม import
import '../widgets/branch_and_product_card.dart';

import '../widgets/record_info_card.dart'; // <-- import ตัวใหม่

class MotorcycleStockPage extends StatefulWidget {
  const MotorcycleStockPage({super.key});

  @override
  State<MotorcycleStockPage> createState() => _MotorcycleStockPage();
}

class _MotorcycleStockPage extends State<MotorcycleStockPage> {
  String selectedOption = 'ค้นหาจาก';
  final List<String> options = ['ค้นหาจาก', 'รหัส', 'ชื่อ', 'หมวดหมู่'];

  String selectedBranch = '101 : สำนักงานใหญ่';
  final List<String> branchList = ['101 : สำนักงานใหญ่'];

  String selectProduct = '06430-KPH-900 : ชุดผ้าเบรก';
  final List<String> productList = [
    '06430-KPH-900 : ชุดผ้าเบรก',
    '06431-KPH-901 : ผ้าคลัทช์',
    '06432-KPH-902 : กรองน้ำมัน',
  ];

  final List<Map<String, String>> stockData = List.generate(
    10,
    (index) => {
      'ลำดับ': '${index + 1}',
      'รหัสสินค้า': '0643${index}-KPH-90${index}',
      'จำนวน': '${(index + 1) * 5}',
    },
  );

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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'ตรวจสอบข้อมูล STOCK รถจักรยานยนต์',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                 

                  const SizedBox(height: 16),

               

                  const SizedBox(height: 16),

                  RecordInfoCard(
                    employeeName: 'สมชาย ใจดี',
                    initialRecordDate: todayStr,
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ปุ่ม ยกเลิก
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                            style: TextStyle(
                              color: Color(0xFFBF0000),
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ปุ่ม บันทึก
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SaveDialog(
                                  onCancel: () {
                                    Navigator.of(context).pop(); // ปิด popup
                                  },
                                  onConfirm: () {
                                    Navigator.of(context).pop(); // ปิด popup
                                    // ใส่โค้ดบันทึกข้อมูลที่นี่
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'บันทึกข้อมูลเรียบร้อยแล้ว',
                                        ),
                                      ),
                                    );
                                    print(
                                      'บันทึกข้อมูลการตรวจนับสต๊อกเรียบร้อย',
                                    );
                                  },
                                );
                              },
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

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ฟุตเตอร์แดงพร้อมข้อความกึ่งกลาง
          Container(
            height: 50,
            color: const Color(0xFFBF0000),
            alignment: Alignment.center,
            child: const Text(
              'www.erp.com',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
