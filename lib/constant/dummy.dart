import '../model/reservation.dart';

class Dummy {
  static final Reservation reservation = Reservation(
      date: "20231228",
      time: "9:30",
      clientCD: 111111,
      clientName: "A社",
      deliveryPort: "C-1");

  static final List<Reservation> reservationList =
      List.generate(100, (index) => reservation);

  static const String mailHint = "mail@wentz-design.com";
  static const String passHint = "password";
}
