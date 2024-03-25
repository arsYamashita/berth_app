import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_web_pagination/flutter_web_pagination.dart';

class DeliverySearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> searchDeliveries({
    required String deliveryStartDate,
    required String deliveryEndDate,
    String? deliveryStartTime,
    String? deliveryEndTime,
    String? branchCode,
    String? userCode,
    String? deliveryPort,
  }) async {
    Query dateQuery = _firestore.collection('reservation');

    // deliveryStartDateとdeliveryEndDateの間の日付のデータを取得
    if (deliveryStartDate.isNotEmpty && deliveryEndDate.isNotEmpty) {
      DateTime startDate = DateTime.parse(deliveryStartDate);
      DateTime endDate =
          DateTime.parse(deliveryEndDate).add(const Duration(days: 1));

      Timestamp formattedStartDate = Timestamp.fromDate(startDate);
      Timestamp formattedEndDate = Timestamp.fromDate(endDate);

      dateQuery =
          dateQuery.where('date', isGreaterThanOrEqualTo: formattedStartDate);
      dateQuery = dateQuery.where('date', isLessThan: formattedEndDate);
    }

    // クエリを実行し、結果を取得
    QuerySnapshot dateQuerySnapshot = await dateQuery.get();

    List<DocumentSnapshot> resultSet = dateQuerySnapshot.docs;

    if (deliveryStartTime != null &&
        deliveryEndTime != null &&
        deliveryStartTime.isNotEmpty &&
        deliveryEndTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime startTime =
            DateTime.parse("2000-01-01 ${deliveryStartTime.padLeft(5, '0')}");
        DateTime endTime =
            DateTime.parse("2000-01-01 ${deliveryEndTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return (startTime.isBefore(docTimeOnlyHourMinute) ||
                startTime.isAtSameMomentAs(docTimeOnlyHourMinute)) &&
            (endTime.isAfter(docTimeOnlyHourMinute) ||
                endTime.isAtSameMomentAs(docTimeOnlyHourMinute));
      }).toList();
    } else if (deliveryStartTime != null && deliveryStartTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime startTime =
            DateTime.parse("2000-01-01 ${deliveryStartTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return startTime.isBefore(docTimeOnlyHourMinute) ||
            startTime.isAtSameMomentAs(docTimeOnlyHourMinute);
      }).toList();
    } else if (deliveryEndTime != null && deliveryEndTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime endTime =
            DateTime.parse("2000-01-01 ${deliveryEndTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return endTime.isAfter(docTimeOnlyHourMinute) ||
            endTime.isAtSameMomentAs(docTimeOnlyHourMinute);
      }).toList();
    }

    // 他の条件にも同様に対応
    if (branchCode != null && branchCode.isNotEmpty) {
      // dateQuery = dateQuery.where('branchCode', isEqualTo: branchCode);

      resultSet = resultSet.where((doc) {
        String docBranchCode = doc['branchCode'];
        return branchCode == docBranchCode;
      }).toList();
    }
    if (userCode != null && userCode.isNotEmpty) {
      // dateQuery = dateQuery.where('userCode', isEqualTo: userCode);
      resultSet = resultSet.where((doc) {
        String docUserCode = doc['userCode'];
        return userCode == docUserCode;
      }).toList();
    }
    if (deliveryPort != null && deliveryPort.isNotEmpty) {
      // dateQuery = dateQuery.where('deliveryPort', isEqualTo: deliveryPort);
      resultSet = resultSet.where((doc) {
        String docDeliveryPort = doc['deliveryPort'];
        return deliveryPort == docDeliveryPort;
      }).toList();
    }

    return resultSet;
  }
}

class SearchArrivalPage extends StatefulWidget {
  // コンストラクタに key パラメータを追加
  const SearchArrivalPage({super.key});

  @override
  _SearchArrivalPageState createState() => _SearchArrivalPageState();
}

