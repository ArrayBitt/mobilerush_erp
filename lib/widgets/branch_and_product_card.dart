import 'package:flutter/material.dart';

class BranchAndProductCard extends StatelessWidget {
  final String selectedBranch;
  final List<String> branchList;
  final ValueChanged<String?> onBranchChanged;

  final String selectedProduct;
  final List<String> productList;
  final ValueChanged<String?> onProductChanged;

  const BranchAndProductCard({
    super.key,
    required this.selectedBranch,
    required this.branchList,
    required this.onBranchChanged,
    required this.selectedProduct,
    required this.productList,
    required this.onProductChanged,
  });

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
                // ปุ่มแดงกดไม่ได้
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

                // สาขา label
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'สาขา',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 8),

                // Dropdown สาขา
                Center(
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
                        value: selectedBranch,
                        isExpanded: true,
                        items:
                            branchList.map((String branch) {
                              return DropdownMenuItem<String>(
                                value: branch,
                                child: Text(branch),
                              );
                            }).toList(),
                        onChanged: onBranchChanged,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // รหัสสินค้า label
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'รหัสสินค้า',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 8),

                // Dropdown รหัสสินค้า
                Center(
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
                        value: selectedProduct,
                        isExpanded: true,
                        items:
                            productList.map((String product) {
                              return DropdownMenuItem<String>(
                                value: product,
                                child: Text(product),
                              );
                            }).toList(),
                        onChanged: onProductChanged,
                      ),
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
