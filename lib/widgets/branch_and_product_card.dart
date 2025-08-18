import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

class BranchAndProductCard extends StatefulWidget {
  final String? selectedBranch;
  final ValueChanged<String?> onBranchChanged;

  final String? selectedProduct;
  final List<String> productList;
  final ValueChanged<String?> onProductChanged;

  final String? selectedDocument;
  final ValueChanged<String?> onDocumentChanged;

  final String? selectedStorage;
  final List<String> storageList;
  final ValueChanged<String?> onStorageChanged;

  // เพิ่ม callback สำหรับ Location
  final String? selectedLocation;
  final ValueChanged<String?>? onLocationChanged;

  final String apiToken;

  const BranchAndProductCard({
    super.key,
    required this.selectedBranch,
    required this.onBranchChanged,
    required this.selectedProduct,
    required this.productList,
    required this.onProductChanged,
    required this.selectedDocument,
    required this.onDocumentChanged,
    required this.selectedStorage,
    required this.storageList,
    required this.onStorageChanged,
    required this.apiToken,
    this.selectedLocation,
    this.onLocationChanged,
  });

  @override
  State<BranchAndProductCard> createState() => _BranchAndProductCardState();
}

class _BranchAndProductCardState extends State<BranchAndProductCard> {
  String? currentDocument;
  String? currentBranch;
  String? currentLocation;
  List<String> documentList = [];
  List<String> locationList = [];

  @override
  void initState() {
    super.initState();
    currentDocument = widget.selectedDocument;
    currentBranch = widget.selectedBranch;
    currentLocation = widget.selectedLocation;
    fetchLocations(); // โหลด Location ตอน init
  }

  // API สำหรับเอกสาร
  Future<List<String>> fetchDocuments(String filter) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://erp-dev.somjai.app/api/mststocks/getInventoryCheckCar?keyword=$filter&token=${widget.apiToken}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<String> stockNos = [];
        for (var item in data) {
          final stockno = item['stockno'];
          if (stockno != null && stockno.isNotEmpty) {
            stockNos.add(stockno.toString());
          }
        }
        documentList = stockNos;
        return stockNos;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // API สำหรับสาขาตามเอกสาร
  Future<String?> fetchBranchByDocument(String stockno) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://erp-dev.somjai.app/api/mststocks/getInventoryCheckCar?keyword=$stockno&token=${widget.apiToken}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final item = data.first;
          final branchObj = item['branchformtran'];
          if (branchObj != null) {
            return '${branchObj['branchcode']} - ${branchObj['branchname']}';
          }
        }
      }
    } catch (e) {
      print('Error fetching branch: $e');
    }
    return null;
  }

  // API สำหรับ Location
  Future<void> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://erp-dev.somjai.app/api/locationitems/getAllLocationByselect?token=${widget.apiToken}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          locationList =
              data
                  .map<String>(
                    (item) => '${item['locationname']} - ${item['location']}',
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error fetching locations: $e');
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // --- Dropdown เอกสาร ---
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'เอกสาร',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
               DropdownSearch<String>(
                  selectedItem: currentDocument,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: const InputDecoration(
                        hintText: 'พิมพ์เพื่อค้นหาเอกสาร',
                        fillColor: Colors.white,
                        filled: true, // search box สีขาว
                      ),
                    ),
                    menuProps: const MenuProps(
                      backgroundColor: Colors.white, // ✅ popup list เป็นสีขาว
                    ),
                  ),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'เลือกเอกสาร',
                      fillColor: Colors.white,
                      filled: true, // field สีขาว
                    ),
                  ),
                  asyncItems: fetchDocuments,
                  onChanged: (value) async {
                    setState(() {
                      currentDocument = value;
                    });
                    widget.onDocumentChanged(value);

                    if (value != null) {
                      final branch = await fetchBranchByDocument(value);
                      setState(() {
                        currentBranch = branch;
                      });
                      widget.onBranchChanged(branch);
                    }
                  },
                ),


                const SizedBox(height: 8),
                // --- Dropdown สาขา ---
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'สาขา',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: currentBranch,
                  list: currentBranch != null ? [currentBranch!] : [],
                  hint: 'เลือกสาขา',
                  onChanged: (value) {
                    setState(() {
                      currentBranch = value;
                    });
                    widget.onBranchChanged(value);
                  },
                ),

                const SizedBox(height: 8),
                // --- Dropdown Location ใหม่ ---
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'ที่เก็บ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    if (widget.onLocationChanged != null) {
                      widget.onLocationChanged!(value);
                    }
                  },
                ),

                const SizedBox(height: 8),
  
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'รหัสสินค้า',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: widget.selectedProduct,
                  list: widget.productList,
                  hint: 'เลือกสินค้า',
                  onChanged: widget.onProductChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> list,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: list.contains(value) ? value : null,
            hint: Text(hint),
            isExpanded: true,
            items:
                list
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
