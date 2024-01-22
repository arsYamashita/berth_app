import 'package:berth_app/ui/confirm_data_from_csv_page.dart';
import 'package:berth_app/util/size_config.dart';
import 'package:flutter/material.dart';

class ImportCSVPage extends StatelessWidget {
  const ImportCSVPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CSVをインポートしてください"),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _ImportCsvWidget(),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _RegistrationButton()
          ],
        ),
      ),
    );
  }
}

class _RegistrationButton extends StatelessWidget {
  const _RegistrationButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: SizeConfig.blockSizeVertical * 5,
        width: SizeConfig.blockSizeHorizontal * 10,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConfirmDataFromCsvPage()),
            );
          },
          child: Text("登録する"),
        ),
      ),
    );
  }
}

class _ImportCsvWidget extends StatelessWidget {
  const _ImportCsvWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 5,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              height: double.infinity,
              margin:
                  EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 2),
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("入荷指定データ.CSV"),
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text("ファイルを選択"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
