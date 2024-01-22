import 'package:berth_app/constant/dummy.dart';
import 'package:berth_app/ui/select_task_page.dart';
import 'package:flutter/material.dart';

import '../util/size_config.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 10,
            vertical: SizeConfig.blockSizeVertical * 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LoginForm(
              title: "メールアドレス",
              hint: Dummy.mailHint,
            ),
            _LoginForm(
              title: "パスワード",
              hint: Dummy.passHint,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectTaskPage()),
                );
              },
              child: Text("ログイン"),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  _LoginForm({super.key, required this.title, required this.hint});
  final String title;
  final String hint;
  final TextStyle essentialTextStyle = TextStyle(color: Colors.red);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: title),
            TextSpan(text: "　(必須)", style: essentialTextStyle)
          ])),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
          ),
        ],
      ),
    );
  }
}
