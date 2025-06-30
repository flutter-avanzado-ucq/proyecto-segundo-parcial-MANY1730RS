import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

class EditTaskSheet extends StatefulWidget {
  final int index; // índice de la tarea a editar

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  // 1. Aquí se define el manejo de la hora (dueTime)
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Se obtienen los valores actuales de la tarea a editar
    final task =
        Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task.dueDate;
    _selectedTime =
        task.dueTime ??
        const TimeOfDay(
          hour: 8,
          minute: 0,
        ); // 1. Se inicializa con la hora previa
  }

  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;

      final task =
          Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      // 3. Si la tarea ya tenía una notificación, se cancela antes de programar una nueva
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
        // 3. Esto evita que queden notificaciones duplicadas cuando se edita
      }

      // Notificación inmediata para informar al usuario que actualizó
      await NotificationService.showImmediateNotification(
        title: 'Tarea actualizada',
        body: 'Has actualizado la tarea: $newTitle',
        payload: 'Tarea actualizada: $newTitle',
      );

      // 1. Si hay fecha y hora nuevas, se agenda una notificación futura
      if (_selectedDate != null && _selectedTime != null) {
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // 2. Se genera un nuevo notificationId para esta notificación programada
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
          100000,
        );

        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea actualizada',
          body: 'No olvides: $newTitle',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea actualizada: $newTitle para $scheduledDateTime',
          notificationId: notificationId, // 2. Se usa aquí
        );
      }

      // Se actualiza la tarea con nueva info (incluyendo notificationId)
      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        newDate: _selectedDate,
        newTime: _selectedTime,
        notificationId: notificationId, // 2. Se guarda el identificador
      );

      Navigator.pop(context); // Cierra el modal
    }
  }

  // Selección de fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Selección de hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ??
          TimeOfDay.now(), // 1. Aquí también se manipula la hora
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Interfaz
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Editar tarea',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Cambiar fecha'),
              ),
              const SizedBox(width: 10),
              if (_selectedDate != null)
                Text(
                  '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Cambiar hora'),
              ),
              const SizedBox(width: 10),
              const Text('Hora: '),
              if (_selectedTime != null)
                Text(
                  '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
