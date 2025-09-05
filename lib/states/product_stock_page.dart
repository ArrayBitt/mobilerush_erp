import 'package:stock_count/dialog/logout_dialog.dart';
import 'package:stock_count/states/spare_part_stock_page.dart';
import 'package:flutter/material.dart';
import 'motorcycle_stock_page.dart'; // เพิ่ม import หน้าเป้าหมาย

class ProductStockPage extends StatefulWidget {
  final String token; // เพิ่ม token
  final String empName;

  const ProductStockPage({
    super.key,
    required this.token,

    required this.empName,
  });

  @override
  State<ProductStockPage> createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 225, 225),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 8.0),
              child: Image.asset(
                'assets/icon/somjai.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'PRODUCT STOCK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.1,
                color: Colors.black,
              ),
            ),
          ],
        ),
       actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const LogoutDialog(),
                );
              },
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ตรวจสอบข้อมูล STOCK สินค้า นี้',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // การ์ดรถจักรยานยนต์ (เพิ่ม InkWell ล้อมรอบ)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 340,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MotorcycleStockPage(
                                      token: widget.token,
                                      empName: widget.empName,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            color: const Color(0xFFBF0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.motorcycle_rounded,
                                    color: Colors.white,
                                    size: 110,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'รถจักรยานยนต์',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Motorcycle stock',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // การ์ดอะไหล่
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 340,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // ส่ง token จริงจาก ProductStockPage
                                builder:
                                    (context) => SparePartStockPage(
                                      token: widget.token, empName: widget.empName,
                                      
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            color: const Color(0xFFBF0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 110,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'อะไหล่',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Spare part',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

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