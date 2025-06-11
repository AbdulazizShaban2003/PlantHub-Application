import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../providers/plant_provider.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  XFile? _mainImage;
  List<XFile> _additionalImages = [];
  final Map<ActionType, bool> _selectedActions = {};
  final Map<ActionType, Reminder?> _actionReminders = {};

  @override
  void initState() {
    super.initState();
    // Initialize all actions as disabled
    for (final actionType in ActionType.values) {
      _selectedActions[actionType] = false;
      _actionReminders[actionType] = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _savePlant,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter plant name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMainImagePicker(),
            const SizedBox(height: 16),
            _buildAdditionalImagesPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Main Image *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _mainImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_mainImage!.path),
                fit: BoxFit.cover,
              ),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Tap to add main image'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalImagesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Additional Images', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickAdditionalImages,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 32, color: Colors.grey),
                      Text('Add', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ..._additionalImages.map((image) => Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeAdditionalImage(image),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Action',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ActionType.values.map((actionType) => _buildActionTile(actionType)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(ActionType actionType) {
    final bool isSelected = _selectedActions[actionType] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: actionType.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            actionType.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          actionType.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              _selectedActions[actionType] = value;
              if (!value) {
                _actionReminders[actionType] = null;
              }
            });
          },
          activeColor: Colors.green,
        ),
        onTap: isSelected ? () => _setReminder(actionType) : null,
        subtitle: isSelected && _actionReminders[actionType] != null
            ? Text(
          'Reminder set for ${_actionReminders[actionType]!.time.toString().substring(0, 16)}',
          style: const TextStyle(fontSize: 12, color: Colors.green),
        )
            : null,
      ),
    );
  }

  Future<void> _pickMainImage() async {
    final plantProvider = context.read<PlantProvider>();
    final XFile? image = await plantProvider.pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainImage = image;
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    final plantProvider = context.read<PlantProvider>();
    final List<XFile> images = await plantProvider.pickMultipleImages();
    setState(() {
      _additionalImages.addAll(images);
    });
  }

  void _removeAdditionalImage(XFile image) {
    setState(() {
      _additionalImages.remove(image);
    });
  }

  Future<void> _setReminder(ActionType actionType) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => ReminderDialog(
        actionType: actionType,
        existingReminder: _actionReminders[actionType],
      ),
    );

    if (result != null) {
      setState(() {
        _actionReminders[actionType] = result;
      });
    }
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a main image')),
      );
      return;
    }

    final plantProvider = context.read<PlantProvider>();

    // Create actions list
    final List<PlantAction> actions = [];
    for (final entry in _selectedActions.entries) {
      if (entry.value) {
        actions.add(PlantAction(
          id: _uuid.v4(),
          type: entry.key,
          isEnabled: true,
          reminder: _actionReminders[entry.key],
        ));
      }
    }

    await plantProvider.addPlant(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      mainImage: _mainImage!,
      additionalImages: _additionalImages,
      actions: actions,
    );

    if (plantProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${plantProvider.error}')),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plant added successfully!')),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final ActionType actionType;
  final Reminder? existingReminder;

  const ReminderDialog({
    super.key,
    required this.actionType,
    this.existingReminder,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final _remindMeToController = TextEditingController();
  final List<String> _tasks = [];
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  RepeatType _selectedRepeat = RepeatType.daily;
  final _uuid = const Uuid();
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      _selectedDateTime = widget.existingReminder!.time;
      _selectedRepeat = widget.existingReminder!.repeat;
      _remindMeToController.text = widget.existingReminder!.remindMeTo;
      _tasks.addAll(widget.existingReminder!.tasks);
    } else {
      // Add default task
      final defaultTask = '${widget.actionType.displayName} your plant';
      _remindMeToController.text = defaultTask;
      _tasks.add(defaultTask);
    }
  }

  @override
  void dispose() {
    _remindMeToController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set ${widget.actionType.displayName} Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Display current tasks
            ..._tasks.map((task) => ListTile(
              dense: true,
              title: Text(task),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _tasks.remove(task);
                  });
                },
              ),
            )),
            // Add new task
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add new task',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    if (_taskController.text.trim().isNotEmpty) {
                      setState(() {
                        _tasks.add(_taskController.text.trim());
                        _taskController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date & Time'),
              subtitle: Text(_selectedDateTime.toString().substring(0, 16)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RepeatType>(
              value: _selectedRepeat,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: RepeatType.values.map((repeat) {
                return DropdownMenuItem(
                  value: repeat,
                  child: Text(repeat.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRepeat = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveReminder,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one task')),
      );
      return;
    }

    // Use first task as main reminder text
    final mainTask = _tasks.first;

    final reminder = Reminder(
      id: widget.existingReminder?.id ?? _uuid.v4(),
      time: _selectedDateTime,
      repeat: _selectedRepeat,
      remindMeTo: mainTask,
      tasks: _tasks,
      isActive: true,
    );

    Navigator.pop(context, reminder);
  }
}
