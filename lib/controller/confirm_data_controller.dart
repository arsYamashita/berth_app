import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../util/csv_reader.dart';

final confirmDataProvider = StateNotifierProvider.autoDispose<
    ConfirmDataController,
    Future<CsvDataResult>>((ref) => throw UnimplementedError());

final confirmDataProviderFamily = StateNotifierProvider.autoDispose
    .family<ConfirmDataController, Future<CsvDataResult>, String>(
        (ref, csvData) {
  return ConfirmDataController(csvData: csvData);
});

class ConfirmDataController extends StateNotifier<Future<CsvDataResult>> {
  ConfirmDataController({required this.csvData})
      : super(CsvReader().getCsvDataResult(csvData) as Future<CsvDataResult>);
  final String csvData;

  void readCSVData() {
    // CSVデータを読み込む処理
    final csvResult = CsvReader().getCsvDataResult(csvData);
    state = csvResult;
  }

  void inputCsvData(String csvData) {}
}
