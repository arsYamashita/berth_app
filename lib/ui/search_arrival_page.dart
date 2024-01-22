/* 時間制定確認画面 */

import 'package:berth_app/constant/dummy.dart';
import 'package:berth_app/ui/confirm_data_from_csv_page.dart';
import 'package:berth_app/util/size_config.dart';
import 'package:flutter/material.dart';

class SearchArrivalPage extends StatelessWidget {
  const SearchArrivalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 20,
          vertical: SizeConfig.blockSizeVertical * 5,
        ),
        child: Column(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 30,
              padding:
                  EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 3),
              child: Row(
                children: [
                  _FilterTextFields(),
                  Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 10,
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 5),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 0),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {},
                            child: Text("表示する"),
                          ),
                        ),
                      ))
                ],
              ),
            ),
            InputedDataList(
              datas: Dummy.reservationList,
            )
          ],
        ),
      ),
    );
  }
}

class _FilterTextFields extends StatelessWidget {
  const _FilterTextFields({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          _buildTextField(title: "日付"),
          _buildTextField(title: "時間"),
          _buildTextField(title: "納品口"),
          _buildTextField(title: "取引先CD"),
        ],
      ),
    );
  }

  Widget _buildTextField({required title}) {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(title),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
