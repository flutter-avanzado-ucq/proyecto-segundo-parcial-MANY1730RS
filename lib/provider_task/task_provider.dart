import 'package:flutter/material.dart';
import '../services/notification_service.dart';

// Clase que representa una tarea individual.
class Task {
  String title;
  bool done;

  // 1. Manejo de la hora (dueTime): Se agregó como atributo opcional.
  DateTime? dueDate;
  TimeOfDay? dueTime;

  // 2. Identificador de notificacion (notificationId): Se guarda aquí.
  int? notificationId;

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.dueTime,
    this.notificationId, // 2. Se inicializa aquí si existe una notificacion programada.
  });
}

// Proveedor de tareas que gestiona el estado.
class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  // Metodo para agregar una nueva tarea al inicio de la lista.
  void addTask(
    String title, {
    DateTime? dueDate,
    TimeOfDay? dueTime,
    int? notificationId,
  }) {
    _tasks.insert(
      0,
      Task(
        title: title,
        dueDate: dueDate,
        dueTime:
            dueTime, // 1. Se asigna la hora de vencimiento al crear la tarea.
        notificationId:
            notificationId, // 2. Se guarda el ID de la notificacion.
      ),
    );
    notifyListeners();
  }

  // Cambia el estado de completado de una tarea.
  void toggleTask(int index) {
    _tasks[index].done = !_tasks[index].done;
    notifyListeners();
  }

  // Elimina una tarea, y si tenia una notificacion, tambien la cancela.
  void removeTask(int index) {
    final task = _tasks[index];

    // 3. Cancelacion de la notificacion anterior:
    // Si existe un notificationId, se cancela la notificacion pendiente.
    // Esto es importante para evitar que el usuario reciba alertas de tareas eliminadas.
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    _tasks.removeAt(index);
    notifyListeners();
  }

  // Actualiza una tarea existente y programa una nueva notificacion si aplica.
  void updateTask(
    int index,
    String newTitle, {
    DateTime? newDate,
    TimeOfDay? newTime,
    int? notificationId,
  }) {
    final task = _tasks[index];

    // 3. Cancelacion de la notificacion anterior (si existe):
    // Es importante para evitar duplicados de notificaciones y mantener actualizado el recordatorio.
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    // Se actualizan los campos, incluyendo la hora (1) y el ID de notificacion (2)
    _tasks[index].title = newTitle;
    _tasks[index].dueDate = newDate;
    _tasks[index].dueTime = newTime;
    _tasks[index].notificationId = notificationId;

    notifyListeners();
  }
}
