import 'package:berth_app/ui/search_arrival_page.dart';
import 'package:berth_app/util/size_config.dart';
import 'package:flutter/material.dart';

import 'import_csv_page.dart';

class SelectTaskPage extends StatelessWidget {
  const SelectTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Container(
        width: SizeConfig.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical * 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TaskButton(
              title: "時間指定画面（CSV一括）",
              isInputCsv: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImportCSVPage()),
                );
              },
            ),
            _TaskButton(
              title: "時間指定確認画面",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchArrivalPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskButton extends StatelessWidget {
  const _TaskButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isInputCsv = false,
  });
  final String title;
  final VoidCallback onPressed;
  final bool isInputCsv;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.blockSizeHorizontal * 3),
      child: SizedBox(
        height: SizeConfig.blockSizeVertical * 10,
        width: SizeConfig.blockSizeHorizontal * 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: isInputCsv ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white),
          onPressed: onPressed,
          child: Text(title),
        ),
      ),
    );
  }
}
