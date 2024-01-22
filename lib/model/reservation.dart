import 'package:flutter/cupertino.dart';

@immutable
class Reservation {
  Reservation({
    required this.date,
    required this.time,
    required this.clientCD,
    required this.clientName,
    required this.deliveryPort,
  });
  String date;
  String time;
  int clientCD;
  String clientName;
  String deliveryPort;
}
