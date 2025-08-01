import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

// Importar AppLocalizations generado
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTaskSheet extends StatefulWidget {
  final int index;

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final task =
        Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task
        .dueDate; // practica: se carga la FECHA y HORA actuales de la notificación

    if (task.dueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(task.dueDate!);
    } else {
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;
      DateTime? finalDueDate;

      final task =
          Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      // practica: cancelación de la notificación anterior antes de programar la nueva
      // importante para evitar notificaciones duplicadas o antiguas
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      await NotificationService.showImmediateNotification(
        title: 'Tarea actualizada',
        body: 'Has actualizado la tarea: $newTitle',
        payload: 'Tarea actualizada: $newTitle',
      );

      if (_selectedDate != null && _selectedTime != null) {
        // practica: aquí se combina la FECHA y HORA seleccionadas para programar la nueva notificación
        finalDueDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // practica: generación de un identificador único para la nueva notificación
        notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea actualizada',
          body: 'No olvides: $newTitle',
          scheduledDate:
              finalDueDate, // practica: FECHA y HORA exactas de la notificación
          payload: 'Tarea actualizada: $newTitle para $finalDueDate',
          notificationId:
              notificationId, // practica: se pasa el nuevo identificador
        );
      }

      // Integración Hive: actualizar la tarea en Provider + Hive
      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        // Integración Hive: se pasa la fecha completa
        newDate: finalDueDate ??
            _selectedDate, // practica: aquí se guarda la FECHA y HORA nuevas en la tarea
        notificationId:
            notificationId, // practica: se guarda el nuevo identificador de la notificación
      );

      Navigator.pop(context);
    }
  }

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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
          Text(
            localizations.editTaskTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: localizations.titleLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(localizations.changeDate),
              ),
              const SizedBox(width: 10),
              if (_selectedDate != null)
                Text(
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(localizations.changeTime),
              ),
              const SizedBox(width: 10),
              Text(localizations.timeLabel),
              if (_selectedTime != null)
                Text(
                    '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: Text(localizations.saveChanges),
          ),
        ],
      ),
    );
  }
}
