class User {
  int id;
  String username = '';
  String name = '';
  String lang = '';
  int age = 18;
  int gender = 0;
  int height = 0;
  bool waterCalculation = false;
  int waterAmount = 5000;

  User();

  User.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'] ?? 0;
    this.username = json['username'];
    this.name = json['name'];
    this.lang = json['lang'];
    this.age = json['age'];
    this.gender = json['gender'];
    this.height = json['height'];
    this.waterCalculation = json['water_calculation'];
    this.waterAmount = json['water_amount'];
  }
}
