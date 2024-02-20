import 'package:cloud_firestore/cloud_firestore.dart';

class CsvReader {
  final CsvDataResult _csvDataResult = CsvDataResult();
  List<CompanyUser> _fetchedUserIds = [];
  List<Branch> _fetchedBranch = [];
  List<Reservation> _fetchReservation = [];

  Future<void> _fetchFirestoreData() async {
    const undefinedString = 'undefined';
    final mFirestore = FirebaseFirestore.instance;

    // user情報を追加
    final userSnapshot = await mFirestore.collection('users').get();
    userSnapshot.docs.forEach((doc) {
      final userCode = doc.id;
      final userName = doc.data()?['name'] ?? undefinedString;

      final companyUser = CompanyUser(
        userCode: userCode,
        userName: userName,
      );
      _fetchedUserIds.add(companyUser);
    });

    // 拠点情報を追加
    final branchSnapshot = await mFirestore.collection('branch').get();
    branchSnapshot.docs.forEach((doc) {
      final branchCode = doc.id;
      final branchName = doc.data()?['branchName'] ?? undefinedString;
      final deliveryPorts =
          List<String>.from(doc.data()?['deliveryPorts'] ?? []);

      final branch = Branch(
        branchCode: branchCode,
        branchName: branchName,
        deliveryPorts: deliveryPorts,
      );
      _fetchedBranch.add(branch);
    });
    //予約情報を追加
    final reservationSnapshot =
        await mFirestore.collection('reservation').get();
    reservationSnapshot.docs.forEach((doc) {
      final date = doc.data()?['date'] ?? undefinedString;
      final time = doc.data()?['time'] ?? undefinedString;
      final branchCode = doc.data()?['branchCode'] ?? undefinedString;
      final deliveryPort = doc.data()?['deliveryPort'] ?? undefinedString;

      final reservation = Reservation(
        date: date,
        time: time,
        branchCode: branchCode,
        deliveryPort: deliveryPort,
      );
      _fetchReservation.add(reservation);
    });
  }

