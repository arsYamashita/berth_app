import 'dart:convert';

import 'package:berth_app/ui/confirm_data_from_csv_page.dart';
import 'package:berth_app/util/csv_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
part 'import_csv_controller.freezed.dart';

@freezed
class ImportCsvState with _$ImportCsvState {
  const factory ImportCsvState({
    @Default("") String fileName,
  }) = _ImportCsvState;
}

final importCsvProvider =
    StateNotifierProvider.autoDispose<ImportCsvController, ImportCsvState>(
        (ref) => ImportCsvController());

class ImportCsvController extends StateNotifier<ImportCsvState> {
  ImportCsvController() : super(const ImportCsvState());

  FilePickerResult? csvData;

  void pickFile(BuildContext context) async {
    // CSVをインポートする処理
    FilePickerResult? picResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (picResult == null) {
      return;
    }
    csvData = picResult;
    _inputFileName(picResult.files.single.name);
  }

  void readCsvData() {
    // CSVデータを読み込む処理
    if (this.csvData == null) {
      return;
    }
    final _csvBytes = this.csvData!.files.single.bytes;
    final _csvText = utf8.decode(_csvBytes!);

    final csvResult = CsvReader().getCsvDataResult(_csvText);
    print('CSV: ${csvResult.csvData}, error: ${csvResult.errorMessages}');
  }

  void _inputFileName(String fileName) {
    state = state.copyWith(fileName: fileName);
  }
}
