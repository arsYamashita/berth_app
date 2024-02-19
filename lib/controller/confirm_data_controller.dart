import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../util/csv_reader.dart';

final confirmDataProvider =
    StateNotifierProvider<ConfirmDataController, Future<CsvDataResult>>(
        (ref) => throw UnimplementedError());

final confirmDataProviderFamily = StateNotifierProvider.family<
    ConfirmDataController, Future<CsvDataResult>, String>((ref, csvData) {
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

  //データをFirebaseに登録
  void registerData() {
    state.then((data) {
      if (data.errorMessages.isNotEmpty) {
        return;
      }

      final mFirestore = FirebaseFirestore.instance;
      //for文でデータを登録
      for (int i = 0; i < data.csvData.length; i++) {
        final uuid = Uuid().v4();
        mFirestore.collection('reservation').doc(uuid).set({
          'branchCode': data.csvData[i].branchCode,
          'date': data.csvData[i].date,
          'time': data.csvData[i].time,
          'userCode': data.csvData[i].userCode,
          'deliveryPort': data.csvData[i].deliveryPort,
          'userName': data.csvData[i].userName,
        });
      }
    });
  }

  void inputCsvData(String csvData) {}
}
