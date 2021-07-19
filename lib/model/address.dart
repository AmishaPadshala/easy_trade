import 'package:meta/meta.dart';

class Address {
  String id, personName, flatNo, area, landmark, city, pinCode, phoneNo;

  Address({
    @required this.personName,
    @required this.flatNo,
    @required this.area,
    this.landmark = '',
    @required this.city,
    @required this.pinCode,
    this.phoneNo = '',
  }) : this.id = DateTime.now().toIso8601String();

  String formFullAddress() {
    return "No. $flatNo, $area, $city-$pinCode.";
  }
}
