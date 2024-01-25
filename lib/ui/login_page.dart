import 'package:berth_app/constant/dummy.dart';
import 'package:berth_app/controller/login_controller.dart';
import 'package:berth_app/ui/select_task_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/size_config.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: HookConsumer(builder: (context, ref, _) {
        final notifier = ref.read(loginProvider.notifier);
        final _formkey = GlobalKey<FormState>();
        ref.watch(loginProvider.notifier);

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 10,
              vertical: SizeConfig.blockSizeVertical * 10),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoginForm(
                  onChanged: (value) {
                    notifier.inputEmail(value);
                  },
                  title: "メールアドレス",
                  hint: Dummy.mailHint,
                ),
                _LoginForm(
                  onChanged: (value) {
                    notifier.inputPassword(value);
                  },
                  title: "パスワード",
                  hint: Dummy.passHint,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      await notifier.signIn().then((value) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(value)));
                        //authの結果によって画面遷移
                        if (value == "ログインしました") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SelectTaskPage()));
                        }
                      });
                    }
                  },
                  child: Text("ログイン"),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LoginForm extends StatelessWidget {
  _LoginForm(
      {super.key,
      required this.title,
      required this.hint,
      required this.onChanged});
  final ValueChanged<String> onChanged;
  final String title;
  final String hint;
  final TextStyle essentialTextStyle = const TextStyle(color: Colors.red);
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
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return "入力欄が空です。";
              }
            },
            onChanged: onChanged,
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
