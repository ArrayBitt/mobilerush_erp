import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordCardMotor extends StatefulWidget {
  final String employeeName;
  final String initialRecordDate;

  const RecordCardMotor({
    super.key,
    required this.employeeName,
    required this.initialRecordDate,
  });

  @override
  State<RecordCardMotor> createState() => _RecordCardMotorState();
}

class _RecordCardMotorState extends State<RecordCardMotor> {
  late TextEditingController _employeeControllerMotor;
  late TextEditingController _dateControllerMotor;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _employeeControllerMotor = TextEditingController(text: widget.employeeName);
    _dateControllerMotor = TextEditingController(text: widget.initialRecordDate);
  }

  @override
  void dispose() {
    _employeeControllerMotor.dispose();
    _dateControllerMotor.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate =
        DateTime.tryParse(_dateControllerMotor.text) ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('th', 'TH'), // กรณีต้องการภาษาไทย
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        _dateControllerMotor.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อพนักงาน (label ปรับไม่หนา)
                const Text('ชื่อพนักงาน', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  readOnly: true,
                  controller: _employeeControllerMotor,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),

                // วันที่บันทึก (label ปรับไม่หนา)
                const Text('วันที่บันทึก', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateControllerMotor,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
