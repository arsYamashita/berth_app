import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            // 配送日
            Text('配送日'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: ''),
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
                    decoration: InputDecoration(labelText: ''),
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
              ],
            ),
            SizedBox(height: 16.0),
            // センター
            Text('センター'),
            TextField(
              decoration: InputDecoration(labelText: ''),
              onChanged: (value) {
                setState(() {
                  _branchCode = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            // 配送日時
            Text('配送日時'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: ''),
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
                    decoration: InputDecoration(labelText: ''),
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
              ],
            ),
            SizedBox(height: 16.0),
            // 納品口
            Text('納品口'),
            TextField(
              decoration: InputDecoration(labelText: ''),
              onChanged: (value) {
                setState(() {
                  _deliveryPort = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            // 取引先CD
            Text('取引先CD'),
            TextField(
              decoration: InputDecoration(labelText: ''),
              onChanged: (value) {
                setState(() {
                  _customerCode = value;
                });
              },
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
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:DataTable(
          columns: [
            DataColumn(label: Text('日付')),
            DataColumn(label: Text('時間')),
            DataColumn(label: Text('センター')),
            DataColumn(label: Text('取引先CD')),
            DataColumn(label: Text('取引先名')),
            DataColumn(label: Text('納品口')),
          ],
          rows: List<DataRow>.generate(
            searchResults.length,
                (index) {
              Map<String, dynamic> deliveryData = searchResults[index].data() as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(Text(deliveryData['date'].toString())), // 日付のキーは適切なものに変更
                  DataCell(Text(deliveryData['time'].toString())), // 時間のキーは適切なものに変更
                  DataCell(Text(deliveryData['branchCode'].toString())),
                  DataCell(Text(deliveryData['userCode'].toString())),
                  DataCell(Text(deliveryData['userName'].toString())),
                  DataCell(Text(deliveryData['deliveryPort'].toString())),
                ],
              );
            },
          ),
        ));
  }
}