  Future<CsvDataResult> getCsvDataResult(String csvText) async {
    //Firestoreからデータを取得
    await _fetchFirestoreData();

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
      //改行コードを削除
      List<String> csvRowItems = lines[i].replaceAll('\r', '').split(',');
      //項目ごとのバリデーション
      if (await _csvValidation(i + 1, csvRowItems)) {
        return _csvDataResult;
      }
      //データの重複がないか確認
      if (_isDuplicateData(i + 1, csvRowItems)) {
        return _csvDataResult;
      }

      //userCodeからuserNameを取得
      final userName = _fetchedUserIds
          .where((user) => user.userCode == csvRowItems[3])
          .first
          .userName;
      //branchCodeからbranchNameを取得
      final branchName = _fetchedBranch
          .where((branch) => branch.branchCode == csvRowItems[0])
          .first
          .branchName;

      final csvData = CsvData(
        branchCode: csvRowItems[0],
        branchName: branchName,
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

  //CSVファイルにデータの重複がないか確認
  bool _isDuplicateData(int count, List<String> csvRowItems) {
    final branchCode = csvRowItems[0];
    final date = csvRowItems[1];
    final time = csvRowItems[2];
    final deliveryPort = csvRowItems[4];

    //CSVファイルにデータの重複がないか確認
    final isDuplicateInCsv = _csvDataResult.csvData
        .where((csvData) =>
            csvData.branchCode == branchCode &&
            csvData.date == date &&
            csvData.time == time &&
            csvData.deliveryPort == deliveryPort)
        .isNotEmpty;
    if (isDuplicateInCsv) {
      _csvDataResult.setErrorMessage('$count行目:CSVファイルに'
          '重複データがあります。');
      return true;
    }
    //Firestoreにデータの重複がないか確認
    final isDuplicateInFirestore = _fetchReservation
        .where((reservation) =>
            reservation.branchCode == branchCode &&
            reservation.date == date &&
            reservation.time == time &&
            reservation.deliveryPort == deliveryPort)
        .isNotEmpty;
    if (isDuplicateInFirestore) {
      _csvDataResult.setErrorMessage('$count行目:Firestoreに'
          '重複データがあります。');
      return true;
    }
    return isDuplicateInCsv || isDuplicateInFirestore;
  }

  //項目ごとのバリデーション
  Future<bool> _csvValidation(int count, List<String> csvRowItems) async {
    final errorMessage = StringBuffer();

    final branchCode = csvRowItems[0];
    final userCode = csvRowItems[3];
    final deliveryPort = csvRowItems[4];

    final existsUserCode =
        _fetchedUserIds.where((user) => user.userCode == userCode).isNotEmpty;
    final existsBranchCode = _fetchedBranch
        .where((branch) => branch.branchCode == branchCode)
        .isNotEmpty;
    final existsDeliveryPort = _fetchedBranch
        .where((branch) =>
            branch.branchCode == branchCode &&
            branch.deliveryPorts.contains(deliveryPort))
        .isNotEmpty;

    if (csvRowItems.length != 5) {
      errorMessage.write('$count行目：項目数が不正です。');
      _csvDataResult.setErrorMessage(errorMessage.toString());
      return true;
    }

    if (branchCode.length != 4 || int.tryParse(branchCode) == null) {
      errorMessage.write('拠点CDが不正です。');
    } else if (!existsBranchCode) {
      errorMessage.write('拠点CDが存在しません。');
    } else if (!_isValidDate(csvRowItems[1])) {
      errorMessage.write('日付が不正です。');
    } else if (!_isValidTime(csvRowItems[2])) {
      errorMessage.write('時間が不正です。');
    } else if (userCode.length != 9 || int.tryParse(userCode) == null) {
      errorMessage.write('取引先CDが不正です。');
    } else if (!existsUserCode) {
      errorMessage.write('取引先CDが存在しません。');
    } else if (!existsDeliveryPort) {
      errorMessage.write('納品口が存在しません。');
    }
    if (errorMessage.isNotEmpty) {
      _csvDataResult.setErrorMessage('$count行目: ${errorMessage.toString()}');
      return true;
    }

    return false;
  }

  bool _isValidDate(String dateString) {
    // 文字列の長さが8でない場合は無効
    if (dateString.length != 8) {
      return false;
    }

    // 全ての文字が数字であることを確認
    if (!RegExp(r'^[0-9]+$').hasMatch(dateString)) {
      return false;
    }

    // 年、月、日に分割
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));

    // 年が1年以上9999年以下であることを確認
    if (year < 1 || year > 9999) {
      return false;
    }

    // 月が1以上12以下であることを確認
    if (month < 1 || month > 12) {
      return false;
    }

    // 日数の制限を取得
    int maxDaysInMonth = _getMaxDaysInMonth(year, month);

    // 日が1以上月の最大日数以下であることを確認
    if (day < 1 || day > maxDaysInMonth) {
      return false;
    }

    return true;
  }

// 月ごとの最大日数を返すメソッド
  int _getMaxDaysInMonth(int year, int month) {
    switch (month) {
      case 2:
        // 2月は閏年かどうかで日数が異なる
        return _isLeapYear(year) ? 29 : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        // 4月、6月、9月、11月は30日まで
        return 30;
      default:
        // 他の月は31日まで
        return 31;
    }
  }

// 閏年かどうかを判定するメソッド
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  bool _isValidTime(String timeString) {
    // コロンで時刻を分割
    List<String> parts = timeString.split(':');
    if (parts.length != 2) {
      return false;
    }

    // 時、分が全て数字であることを確認
    if (!RegExp(r'^[0-9]+$').hasMatch(parts[0]) ||
        !RegExp(r'^[0-9]+$').hasMatch(parts[1])) {
      print('数字でない');
      return false;
    }

    // 時間が0以上23以下であることを確認
    int hour = int.parse(parts[0]);
    if (hour < 0 || hour > 23) {
      print('時間が不正');
      return false;
    }

    // 分が0以上59以下であることを確認
    int minute = int.parse(parts[1]);
    if (minute < 0 || minute > 59) {
      print('分が不正');
      return false;
    }

    return true;
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
  final String branchName;
  final String date;
  final String time;
  final String userCode;
  final String userName;
  final String deliveryPort;

  CsvData({
    required this.branchCode,
    required this.branchName,
    required this.date,
    required this.time,
    required this.userCode,
    required this.userName,
    required this.deliveryPort,
  });
}

class Branch {
  final String branchCode;
  final String branchName;
  final List<String> deliveryPorts;

  Branch({
    required this.branchCode,
    required this.deliveryPorts,
    required this.branchName,
  });
}

class Reservation {
  Reservation({
    required this.date,
    required this.time,
    required this.branchCode,
    required this.deliveryPort,
  });
  String date;
  String time;
  String branchCode;
  String deliveryPort;
}

class CompanyUser {
  final String userCode;
  final String userName;

  CompanyUser({
    required this.userCode,
    required this.userName,
  });
}
