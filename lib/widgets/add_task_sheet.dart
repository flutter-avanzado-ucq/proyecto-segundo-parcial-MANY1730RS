import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

// Importar AppLocalizations generado
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      int? notificationId;
      DateTime? finalDueDate;

      // practica: notificación inmediata al agregar
      await NotificationService.showImmediateNotification(
        title: 'Nueva tarea',
        body: 'Has agregado la tarea: $text',
        payload: 'Tarea: $text',
      );

      if (_selectedDate != null && _selectedTime != null) {
        // practica: aquí se combina la FECHA y HORA seleccionadas por el usuario para programar la notificación exacta
        finalDueDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // practica: generación de un identificador único para la notificación programada
        notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea',
          body: 'No olvides: $text',
          scheduledDate:
              finalDueDate, // practica: FECHA y HORA exacta de la notificación
          payload: 'Tarea programada: $text para $finalDueDate',
          notificationId:
              notificationId, // practica: se pasa el identificador único para esta notificación
        );
      }

      // Integración Hive: guardar la tarea en Provider + Hive
      Provider.of<TaskProvider>(context, listen: false).addTask(
        text,
        dueDate: finalDueDate ??
            _selectedDate, // practica: aquí se guarda la FECHA y HORA completas en la tarea
        notificationId:
            notificationId, // practica: se guarda el identificador de la notificación programada
      );

      Navigator.pop(context);
    }
  }

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
            localizations.addNewTask,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: localizations.description,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(localizations.selectDate),
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
                child: Text(localizations.selectTime),
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
            label: Text(localizations.addTask),
          ),
        ],
      ),
    );
  }
}