class _SearchArrivalPageState extends State<SearchArrivalPage> {
  GlobalKey<_DeliverySearchResultTableState> _searchResultTableKey =
      GlobalKey();
  final DeliverySearchService deliverySearchService = DeliverySearchService();
  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;
  String? _branchCode;
  String? _deliveryStartTime;
  String? _deliveryEndTime;
  String? _userCode;
  String? _deliveryPort;
  List<DocumentSnapshot> _searchResults = [];
  late List<DocumentSnapshot> _currentResults;
  late int _currentPage;
  late int _totalPages;
  static const int _itemsPerPage = 100;

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
  }

  @override
  void dispose() {
    _searchResultTableKey.currentState?.dispose();
    super.dispose();
  }

  void _newUpdateResults() {
    int newTotalPages = (_searchResults.length / _itemsPerPage).ceil();

    if (_currentPage > newTotalPages) {
      _currentPage = 1;
    }

    // 新しいキーを作成
    final newKey = GlobalKey<_DeliverySearchResultTableState>();

    setState(() {
      // _searchResultTableKey.currentState?.dispose(); // 古いキーの状態を解放
      _searchResultTableKey = newKey; // 新しいキーに更新
      _currentPage = _currentPage;
      _totalPages = newTotalPages;
      _currentResults = _searchResults
          .skip((_currentPage - 1) * _itemsPerPage)
          .take(_itemsPerPage)
          .toList()
          .cast<DocumentSnapshot>();
    });
  }

  void _updateResults() {
    int newTotalPages = (_searchResults.length / _itemsPerPage).ceil();

    if (_currentPage > newTotalPages) {
      // もし現在のページが新しいページ数を超えていたら、1ページ目に戻す
      _currentPage = 1;
    }

    List<DocumentSnapshot> newCurrentResults = _searchResults
        .skip((_currentPage - 1) * _itemsPerPage)
        .take(_itemsPerPage)
        .toList()
        .cast<DocumentSnapshot>();
    setState(() {
      _currentPage = _currentPage; // currentPage を受け取り、更新する
      _totalPages = newTotalPages;
      _currentResults = newCurrentResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('納品指定内容確認'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
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
                            horizontal: 10,
                            vertical: 0,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _deliveryStartDate != null
                              ? DateFormat('yyyyMMdd')
                                  .format(_deliveryStartDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(' 〜 '),
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
                            horizontal: 10,
                            vertical: 0,
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
                const SizedBox(width: 20),
                const SizedBox(
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
                        horizontal: 10,
                        vertical: 0,
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
            const SizedBox(height: 16.0),
            Row(
              children: [
                const SizedBox(
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
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _deliveryStartTime = value;
                      });
                    },
                  ),
                ),
                const Text(' 〜 '),
                Expanded(
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
                        _deliveryEndTime = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                const SizedBox(
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
                        horizontal: 10,
                        vertical: 0,
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
            const SizedBox(height: 16.0),
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('取引先CD'),
                ),
                SizedBox(
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
                        _userCode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_deliveryStartDate != null &&
                        _deliveryEndDate != null) {
                      List<DocumentSnapshot> results =
                          await deliverySearchService.searchDeliveries(
                        deliveryStartDate: _deliveryStartDate.toString(),
                        deliveryEndDate: _deliveryEndDate.toString(),
                        branchCode: _branchCode,
                        deliveryStartTime: _deliveryStartTime,
                        deliveryEndTime: _deliveryEndTime,
                        userCode: _userCode,
                        deliveryPort: _deliveryPort,
                      );
                      // _searchResultsと_totalPagesを更新
                      setState(() {
                        _searchResults = results;
                        _currentPage = 1; // ページ数を1にリセット
                        _newUpdateResults(); // ここで_updateResultsを呼び出す
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("開始日と終了日は必須項目です")));
                    }
                  },
                  child: const Text('検索'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
              color: Colors.grey,
            ),
            _searchResults.isEmpty
                ? const Center(
                    child: Text('No results found.'),
                  )
                : DeliverySearchResultTable(
                    key: _searchResultTableKey,
                    searchResults: _searchResults as List<dynamic>,
                    onUpdateResults: _updateResults, // 新しいコールバックを追加
                  ),
          ],
        ),
      ),
    );
  }
}

class DeliverySearchResultTable extends StatefulWidget {
  final List<dynamic> searchResults; // 仮の検索結果データ
  final VoidCallback onUpdateResults; // 追加

  // コンストラクタ
  const DeliverySearchResultTable({
    super.key,
    required this.searchResults,
    required this.onUpdateResults, // 追加
  });

  @override
  _DeliverySearchResultTableState createState() =>
      _DeliverySearchResultTableState();
}

class _DeliverySearchResultTableState extends State<DeliverySearchResultTable> {
  late List<DocumentSnapshot> _currentResults;
  late int _currentPage;
  late int _totalPages;
  static const int _itemsPerPage = 100;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    // 総ページ数を計算し、少なくとも1になるようにする
    _totalPages = (widget.searchResults.length / _itemsPerPage).ceil();
    _totalPages = _totalPages < 1 ? 1 : _totalPages;
    // サブリストが範囲外にならないようにする
    int endIndex = _currentPage * _itemsPerPage;
    endIndex = endIndex > widget.searchResults.length
        ? widget.searchResults.length
        : endIndex;
    _currentResults =
        widget.searchResults.sublist(0, endIndex).cast<DocumentSnapshot>();
  }

  void onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _currentResults = widget.searchResults
          .skip((_currentPage - 1) * _itemsPerPage)
          .take(_itemsPerPage)
          .toList()
          .cast<DocumentSnapshot>();
    });

    // 新しいコールバックを呼び出す
    widget.onUpdateResults(); // currentPage を渡すように変更
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('日付'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('時間'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('センター'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('取引先CD'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('取引先名'),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text('納品口'),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                _currentResults.length,
                (index) {
                  if (index < _currentResults.length) {
                    Map<String, dynamic> deliveryData =
                        _currentResults[index].data() as Map<String, dynamic>;

                    DateTime dateTime = deliveryData['date'].toDate();
                    String formattedDate =
                        DateFormat('yyyyMMdd').format(dateTime);
                    String formattedTime = DateFormat('HH:mm').format(dateTime);

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(formattedDate),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(formattedTime),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(deliveryData['branchCode'].toString()),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(deliveryData['userCode'].toString()),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(deliveryData['userName'].toString()),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child:
                                Text(deliveryData['deliveryPort'].toString()),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const DataRow(
                        cells: []); // インデックスが範囲外の場合は空のDataRowを返す
                  }
                },
              ),
            ),
          ),
          WebPagination(
            currentPage: _currentPage,
            totalPage: _totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}
