class CsvReader {
  final CsvDataResult _csvData = CsvDataResult();
  CsvDataResult getCsvDataResult(String csvText) {
    //改行ごとに行を格納する
    List<String> lines = csvText.split('\n');
    //空行を削除
    lines.removeWhere((line) => line.trim().isEmpty);
    //csvファイルが空の場合
    if (lines.isEmpty) {
      _csvData.addErrorMessage('CSVファイルが空です');
      return _csvData;
    }
    for (int i = 0; i < lines.length; i++) {
      final csvRowItems = lines[i].split(',');
      //項目ごとのバリデーション
      _csvValidation(i + 1, csvRowItems);
      _csvData.addCsvData(csvRowItems);
    }
    return _csvData;
  }

  //項目ごとのバリデーション
  void _csvValidation(int count, List<String> csvRowitems) {
    String errorMessage = '';

    if (csvRowitems.length != 5) {
      errorMessage += 'CSVのフォーマットが不正です';
      _csvData.addErrorMessage(errorMessage);
      return;
    }
    //拠点CDが四桁の数字でない場合
    if (csvRowitems[0].length != 4 || int.tryParse(csvRowitems[0]) == null) {
      errorMessage += '拠点CDが不正です。\n';
    }
    //日付がYYYY/MM/DD形式でない場合
    if (!RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(csvRowitems[1])) {
      errorMessage += '日付が不正です。\n';
    }
    //時間がHH:MM形式でない場合
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(csvRowitems[2])) {
      errorMessage += '時間が不正です。\n';
    }
    //取引先CDが6桁の数字でない場合
    if (csvRowitems[3].length != 6 || int.tryParse(csvRowitems[3]) == null) {
      errorMessage += '取引先CDが不正です。\n';
    }
    //納品口の情報
    //errorMessageが空でない場合、エラーメッセージを追加
    if (errorMessage.isNotEmpty) {
      _csvData.addErrorMessage('${count}行目：\n${errorMessage}');
    }
  }
}

//エラー内容とCSVデータの各行を保持するクラス
class CsvDataResult {
  final List<List<String>> _csvData = [];
  final List<String> _errorMessages = [];
  void addCsvData(List<String> csvData) {
    _csvData.add(csvData);
  }

  void addErrorMessage(String errorMessage) {
    _errorMessages.add(errorMessage);
  }

  get csvData => _csvData;
  get errorMessages => _errorMessages;
}
