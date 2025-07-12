import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  Box<Task> get _taskBox => Hive.box<Task>('tasksBox');

  List<Task> get tasks => _taskBox.values.toList();

  void addTask(
    String title, {
    DateTime? dueDate,
    TimeOfDay? dueTime,
    int? notificationId,
  }) async {
    // 🛠️ Combinar fecha y hora si ambas están presentes
    DateTime? fullDueDate;
    if (dueDate != null && dueTime != null) {
      fullDueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );
    } else {
      fullDueDate = dueDate;
    }

    final task = Task(
      title: title,
      dueDate: fullDueDate,
      notificationId: notificationId,
    );

    await _taskBox.add(task);
    notifyListeners();
  }

  void toggleTask(int index) async {
    final task = _taskBox.getAt(index);
    if (task != null) {
      task.done = !task.done;
      await task.save();
      notifyListeners();
    }
  }

  void removeTask(int index) async {
    final task = _taskBox.getAt(index);
    if (task != null) {
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }
      await task.delete();
      notifyListeners();
    }
  }

  void updateTask(
    int index,
    String newTitle, {
    DateTime? newDate,
    TimeOfDay? newTime,
    int? notificationId,
  }) async {
    final task = _taskBox.getAt(index);
    if (task != null) {
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      task.title = newTitle;

      // 🛠️ Combinar nueva fecha y hora si están presentes
      if (newDate != null && newTime != null) {
        task.dueDate = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );
      } else {
        task.dueDate = newDate;
      }

      task.notificationId = notificationId;

      await task.save();
      notifyListeners();
    }
  }
}
