import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../providers/plant_provider.dart';
import 'set_reminder_screen.dart';

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
    // Initialize only the 4 main actions
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
              'Care Actions',
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

  // Show image source selection (Camera or Gallery)
  Future<void> _showImageSourceSelection(Function(ImageSource) onSourceSelected) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMainImage() async {
    await _showImageSourceSelection((source) async {
      final plantProvider = context.read<PlantProvider>();
      final XFile? image = await plantProvider.pickImage(source);
      if (image != null) {
        setState(() {
          _mainImage = image;
        });
      }
    });
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
    final result = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderScreen(
          actionType: actionType,
          existingReminder: _actionReminders[actionType],
        ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${plantProvider.error}')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant added successfully!')),
      );
    }
  }
}
