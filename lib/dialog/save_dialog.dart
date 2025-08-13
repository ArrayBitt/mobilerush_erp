import 'package:flutter/material.dart';

class SaveDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SaveDialog({Key? key, required this.onConfirm, required this.onCancel})
    : super(key: key);

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  bool _confirmed = false;

  void _handleConfirm() {
    setState(() {
      _confirmed = true;
    });

    // รอแสดงผลไอคอนถูกต้องสักครู่ ก่อนเรียก callback
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onConfirm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // พื้นหลังโปร่งใส
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ไอคอนแสดงสถานะ
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _confirmed
                          ? Colors.green.withOpacity(0.15)
                          : Colors.yellow.withOpacity(0.15),
                  border: Border.all(
                    color: _confirmed ? Colors.green : Colors.yellow,
                    width: 3,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _confirmed ? Icons.check : Icons.error,
                  size: 48,
                  color: _confirmed ? Colors.green : Colors.yellow[800],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _confirmed
                    ? 'บันทึกข้อมูลสำเร็จ!'
                    : 'บันทึกข้อมูลการตรวจนับสต๊อกหรือไม่ ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!_confirmed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ปุ่มยกเลิก
                    ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // ปุ่มยืนยัน
                    ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
