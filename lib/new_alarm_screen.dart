// new_alarm_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'alarm.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NewAlarmScreen extends StatefulWidget {
  final TimeOfDay? selectedTime;
  final Alarm? alarm;

  const NewAlarmScreen({Key? key, this.selectedTime, this.alarm})
      : super(key: key);

  @override
  _NewAlarmScreenState createState() => _NewAlarmScreenState();
}

class _NewAlarmScreenState extends State<NewAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _titleController;
  late TextEditingController _soundController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initState();
    _selectedTime = widget.selectedTime ?? TimeOfDay.now();
    _titleController = TextEditingController(text: widget.alarm?.title ?? "");
    _soundController = TextEditingController(text: widget.alarm?.sound ?? "");
  }

  Future<void> _initState() async {
    if (!kIsWeb) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        // Handle the case where permission is denied
        print('Permission denied');
      }
    }
  }

  Future<void> _pickSound() async {
    print('Attempting to pick sound');

    var status = await Permission.storage.request();

    if (status.isGranted) {
      file_picker.FilePickerResult? result =
          await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _soundController.text = result.files.first.path ?? '';
          print('Selected sound path: ${_soundController.text}');
        });
      } else {
        print('No sound selected');
      }
    } else {
      print('Permission denied');
    }
  }

  Future<void> _scheduleNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create a unique ID for the notification
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final soundPath = _soundController.text;

    final player = AudioPlayer();
    await player.setFilePath(soundPath);
    await player.play();

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Alarm Notification',
      'Your alarm for ${_selectedTime.hour}:${_selectedTime.minute} is ringing!',
      tz.TZDateTime.now(tz.local)
          .add(const Duration(seconds: 5)), // Add your desired delay
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'Custom_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'New Alarm' : 'Edit Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Time',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                '${_selectedTime.hour}:${_selectedTime.minute}',
                style: const TextStyle(fontSize: 24),
              ),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );

                if (pickedTime != null && pickedTime != _selectedTime) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
            ),
            ListTile(
              title: TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ),
            ListTile(
              title: TextField(
                controller: _soundController,
                decoration:
                    const InputDecoration(labelText: 'Over the Horizon.mp3'),
                readOnly: true,
                onTap: _pickSound,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Text('Active'),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scheduleNotification();
          // Create or update the alarm
          Alarm newAlarm = Alarm(
            DateTime.now().millisecondsSinceEpoch, // Unique ID for each alarm
            _selectedTime.hour,
            _selectedTime.minute,
            _titleController.text,
            _soundController.text,
            true,
          );

          Navigator.pop(context, newAlarm);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
