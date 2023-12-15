// alarm_model.dart
class Alarm {
  int id; // Unique identifier for each alarm
  int hour;
  int minute;
  String title;
  String
      sound; // Notification sound (you can expand this based on your requirements)
  bool isActive;

  Alarm(this.id, this.hour, this.minute, this.title, this.sound, this.isActive);
}
