import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../util/csv_reader.dart';

//ダイアログ用プロバイダー
final dialogStateProvider = StateProvider<AsyncValue<void>>(
  (_) => const AsyncValue.data(null),
);

final confirmDataProvider =
    StateNotifierProvider<ConfirmDataController, Future<CsvDataResult>>(
        (ref) => throw UnimplementedError());

final confirmDataProviderFamily = StateNotifierProvider.family<
    ConfirmDataController, Future<CsvDataResult>, String>((ref, csvData) {
  return ConfirmDataController(ref: ref, csvData: csvData);
});

class ConfirmDataController extends StateNotifier<Future<CsvDataResult>> {
  ConfirmDataController({required this.ref, required this.csvData})
      : super(CsvReader().getCsvDataResult(csvData) as Future<CsvDataResult>);
  final String csvData;
  final Ref ref;

  void readCSVData() {
    // CSVデータを読み込む処理
    final csvResult = CsvReader().getCsvDataResult(csvData);
    state = csvResult;
  }

  void testShowDialog() async {
    ref.read(dialogStateProvider.notifier).state = await AsyncValue.loading();
    Future.delayed(const Duration(seconds: 2), () async {
      ref.read(dialogStateProvider.notifier).state =
          await AsyncValue.guard(() async {
        // ここで実際にログイン処理を非同期で行う
      });
    });
  }

  //データをFirebaseに登録
  void registerData() {
    state.then((data) async {
      if (data.errorMessages.isNotEmpty) {
        return;
      }

      final mFirestore = FirebaseFirestore.instance;
      //ローディングさせる
      ref.read(dialogStateProvider.notifier).state =
          await const AsyncValue.loading();
      //for文でデータを登録
      for (int i = 0; i < data.csvData.length; i++) {
        final uuid = Uuid().v4();
        try {
          mFirestore.collection('reservation').doc(uuid).set({
            'branchCode': data.csvData[i].branchCode,
            'branchName': data.csvData[i].branchName,
            'date': data.csvData[i].date,
            'time': data.csvData[i].time,
            'userCode': data.csvData[i].userCode,
            'deliveryPort': data.csvData[i].deliveryPort,
            'userName': data.csvData[i].userName,
          }).onError(
              (error, stackTrace) => throw Exception([error, stackTrace]));
        } catch (e, s) {
          ref.read(dialogStateProvider.notifier).state =
              await AsyncValue.error(e, s);
          return;
        }
      }
      //全データ登録したことを通知
      ref.read(dialogStateProvider.notifier).state =
          await const AsyncValue.data(null);
    });
  }

  Future<void> sendFCMNotification() async {
    // FCMサーバーへのエンドポイントURL
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/berthapp-c3c59/messages:send');

    // HTTPリクエストヘッダー
    final headers = {
      'Authorization': 'AIzaSyC1J2lOjae45Dfm8NL1npSjEfgUhPC2Dfg',
      'Content-Type': 'application/json',
    };

    // 送信するメッセージデータ
    final messageData = {
      'message': {
        'token':
            'ch-4IyvLhEipv4KnTXqG43:APA91bGR7w9kg7TcmBq4pVXMHvxUznLRgATrh0Eqg2OET8ZWCUKzGOUqoxaoWx55G_vM27kOPjazpotE6PoVf8NGJGQx_i5lON4l3RGAFrWryK0zqQCFhEcGqlX-4ZkEMd07paHR6hNb',
        'notification': {
          'title': '入荷コントロール',
          'body': '新しい入荷予約が確定しました。',
        },
        'data': {
          'key1': 'value1',
          'key2': 'value2',
        },
      },
    };

    // HTTP POSTリクエストの送信
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(messageData),
    );

    // レスポンスの確認
    if (response.statusCode == 200) {
      print('FCM通知が正常に送信されました');
    } else {
      print('FCM通知の送信に失敗しました: ${response.statusCode}');
      print('レスポンスボディ: ${response.body}');
    }
  }
}
