import 'package:berth_app/controller/confirm_data_controller.dart';
import 'package:berth_app/util/csv_reader.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../constant/dummy.dart';
import '../model/reservation.dart';
import '../util/size_config.dart';

class ConfirmDataFromCsvPage extends StatelessWidget {
  ConfirmDataFromCsvPage({super.key});
  final labels = List<DataColumn>.generate(
      5, (int index) => DataColumn(label: Text("ラベル$index")),
      growable: false);

  final values = List<DataRow>.generate(20, (int index) {
    return DataRow(cells: [
      DataCell(Text("山田$index郎")),
      const DataCell(Text("男性")),
      const DataCell(Text("2000/10/30")),
      const DataCell(Text("東京都港区")),
      const DataCell(Text("会社員")),
    ]);
  }, growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 20,
          vertical: SizeConfig.blockSizeVertical * 10,
        ),
        child: Consumer(builder: (context, ref, _) {
          final notifier = ref.read(confirmDataProvider.notifier);
          final state = ref.read(confirmDataProvider);
          return FutureBuilder(
              future: state,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<CsvData> csvData = snapshot.data!.csvData;

                  if (snapshot.data!.errorMessages.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("エラーが発生しました"),
                          SizedBox(height: SizeConfig.blockSizeVertical * 2),
                          Text("エラー内容：${snapshot.data!.errorMessages}"),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      InputedDataList(
                        datas: csvData,
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 10),
                      Text("上記${csvData.length}件のデータを登録します"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ConfirmButton(
                            title: "キャンセル",
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          _ConfirmButton(
                            title: "登録する",
                            isRegistration: true,
                            onPressed: () {
                              // notifier.registerData();
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return _RegistrationDialog();
                                  });
                              notifier.registerData();
                            },
                          ),
                        ],
                      )
                    ],
                  );
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
              });
        }),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isRegistration = false,
  });
  final String title;
  final bool isRegistration;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 5,
      width: SizeConfig.blockSizeHorizontal * 10,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 1,
        vertical: SizeConfig.blockSizeVertical * 3,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistration ? Colors.orange : Colors.grey,
        ),
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

class InputedDataList extends StatelessWidget {
  const InputedDataList({
    super.key,
    required this.datas,
  });
  final List<CsvData> datas;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _listHeader(),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: datas.length,
                itemBuilder: (contex, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockSizeVertical * 1),
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    )),
                    child: Row(
                      children: [
                        buildCellData(
                            DateFormat("yyyyMMdd").format(datas[index].date)),
                        buildCellData(
                            DateFormat("HHmm").format(datas[index].date)),
                        buildCellData(datas[index].userCode),
                        buildCellData(datas[index].userName),
                        buildCellData(datas[index].branchCode),
                        buildCellData(datas[index].deliveryPort),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _listHeader() {
    final List<String> headerLabels = [
      "日付",
      "時間",
      "取引先CD",
      "取引先名",
      "拠点名",
      "納品口"
    ];
    final List<Widget> headerList = List.generate(
        headerLabels.length,
        (index) => Expanded(
                child: Center(
              child: Text(headerLabels[index],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )));

    return Container(
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 2.0, color: Colors.black))),
        child: ListTile(title: Row(children: headerList)));
  }

  Expanded buildCellData(String title) {
    return Expanded(child: Center(child: Text(title)));
  }
}

class _RegistrationDialog extends ConsumerWidget {
  const _RegistrationDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final dialogState = ref.watch(dialogStateProvider);

    return AlertDialog(
      title: Text(dialogState.isLoading ? "登録中" : "登録完了"),
      content: ref.watch(dialogStateProvider).when(
        data: (value) {
          return const Text("登録されました。");
        },
        loading: () {
          return const SizedBox(width: 100, child: LinearProgressIndicator());
        },
        error: (error, stack) {
          return Text("エラーが発生しました: ${error.toString()}");
        },
      ),
      actions: [
        dialogState.isLoading
            ? SizedBox()
            : ElevatedButton(
                onPressed: () {
                  // ダイアログを閉じて前の画面に戻る
                  Navigator.pop(context);
                  // ダイアログが閉じられた後に前の画面に戻る
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
      ],
    );
  }
}
