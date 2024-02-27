class ReservationNotification {
  //constructor
  ReservationNotification({
    required this.userCode,
  });
  final String userCode;
  List<String> reservationIDs = [];
  List<String> fcmTokens = [];

  void addReservationID(String id) {
    reservationIDs.add(id);
  }

  void addFcmToken(List<String> token) {
    fcmTokens = token;
  }
}
