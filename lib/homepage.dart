import 'package:alarmapp/new_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:alarmapp/clock_widget.dart';
import 'package:alarmapp/style.dart';
import 'package:alarmapp/time_model.dart';
import 'alarm.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Alarm> alarms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 86, 87, 113),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
                var currentTime = DateTime.now();

                String seconds = DateTime.now().second < 10
                    ? "0${DateTime.now().second}"
                    : DateTime.now().second.toString();
                String minute = DateTime.now().minute < 10
                    ? "0${DateTime.now().minute}"
                    : DateTime.now().minute.toString();
                String hour = DateTime.now().hour < 10
                    ? "0${DateTime.now().hour}"
                    : DateTime.now().hour.toString();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Text(
                        "$hour:$minute PM",
                        style: AppStyle.mainText,
                      ),
                    ),
                    Center(
                      child: ClockWidget(
                        TimeModel(currentTime.hour, currentTime.minute,
                            currentTime.second),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    return buildAlarmTile(alarms[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show the time picker and wait for a result
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          // If a time is selected, navigate to the NewAlarmScreen
          if (selectedTime != null) {
            final result = await Navigator.push<Alarm>(
              context,
              MaterialPageRoute(
                builder: (context) => NewAlarmScreen(),
              ),
            );

            // If a new alarm is added, update the list
            if (result != null) {
              setState(() {
                alarms.add(result);
              });
            }
          }
        },
        child: Icon(Icons.alarm),
      ),
    );
  }

  Widget buildAlarmTile(Alarm alarm) {
    return ListTile(
      title: Text('${alarm.hour}:${alarm.minute} - ${alarm.title}'),
      subtitle: Text('Sound: ${alarm.sound}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: alarm.isActive,
            onChanged: (value) {
              setState(() {
                alarm.isActive = value;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              // Navigate to the NewAlarmScreen to edit the alarm
              final result = await Navigator.push<Alarm>(
                context,
                MaterialPageRoute(
                  builder: (context) => NewAlarmScreen(alarm: alarm),
                ),
              );

              // If the alarm is edited, update the list
              if (result != null) {
                setState(() {
                  alarms[alarms.indexOf(alarm)] = result;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
