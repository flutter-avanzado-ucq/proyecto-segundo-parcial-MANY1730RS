import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

// Widget de formulario para agregar una nueva tarea
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();

  // 1. Aquí se declara la hora de vencimiento seleccionada para la tarea (dueTime)
  TimeOfDay? _selectedTime;

  // También se declara la fecha de vencimiento (dueDate)
  DateTime? _selectedDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Función que se llama al presionar "Agregar tarea"
  void _submit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      int? notificationId;

      // Muestra una notificación inmediata para confirmar al usuario
      await NotificationService.showImmediateNotification(
        title: 'Nueva tarea',
        body: 'Has agregado la tarea: $text',
        payload: 'Tarea: $text',
      );

      // 1. Si el usuario seleccionó una fecha y una hora, se programa la notificación
      if (_selectedDate != null && _selectedTime != null) {
        // Combina fecha + hora en un solo DateTime
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // 2. Se genera un notificationId único
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
          100000,
        );

        // 2. Se programa la notificación para el futuro con ese ID
        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea',
          body: 'No olvides: $text',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea programada: $text para $scheduledDateTime',
          notificationId: notificationId,
        );
      }

      // Se agrega la tarea al provider, incluyendo dueDate, dueTime y notificationId
      Provider.of<TaskProvider>(context, listen: false).addTask(
        text,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        notificationId: notificationId, // 2. Se guarda el identificador aquí
      );

      Navigator.pop(context); // Cierra el formulario
    }
  }

  // Muestra un selector de fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Muestra un selector de hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // UI del formulario de nueva tarea
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
            'Agregar nueva tarea',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Seleccionar fecha'),
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
                child: const Text('Seleccionar hora'),
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
            label: const Text('Agregar tarea'),
          ),
        ],
      ),
    );
  }
}
