import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DeliverySearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> searchDeliveries({
    DateTime? deliveryStartDate,
    DateTime? deliveryEndDate,
    String? branchCode,
    String? deliveryStartTime,
    String? deliveryEndTime,
    String? customerCode,
    String? deliveryPort,
  }) async {
    Query query = _firestore.collection('reservation');

    // 必要に応じて、条件に基づいてクエリを構築
    if (deliveryStartDate != null) {
      query = query.where('deliveryStartDate', isEqualTo: deliveryStartDate);
    }
    if (deliveryEndDate != null) {
      query = query.where('deliveryEndDate', isEqualTo: deliveryEndDate);
    }
    if (branchCode != null) {
      query = query.where('branchCode', isEqualTo: branchCode);
    }
    if (customerCode != null) {
      query = query.where('userCode', isEqualTo: customerCode);
    }

    if (deliveryPort != null) {
      query = query.where('deliveryPort', isEqualTo: deliveryPort);
    }


    // 他の条件にも同様に対応

    // クエリを実行し、結果を取得
    QuerySnapshot querySnapshot = await query.get();

    // 結果をリストとして返す
    return querySnapshot.docs;
  }
}

class SearchArrivalPage extends StatefulWidget {
  @override
  _SearchArrivalPageState createState() => _SearchArrivalPageState();
}

class _SearchArrivalPageState extends State<SearchArrivalPage> {
  final DeliverySearchService deliverySearchService = DeliverySearchService();
  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;
  String? _branchCode;
  String? _deliveryStartTime;
  String? _deliveryEndTime;
  String? _customerCode;
  String? _deliveryPort;
  List<DocumentSnapshot> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('納品指定内容確認'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  child: Text('配送日'),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _deliveryStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _deliveryStartDate = selectedDate;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _deliveryStartDate != null
                              ? DateFormat('yyyyMMdd').format(_deliveryStartDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                Text(' 〜 '),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _deliveryEndDate = selectedDate;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _deliveryEndDate != null
                              ? DateFormat('yyyyMMdd').format(_deliveryEndDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 80,
                  child: Text('センター'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _branchCode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 80,
                  child: Text('配送日時'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _deliveryStartTime = value;
                      });
                    },
                  ),
                ),
                Text(' 〜 '),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _deliveryEndTime = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 80,
                  child: Text('納品口'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _deliveryPort = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 80,
                  child: Text('取引先CD'),
                ),
                Container(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _customerCode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    List<DocumentSnapshot> results = await deliverySearchService.searchDeliveries(
                      deliveryStartDate: _deliveryStartDate,
                      deliveryEndDate: _deliveryEndDate,
                      branchCode: _branchCode,
                      deliveryStartTime: _deliveryStartTime,
                      deliveryEndTime: _deliveryEndTime,
                      customerCode: _customerCode,
                      deliveryPort: _deliveryPort,
                    );
                    setState(() {
                      _searchResults = results;
                    });
                  },
                  child: Text('検索'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            const Divider(
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                child: Text('No results found.'),
              )
                  : DeliverySearchResultTable(
                searchResults: _searchResults as List<dynamic>,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}


class DeliverySearchResultTable extends StatelessWidget {
  final List<dynamic> searchResults; // 仮の検索結果データ

  // コンストラクタ
  DeliverySearchResultTable({required this.searchResults});

  // 表示したいデータに応じて適切な Widget を構築
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('日付'),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('時間'),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('センター'),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('取引先CD'),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('取引先名'),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 100, // 列の幅を設定
                  child: Text('納品口'),
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              searchResults.length,
                  (index) {
                Map<String, dynamic> deliveryData = searchResults[index].data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['date'].toString()),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['time'].toString()),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['branchCode'].toString()),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['userCode'].toString()),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['userName'].toString()),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100, // 列の幅を設定
                        child: Text(deliveryData['deliveryPort'].toString()),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}