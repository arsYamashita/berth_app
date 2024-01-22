import 'package:flutter/material.dart';

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
        child: Column(
          children: [
            InputedDataList(
              datas: Dummy.reservationList,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 10),
            Text("上記${Dummy.reservationList.length}件のデータを登録します"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ConfirmButton(
                  title: "キャンセル",
                  onPressed: () {},
                ),
                _ConfirmButton(
                  title: "登録する",
                  isRegistration: true,
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
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
  final List<Reservation> datas;

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
                        buildCellData(datas[index].date),
                        buildCellData(datas[index].time),
                        buildCellData(datas[index].clientCD.toString()),
                        buildCellData(datas[index].clientName),
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
    final List<String> headerLabels = ["日付", "時間", "取引先CD", "取引先名", "納品口"];
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
