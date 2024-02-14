import 'package:cloud_firestore/cloud_firestore.dart';

class CsvReader {
  final CsvDataResult _csvDataResult = CsvDataResult();

  Future<CsvDataResult> getCsvDataResult(String csvText) async {
    //改行ごとに行を格納する
    List<String> lines = csvText.split('\n');
    //空行を削除
    lines.removeWhere((line) => line.trim().isEmpty);
    //csvファイルが空の場合
    if (lines.isEmpty) {
      _csvDataResult.setErrorMessage('CSVファイルが空です');
      return _csvDataResult;
    }
    for (int i = 0; i < lines.length; i++) {
      List<String> csvRowItems = lines[i].split(',');
      //項目ごとのバリデーション
      if (await _csvValidation(i + 1, csvRowItems)) {
        return _csvDataResult;
      }
      //userCodeからuserNameを取得
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(csvRowItems[3])
          .get();
      final userName = userDocSnapshot['name'];

      final csvData = CsvData(
        branchCode: csvRowItems[0],
        date: csvRowItems[1],
        time: csvRowItems[2],
        userCode: csvRowItems[3],
        deliveryPort: csvRowItems[4],
        userName: userName,
      );

      _csvDataResult.addCsvData(csvData);
    }
    return _csvDataResult;
  }

  //項目ごとのバリデーション
  Future<bool> _csvValidation(int count, List<String> csvRowItems) async {
    final errorMessage = StringBuffer();

    final branchCode = csvRowItems[0];
    final userCode = csvRowItems[3];

    final branchDocSnapshot = await FirebaseFirestore.instance
        .collection('branch')
        .doc(branchCode)
        .get();
    final userDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCode)
        .get();

    if (csvRowItems.length != 5) {
      errorMessage.write('$count行目：項目数が不正です。');
      _csvDataResult.setErrorMessage(errorMessage.toString());
      return true;
    }

    if (branchCode.length != 4 || int.tryParse(branchCode) == null) {
      errorMessage.write('拠点CDが不正です。');
    } else if (!branchDocSnapshot.exists) {
      errorMessage.write('拠点CDが存在しません。');
    } else if (!RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(csvRowItems[1])) {
      errorMessage.write('日付が不正です。');
    } else if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(csvRowItems[2])) {
      errorMessage.write('時間が不正です。');
    } else if (userCode.length != 9 || int.tryParse(userCode) == null) {
      errorMessage.write('取引先CDが不正です。');
    } else if (!userDocSnapshot.exists) {
      errorMessage.write('取引先CDが存在しません。');
    }
    if (errorMessage.isNotEmpty) {
      _csvDataResult.setErrorMessage('$count行目: ${errorMessage.toString()}');
      return true;
    }

    return false;
  }
}

//エラー内容とCSVデータの各行を保持するクラス
class CsvDataResult {
  final List<CsvData> _csvData = [];
  String _errorMessages = "";
  void addCsvData(CsvData csvData) {
    _csvData.add(csvData);
  }

  void setErrorMessage(String errorMessage) {
    _errorMessages = errorMessage;
  }

  get csvData => _csvData;
  get errorMessages => _errorMessages;
}

//csv格納用のクラス
class CsvData {
  final String branchCode;
  final String date;
  final String time;
  final String userCode;
  final String userName;
  final String deliveryPort;

  CsvData({
    required this.branchCode,
    required this.date,
    required this.time,
    required this.userCode,
    required this.userName,
    required this.deliveryPort,
  });
}
