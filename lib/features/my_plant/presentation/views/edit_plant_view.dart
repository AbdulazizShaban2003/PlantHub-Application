import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/notification_model.dart';
import '../../providers/plant_provider.dart';
import '../../services/database_helper.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;

  const EditPlantScreen({super.key, required this.plant});

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  XFile? _newMainImage;
  List<XFile> _newAdditionalImages = [];
  final Map<ActionType, bool> _selectedActions = {};
  final Map<ActionType, Reminder?> _actionReminders = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.plant.name;
    _categoryController.text = widget.plant.category;
    _descriptionController.text = widget.plant.description;

    for (final actionType in ActionType.values) {
      final existingAction =
          widget.plant.actions
              .where((action) => action.type == actionType)
              .firstOrNull;

      if (existingAction != null) {
        _selectedActions[actionType] = existingAction.isEnabled;
        _actionReminders[actionType] = existingAction.reminder;
      } else {
        _selectedActions[actionType] = false;
        _actionReminders[actionType] = null;
      }
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
        title: Text(
          'Edit Plant',
          style: TextStyle(fontSize: SizeConfig().responsiveFont(20)),
        ),
        actions: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: SizeConfig().width(0.16),
              maxWidth: SizeConfig().width(0.25),
            ),

            child: GestureDetector(
              onTap: _savePlant,

              child: Text('Save', style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig().width(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              SizedBox(height: SizeConfig().height(0.03)),
              _buildImageSection(),
              SizedBox(height: SizeConfig().height(0.03)),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,

      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            TextFormField(
              controller: _nameController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Plant Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter plant name';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            TextFormField(

              controller: _categoryController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Category',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            TextFormField(
              controller: _descriptionController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Images',
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildCurrentMainImage(),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildCurrentAdditionalImages(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMainImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Image',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig().responsiveFont(14),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        GestureDetector(
          onTap: _pickNewMainImage,
          child: Container(
            height: SizeConfig().height(0.25),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
            ),
            child:
                _newMainImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        SizeConfig().width(0.02),
                      ),
                      child: Image.file(
                        File(_newMainImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                    : widget.plant.mainImagePath.isNotEmpty &&
                        File(widget.plant.mainImagePath).existsSync()
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        SizeConfig().width(0.02),
                      ),
                      child: Image.file(
                        File(widget.plant.mainImagePath),
                        fit: BoxFit.cover,
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: SizeConfig().responsiveFont(48),
                          color: Colors.grey,
                        ),
                        SizedBox(height: SizeConfig().height(0.01)),
                        Text(
                          'Tap to change main image',
                          style: TextStyle(
                            fontSize: SizeConfig().responsiveFont(14),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAdditionalImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Images',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig().responsiveFont(14),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        SizedBox(
          height: SizeConfig().height(0.125),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickNewAdditionalImages,
                child: Container(
                  width: SizeConfig().width(0.25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(
                      SizeConfig().width(0.02),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: SizeConfig().responsiveFont(32),
                        color: Colors.grey,
                      ),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: SizeConfig().width(0.02)),
              ...widget.plant.additionalImagePaths.map((imagePath) {
                if (File(imagePath).existsSync()) {
                  return Container(
                    width: SizeConfig().width(0.25),
                    margin: EdgeInsets.only(right: SizeConfig().width(0.02)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        SizeConfig().width(0.02),
                      ),
                      child: Image.file(
                        File(imagePath),
                        width: SizeConfig().width(0.25),
                        height: SizeConfig().height(0.125),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
              ..._newAdditionalImages.map(
                (image) => Container(
                  width: SizeConfig().width(0.25),
                  margin: EdgeInsets.only(right: SizeConfig().width(0.02)),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          SizeConfig().width(0.02),
                        ),
                        child: Image.file(
                          File(image.path),
                          width: SizeConfig().width(0.25),
                          height: SizeConfig().height(0.125),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: SizeConfig().height(0.005),
                        right: SizeConfig().width(0.01),
                        child: GestureDetector(
                          onTap: () => _removeNewAdditionalImage(image),
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig().width(0.005)),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: SizeConfig().responsiveFont(16),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,

      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Actions',
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            ...ActionType.values.map(
              (actionType) => _buildActionTile(actionType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(ActionType actionType) {
    final bool isSelected = _selectedActions[actionType] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig().height(0.01)),
      child: ListTile(
        leading: Container(
          width: SizeConfig().width(0.1),
          height: SizeConfig().width(0.1),
          decoration: BoxDecoration(
            color: actionType.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            actionType.icon,
            color: Colors.white,
            size: SizeConfig().responsiveFont(20),
          ),
        ),
        title: Text(
          actionType.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig().responsiveFont(16),
          ),
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
          activeColor: ColorsManager.greenPrimaryColor,
        ),
        onTap: isSelected ? () => _setReminder(actionType) : null,
        subtitle:
            isSelected && _actionReminders[actionType] != null
                ? Text(
                  'Reminder set for ${_actionReminders[actionType]!.time.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(12),
                    color: ColorsManager.greenPrimaryColor,
                  ),
                )
                : null,
      ),
    );
  }

  Future<void> _pickNewMainImage() async {
    final plantProvider = context.read<PlantProvider>();
    final XFile? image = await plantProvider.pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newMainImage = image;
      });
    }
  }

  Future<void> _pickNewAdditionalImages() async {
    final plantProvider = context.read<PlantProvider>();
    final List<XFile> images = await plantProvider.pickMultipleImages();
    setState(() {
      _newAdditionalImages.addAll(images);
    });
  }

  void _removeNewAdditionalImage(XFile image) {
    setState(() {
      _newAdditionalImages.remove(image);
    });
  }

  Future<void> _setReminder(ActionType actionType) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder:
          (context) => ReminderDialog(
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

    final plantProvider = context.read<PlantProvider>();

    try {
      String mainImagePath = widget.plant.mainImagePath;
      if (_newMainImage != null) {
        mainImagePath = await plantProvider.saveImageToLocal(
          _newMainImage!,
          widget.plant.id,
          true,
        );
      }

      List<String> additionalImagePaths = List.from(
        widget.plant.additionalImagePaths,
      );
      for (final image in _newAdditionalImages) {
        final String imagePath = await plantProvider.saveImageToLocal(
          image,
          widget.plant.id,
          false,
        );
        additionalImagePaths.add(imagePath);
      }

      final List<PlantAction> actions = [];
      for (final entry in _selectedActions.entries) {
        if (entry.value) {
          actions.add(
            PlantAction(
              id: _uuid.v4(),
              type: entry.key,
              isEnabled: true,
              reminder: _actionReminders[entry.key],
            ),
          );
        }
      }

      final Plant updatedPlant = widget.plant.copyWith(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        mainImagePath: mainImagePath,
        additionalImagePaths: additionalImagePaths,
        actions: actions,
        updatedAt: DateTime.now(),
      );

      await plantProvider.updatePlant(updatedPlant);

      if (plantProvider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${plantProvider.error}')),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Plant updated successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating plant: $e')));
      }
    }
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
      title: Text(
        'Set ${widget.actionType.displayName} Reminder',
        style: TextStyle(fontSize: SizeConfig().responsiveFont(18)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tasks:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig().responsiveFont(16),
              ),
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            ..._tasks.map(
              (task) => ListTile(
                dense: true,
                title: Text(
                  task,
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: SizeConfig().responsiveFont(20),
                  ),
                  onPressed: () {
                    setState(() {
                      _tasks.remove(task);
                    });
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Add new task',
                      isDense: true,
                      hintStyle: TextStyle(
                        fontSize: SizeConfig().responsiveFont(14),
                      ),
                    ),
                    style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: SizeConfig().responsiveFont(24),
                  ),
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
            Divider(),
            SizedBox(height: SizeConfig().height(0.02)),
            ListTile(
              title: Text(
                'Date & Time',
                style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
              ),
              subtitle: Text(
                _selectedDateTime.toString().substring(0, 16),
                style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
              ),
              trailing: Icon(
                Icons.calendar_today,
                size: SizeConfig().responsiveFont(24),
              ),
              onTap: _selectDateTime,
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            DropdownButtonFormField<RepeatType>(
              value: _selectedRepeat,
              decoration: InputDecoration(
                labelText: 'Repeat',
                labelStyle: TextStyle(
                  fontSize: SizeConfig().responsiveFont(16),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                ),
              ),
              items:
                  RepeatType.values.map((repeat) {
                    return DropdownMenuItem(
                      value: repeat,
                      child: Text(
                        repeat.displayName,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(14),
                        ),
                      ),
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
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
          ),
        ),
        ElevatedButton(
          onPressed: _saveReminder,
          child: Text(
            'Save',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
          ),
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
        SnackBar(
          content: Text(
            'Please add at least one task',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
          ),
        ),
      );
      return;
    }

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
