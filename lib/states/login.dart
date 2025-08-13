import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // card กว้าง 55% ของหน้าจอ สูงสุด 260
    final cardWidth = screenWidth * 0.55 > 260 ? 260.0 : screenWidth * 0.55;

    // รูปใหญ่ fixed height เพิ่มขึ้น
    final imageHeight = 200.0;
    final imageWidth = screenWidth * 0.5 > 220 ? 220.0 : screenWidth * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังแบ่งครึ่งแนวนอน + ฟุตเตอร์แดง
          Column(
            children: [
              Expanded(child: Container(color: const Color(0xFFBF0000))),
              Expanded(child: Container(color: Colors.white)),
              // ฟุตเตอร์แดง พร้อมข้อความกึ่งกลาง
              Container(
                height: 50, // ความสูงฟุตเตอร์
                color: const Color(0xFFBF0000), // สีแดงฟุตเตอร์
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

          // รูปอยู่บนสุด กึ่งกลางแนวนอน
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icon/logo.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // การ์ดอยู่กึ่งกลางหน้าจอจริงๆ
          Center(
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT STOCK
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBF0000),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'PRODUCT STOCK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Username
                  const Text(
                    'Username',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password
                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LOG IN ปุ่ม
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBF0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // TODO: ฟังก์ชัน login
                      },
                      child: const Text(
                        'LOG IN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
