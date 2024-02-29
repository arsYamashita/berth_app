import 'dart:convert';
import 'package:berth_app/model/ReservationNotification.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../util/csv_reader.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

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
      List<ReservationNotification> notifications = [];
      //for文でデータを登録
      for (int i = 0; i < data.csvData.length; i++) {
        final uuid = Uuid().v4();
        try {
          //予約通知用のデータを作成
          notifications
              .where(
                  (element) => element.userCode == data.csvData[i].userCode)
              .isEmpty
              ? notifications.add(
              ReservationNotification(userCode: data.csvData[i].userCode))
              : null;
          //予約IDを格納
          notifications
              .firstWhere(
                  (element) => element.userCode == data.csvData[i].userCode)
              .addReservationID(uuid);

          //予約データを登録
          await mFirestore.collection('reservation').doc(uuid).set({
            'branchCode': data.csvData[i].branchCode,
            'branchName': data.csvData[i].branchName,
            'date': data.csvData[i].date,
            'userCode': data.csvData[i].userCode,
            'deliveryPort': data.csvData[i].deliveryPort,
            'userName': data.csvData[i].userName,
          }).onError(
                  (error, stackTrace) => throw Exception([error, stackTrace]));
        } catch (e, s) {
          ref
              .read(dialogStateProvider.notifier)
              .state =
          await AsyncValue.error(e, s);
          return;
        }
      }

      //全データ登録したことを通知
      print('全データ登録したことを通知');
      ref
          .read(dialogStateProvider.notifier)
          .state =
      await const AsyncValue.data(null);
      //各ユーザーのfcmトークンをセット
      await fetchFcmToken(notifications);
      print('notifications:$notifications');
      //通知を送信
      await sendFCMNotificationV1(notifications);
    });
  }

  //登録したユーザーコードから端末のfcmトークンを取得する
  Future<void> fetchFcmToken(
      List<ReservationNotification> notifications) async {
    final mFirestore = FirebaseFirestore.instance;
    for (var element in notifications) {
      final userCode = element.userCode;
      final userSnapshot =
      await mFirestore.collection('users').doc(userCode).get();
      //ユーザーコードに紐づくfcmトークンを取得（配列型）
      final fcmToken = (userSnapshot['fcmToken'] as List<dynamic>)
          .map((token) => token.toString())
          .toList();
      element.addFcmToken(fcmToken);
    }
  }

  Future<void> sendFCMNotification(
      List<ReservationNotification> notifications) async {
    // FCMサーバーへのエンドポイントURL
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // HTTPリクエストヘッダー
    final headers = {
      'Authorization':
      'key=AAAAQQt6HGM:APA91bHVEwYFOZTf4bLxa3wLMptpGL9G5TcPH3l-8CvRRKDPRWvrqhsxBhyWIoOdg0fmjSMGdO_rB7cFB8PZfqwkm_FQdfPDrKcuwioSW6VCiduZlB3HDY6V9FyAoHCqlntlqxDaidTv',
      'Content-Type': 'application/json',
    };


    //業者ごとにまとめて通知する。
    for (var notification in notifications) {
      // 送信するメッセージデータ
      for (var fcmToken in notification.fcmTokens) {
        final messageData = {
          'notification': {
            'title': '入荷コントロール',
            'body': '新しい入荷予約が確定しました。',
          },
          'data': {
            'reservations': notification.reservationIDs,
            'key2': 'value2',
          },
          //実機端末のfcmトークン
          'to': fcmToken,
        };
        // HTTP POSTリクエストの送信
        final response = await http.post(url,
            headers: headers,
            body: jsonEncode(messageData),
            encoding: Encoding.getByName('utf-8'));

        // レスポンスの確認
        if (response.statusCode == 200) {
          print('FCM通知が正常に送信されました');
          print('レスポンスボディ: ${response.body}');
        } else {
          print('FCM通知の送信に失敗しました: ${response.statusCode}');
          print('レスポンスボディ: ${response.body}');
        }
      }
    }
  }

  Future<String> getAccessToken() async {
    final jsonPath = 'json/service-account-key.json';

    // HTTPリクエストでファイルを取得
    final response = await http.get(Uri.parse(jsonPath));

    print('response:$response');
    if (response.statusCode == 200) {
      final credentials = ServiceAccountCredentials.fromJson(json.decode(response.body));

      // 有効期限の短い OAuth 2.0 アクセス トークンを取得
      final client = await clientViaServiceAccount(credentials, ['https://www.googleapis.com/auth/firebase.messaging']);
      final accessToken = await client.credentials.accessToken;

      return accessToken.data;
    } else {
      throw Exception('Failed to load service account key');
    }
  }

  Future<void> sendFCMNotificationV1(List<ReservationNotification> notifications) async {
    final accessToken = await getAccessToken();
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/berthapp-c3c59/messages:send');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    // 業者ごとにまとめて通知する。
    for (var notification in notifications) {
      // 送信するメッセージデータ
      for (var fcmToken in notification.fcmTokens) {
        final messageData = {
          'message': {
            'token': fcmToken,
            'notification': {
              'title': '入荷コントロール',
              'body': '新しい入荷予約が確定しました。',
            },
            'data': {
              'key1': 'value1', // ここに必要なデータを追加
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
          print('レスポンスボディ: ${response.body}');
        } else {
          print('FCM通知の送信に失敗しました: ${response.statusCode}');
          print('レスポンスボディ: ${response.body}');
        }
      }
    }
  }
}