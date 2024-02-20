import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DeliverySearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> searchDeliveries({
    DateTime? deliveryStartDate,
    DateTime? deliveryEndDate,
    String? branchCode,
    TimeOfDay? deliveryStartTime,
    TimeOfDay? deliveryEndTime,
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
  TimeOfDay? _deliveryStartTime;
  TimeOfDay? _deliveryEndTime;
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
                // 配送日
                Container(
                  width: 80,
                  child:
                  Text('配送日'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0)),
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _deliveryStartDate = selectedDate;
                        });
                      }
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
                            horizontal: 10, vertical: 0)),
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
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 80,
                  child:
                  Text('センター'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0)),
                    onChanged: (value) {
                      setState(() {
                        _branchCode = value;
                      });
                    },
                  ),
                )],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                // 配送日時
                Container(
                  width: 80,
                  child:
                  Text('配送日時'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0)),
                    onTap: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (selectedTime != null) {
                        setState(() {
                          _deliveryStartTime = selectedTime;
                        });
                      }
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
                            horizontal: 10, vertical: 0)),
                    onTap: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          _deliveryEndTime = selectedTime;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 20),
                // 納品口
                Container(
                  width: 80,
                  child:
                  Text('納品口'),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0)),
                    onChanged: (value) {
                      setState(() {
                        _deliveryPort = value;
                      });
                    },
                  ),
                )],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                // 取引先CD
                Container(
                  width: 80, // Set a fixed width
                  child: Text('取引先CD'),
                ),
                Container(
                  width: 150, // Adjust the width as needed
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
            // 検索ボタン
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
            // 検索結果（幅一杯に表示）
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