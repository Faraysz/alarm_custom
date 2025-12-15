import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'main.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});
  
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? pickedTime;
  int durationSeconds = 10; // default durasi bunyi 10 detik

  Future<void> scheduleAlarm(TimeOfDay time) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await notificationsPlugin.zonedSchedule(
      1,
      'Alarm',
      'Waktunya!',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Channel',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // STOP suara otomatis setelah durasi
    Future.delayed(Duration(seconds: durationSeconds), () {
      notificationsPlugin.cancel(1); // hentikan suara alarm
    });
  }

  pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (result != null) {
      setState(() => pickedTime = result);
      await scheduleAlarm(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Alarm diset pukul ${result.format(context)}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarm App")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              pickedTime == null
                  ? "Belum ada alarm"
                  : "Alarm: ${pickedTime!.format(context)}",
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 30),

            // Pilih durasi alarm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Durasi alarm (detik):",
                  style: TextStyle(fontSize: 20),
                ),
                DropdownButton<int>(
                  value: durationSeconds,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text("5 detik")),
                    DropdownMenuItem(value: 10, child: Text("10 detik")),
                    DropdownMenuItem(value: 20, child: Text("20 detik")),
                    DropdownMenuItem(value: 30, child: Text("30 detik")),
                    DropdownMenuItem(value: 60, child: Text("1 menit")),
                  ],
                  onChanged: (v) {
                    setState(() => durationSeconds = v!);
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: pickTime, child: const Text("Set Alarm")),
          ],
        ),
      ),
    );
  }
}
