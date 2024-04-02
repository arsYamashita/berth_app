import 'package:cloud_firestore/cloud_firestore.dart';

class DeliverySearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> searchDeliveries({
    required String deliveryStartDate,
    required String deliveryEndDate,
    String? deliveryStartTime,
    String? deliveryEndTime,
    String? branchCode,
    String? userCode,
    String? deliveryPort,
  }) async {
    Query dateQuery = _firestore.collection('reservation');

    // deliveryStartDateとdeliveryEndDateの間の日付のデータを取得
    if (deliveryStartDate.isNotEmpty && deliveryEndDate.isNotEmpty) {
      DateTime startDate = DateTime.parse(deliveryStartDate);
      DateTime endDate =
          DateTime.parse(deliveryEndDate).add(const Duration(days: 1));

      Timestamp formattedStartDate = Timestamp.fromDate(startDate);
      Timestamp formattedEndDate = Timestamp.fromDate(endDate);

      dateQuery =
          dateQuery.where('date', isGreaterThanOrEqualTo: formattedStartDate);
      dateQuery = dateQuery.where('date', isLessThan: formattedEndDate);
    }

    // クエリを実行し、結果を取得
    QuerySnapshot dateQuerySnapshot = await dateQuery.get();

    List<DocumentSnapshot> resultSet = dateQuerySnapshot.docs;

    if (deliveryStartTime != null &&
        deliveryEndTime != null &&
        deliveryStartTime.isNotEmpty &&
        deliveryEndTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime startTime =
            DateTime.parse("2000-01-01 ${deliveryStartTime.padLeft(5, '0')}");
        DateTime endTime =
            DateTime.parse("2000-01-01 ${deliveryEndTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return (startTime.isBefore(docTimeOnlyHourMinute) ||
                startTime.isAtSameMomentAs(docTimeOnlyHourMinute)) &&
            (endTime.isAfter(docTimeOnlyHourMinute) ||
                endTime.isAtSameMomentAs(docTimeOnlyHourMinute));
      }).toList();
    } else if (deliveryStartTime != null && deliveryStartTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime startTime =
            DateTime.parse("2000-01-01 ${deliveryStartTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return startTime.isBefore(docTimeOnlyHourMinute) ||
            startTime.isAtSameMomentAs(docTimeOnlyHourMinute);
      }).toList();
    } else if (deliveryEndTime != null && deliveryEndTime.isNotEmpty) {
      resultSet = resultSet.where((doc) {
        Timestamp docDateTime = doc['date'];
        DateTime endTime =
            DateTime.parse("2000-01-01 ${deliveryEndTime.padLeft(5, '0')}");
        DateTime docTime = docDateTime.toDate();
        // 年月日は無視して、時分だけを比較
        DateTime docTimeOnlyHourMinute =
            DateTime(2000, 1, 1, docTime.hour, docTime.minute);
        return endTime.isAfter(docTimeOnlyHourMinute) ||
            endTime.isAtSameMomentAs(docTimeOnlyHourMinute);
      }).toList();
    }

    // 他の条件にも同様に対応
    if (branchCode != null && branchCode.isNotEmpty) {
      // dateQuery = dateQuery.where('branchCode', isEqualTo: branchCode);

      resultSet = resultSet.where((doc) {
        String docBranchCode = doc['branchCode'];
        return branchCode == docBranchCode;
      }).toList();
    }
    if (userCode != null && userCode.isNotEmpty) {
      // dateQuery = dateQuery.where('userCode', isEqualTo: userCode);
      resultSet = resultSet.where((doc) {
        String docUserCode = doc['userCode'];
        return userCode == docUserCode;
      }).toList();
    }
    if (deliveryPort != null && deliveryPort.isNotEmpty) {
      // dateQuery = dateQuery.where('deliveryPort', isEqualTo: deliveryPort);
      resultSet = resultSet.where((doc) {
        String docDeliveryPort = doc['deliveryPort'];
        return deliveryPort == docDeliveryPort;
      }).toList();
    }

    return resultSet;
  }
}
