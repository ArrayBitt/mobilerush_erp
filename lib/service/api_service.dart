// service/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiToken;

  ApiService(this.apiToken);

  /// ดึงสินค้าทั้งหมด
  Future<List<String>> fetchProducts() async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/submodels/getAllBysearchSparecheckstock?keyword=',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => '${e['submodel_code']}').toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  /// ดึงเอกสารโดยกรองด้วย keyword
  Future<List<String>> fetchDocuments(String filter) async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/mststocks/getInventoryCheckCar?keyword=&token=$filter',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map<String>((item) => item['stockno']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      throw Exception('Failed to load documents: ${response.statusCode}');
    }
  }

  /// ดึงสาขาของเอกสาร
  Future<String?> fetchBranchByDocument(String stockno) async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/mststocks/getInventoryCheckCar?keyword=$stockno',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final branchObj = data.first['branchformtran'];
        if (branchObj != null) {
          return '${branchObj['branchcode']} - ${branchObj['branchname']}';
        }
      }
    }
    return null;
  }

  /// ดึงตำแหน่งที่เก็บทั้งหมด
  Future<List<String>> fetchLocations() async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/locationitems/getAllLocationByselect',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map<String>(
            (item) => '${item['locationname']} - ${item['location']}',
          )
          .toList();
    } else {
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  }

  /// บันทึกสต๊อกใหม่
  Future<bool> saveStock(Map<String, dynamic> payload) async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/sparestocks/saveStock',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['success'] == true;
    } else {
      throw Exception('Failed to save stock: ${response.statusCode}');
    }
  }

Future<List<String>> fetchchassisno() async {
    final url = Uri.parse(
      'https://erp-dev.somjai.app/api/stockitems/getdatabychassisno?keyword=',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

   
    print('DEBUG: apiToken = $apiToken');
    print('DEBUG: url = $url');
    print('DEBUG: statusCode = ${response.statusCode}');
    print('DEBUG: body = ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => '${e['chassisno']}').toList();
    } else {
      throw Exception('Failed to load chassisno: ${response.statusCode}');
    }
  }


}
