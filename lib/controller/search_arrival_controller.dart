import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../model/delivery_search_service.dart';
import '../ui/search_arrival_page.dart';

final deliverySearchProvider =
    ChangeNotifierProvider.autoDispose((ref) => DeliverySearchViewModel());

class DeliverySearchViewModel extends ChangeNotifier {
  final DeliverySearchService _service = DeliverySearchService();

  GlobalKey<DeliverySearchResultTableState> searchResultTableKey = GlobalKey();

  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;
  String? _branchCode;
  String? _deliveryStartTime;
  String? _deliveryEndTime;
  String? _userCode;
  String? _deliveryPort;

  late List<DocumentSnapshot> _currentResults;
  late int _currentPage;
  late int _totalPages;
  bool isInitialState = true;
  static const int _itemsPerPage = 100;
  List<DocumentSnapshot> searchResult = [];

  List<DocumentSnapshot> get searchResults => searchResult;

  void pickDeliveryDate(BuildContext context, {bool isStart = true}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      isStart ? setDeliveryStartDate(date) : setDeliveryEndDate(date);
    }
  }

  String getDeliveryDateString({bool isStart = true}) {
    if (isStart) {
      return _deliveryStartDate != null
          ? DateFormat('yyyy/MM/dd').format(_deliveryStartDate!)
          : '';
    } else {
      return _deliveryEndDate != null
          ? DateFormat('yyyy/MM/dd').format(_deliveryEndDate!)
          : '';
    }
  }

  void searchReservation(BuildContext context) async {
    // 開始日と終了日が入力されている場合のみ検索を実行
    if (_deliveryStartDate != null && _deliveryEndDate != null) {
      // 検索結果を取得
      List<DocumentSnapshot> results = await _service.searchDeliveries(
        deliveryStartDate: _deliveryStartDate.toString(),
        deliveryEndDate: _deliveryEndDate.toString(),
        branchCode: _branchCode,
        deliveryStartTime: _deliveryStartTime,
        deliveryEndTime: _deliveryEndTime,
        userCode: _userCode,
        deliveryPort: _deliveryPort,
      );
      // _searchResultsと_totalPagesを更新
      isInitialState = false;
      searchResult = results;
      _currentPage = 1; // ページ数を1にリセット
      newUpdateResults(); // ここで_updateResultsを呼び出す
      print(_branchCode);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("開始日と終了日は必須項目です")));
    }
    notifyListeners();
  }

  void newUpdateResults() {
    int newTotalPages = (searchResults.length / _itemsPerPage).ceil();

    if (_currentPage > newTotalPages) {
      _currentPage = 1;
    }

    // 新しいキーを作成
    final newKey = GlobalKey<DeliverySearchResultTableState>();

    // _searchResultTableKey.currentState?.dispose(); // 古いキーの状態を解放
    searchResultTableKey = newKey; // 新しいキーに更新
    _currentPage = _currentPage;
    _totalPages = newTotalPages;
    _currentResults = searchResults
        .skip((_currentPage - 1) * _itemsPerPage)
        .take(_itemsPerPage)
        .toList()
        .cast<DocumentSnapshot>();
    notifyListeners();
  }

  void updateResults() {
    int newTotalPages = (searchResults.length / _itemsPerPage).ceil();

    if (_currentPage > newTotalPages) {
      // もし現在のページが新しいページ数を超えていたら、1ページ目に戻す
      _currentPage = 1;
      notifyListeners();
    }

    List<DocumentSnapshot> newCurrentResults = searchResults
        .skip((_currentPage - 1) * _itemsPerPage)
        .take(_itemsPerPage)
        .toList()
        .cast<DocumentSnapshot>();
    _currentPage = _currentPage; // currentPage を受け取り、更新する
    _totalPages = newTotalPages;
    _currentResults = newCurrentResults;
    notifyListeners();
  }

  void setDeliveryStartDate(DateTime date) {
    _deliveryStartDate = date;
    notifyListeners();
  }

  void setDeliveryEndDate(DateTime date) {
    _deliveryEndDate = date;
    notifyListeners();
  }

  void setBranchCode(String code) {
    _branchCode = code;
    notifyListeners();
  }

  void setDeliveryStartTime(String time) {
    _deliveryStartTime = time;
    notifyListeners();
  }

  void setDeliveryEndTime(String time) {
    _deliveryEndTime = time;
    notifyListeners();
  }

  void setUserCode(String code) {
    _userCode = code;
    notifyListeners();
  }

  void setDeliveryPort(String port) {
    _deliveryPort = port;
    notifyListeners();
  }
}
