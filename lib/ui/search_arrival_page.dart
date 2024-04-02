import 'package:berth_app/controller/search_arrival_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_web_pagination/flutter_web_pagination.dart';

class SearchArrivalPage extends HookConsumerWidget {
  const SearchArrivalPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final viewModel = ref.read(deliverySearchProvider);
    final state = ref.watch(deliverySearchProvider);

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
                DeliveryDateForm(
                  onTap: () =>
                      viewModel.pickDeliveryDate(context, isStart: true),
                  deliveryDateText: viewModel.getDeliveryDateString(),
                ),
                const Text(' 〜 '),
                DeliveryDateForm(
                  onTap: () =>
                      viewModel.pickDeliveryDate(context, isStart: false),
                  deliveryDateText:
                      viewModel.getDeliveryDateString(isStart: false),
                ),
                const SizedBox(width: 20),
                const SizedBox(
                  width: 80,
                  child: Text('センター'),
                ),
                FilterInputForm(
                    onChanged: (value) => viewModel.setBranchCode(value)),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('配送日時'),
                ),
                FilterInputForm(
                  onChanged: (value) => viewModel.setDeliveryStartTime(value),
                ),
                const Text(' 〜 '),
                FilterInputForm(
                    onChanged: (value) => viewModel.setDeliveryEndTime(value)),
                const SizedBox(width: 20),
                const SizedBox(
                  width: 80,
                  child: Text('納品口'),
                ),
                FilterInputForm(
                    onChanged: (value) => viewModel.setDeliveryPort(value)),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('取引先CD'),
                ),
                FilterInputForm(
                    isUserCdForm: true,
                    onChanged: (value) => viewModel.setUserCode(value)),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => viewModel.searchReservation(context),
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
            state.searchResults.isEmpty
                ? Center(
                    child: Text(state.isInitialState ? '' : 'No results found'),
                  )
                : DeliverySearchResultTable(
                    key: viewModel.searchResultTableKey,
                    searchResults: state.searchResult as List<dynamic>,
                    onUpdateResults: () =>
                        viewModel.updateResults(), // 新しいコールバックを追加
                  ),
          ],
        ),
      ),
    );
  }
}

class FilterInputForm extends StatelessWidget {
  const FilterInputForm({
    super.key,
    required this.onChanged,
    this.isUserCdForm = false,
  });
  final ValueChanged<String> onChanged;
  final bool isUserCdForm;

  @override
  Widget build(BuildContext context) {
    final child = TextField(
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
      onChanged: (value) => onChanged,
    );

    return isUserCdForm
        ? SizedBox(
            width: 150,
            child: child,
          )
        : Expanded(
            child: child,
          );
  }
}

class DeliveryDateForm extends StatelessWidget {
  const DeliveryDateForm({
    super.key,
    required this.onTap,
    required this.deliveryDateText,
  });

  final VoidCallback onTap;
  final String deliveryDateText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
            controller: TextEditingController(text: deliveryDateText),
          ),
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
  DeliverySearchResultTableState createState() =>
      DeliverySearchResultTableState();
}

class DeliverySearchResultTableState extends State<DeliverySearchResultTable> {
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
