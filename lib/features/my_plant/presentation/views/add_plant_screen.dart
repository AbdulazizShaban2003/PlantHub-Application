import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/features/my_plant/presentation/views/set_reminder_view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/size_config.dart';
import '../../models/notification_model.dart';
import '../widgets/build_image_widget.dart';
import '../../providers/plant_provider.dart';

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
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Plant',
          style: TextStyle(fontSize: SizeConfig().responsiveFont(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, size: SizeConfig().responsiveFont(24)),
            onPressed: _savePlant,
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
              BuildBasicInfoWidget(nameController: _nameController, categoryController: _categoryController, descriptionController: _descriptionController,),
              _buildImageSection(),
              SizedBox(height: SizeConfig().height(0.03)),
              _buildActionSection(),
            ],
          ),
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
              'Plant images',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: SizeConfig().responsiveFont(15)
                )
            ),
            SizedBox(height: SizeConfig().height(0.02)),
             buildMainImagePicker(),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildAdditionalImagesPicker(),
          ],
        ),
      ),
    );
  }

  Widget buildMainImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Image *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig().responsiveFont(14),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: SizeConfig().height(0.25),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
            ),
            child: _mainImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
              child: Image.file(
                File(_mainImage!.path),
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: SizeConfig().height(0.08),
                  color: Colors.grey,
                ),
                SizedBox(height: SizeConfig().height(0.01)),
                Text(
                  'Tap to add main image',
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

  Widget _buildAdditionalImagesPicker() {
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
          height: SizeConfig().height(0.12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickAdditionalImages,
                child: Container(
                  width: SizeConfig().width(0.25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: SizeConfig().height(0.05),
                        color: Colors.grey,
                      ),
                      Text(
                        'Add',
                        style: TextStyle(fontSize: SizeConfig().responsiveFont(12)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: SizeConfig().width(0.02)),
              ..._additionalImages.map(
                    (image) => Container(
                  width: SizeConfig().width(0.25),
                  margin: EdgeInsets.only(right: SizeConfig().width(0.02)),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                        child: Image.file(
                          File(image.path),
                          width: SizeConfig().width(0.25),
                          height: SizeConfig().height(0.12),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: SizeConfig().height(0.005),
                        right: SizeConfig().height(0.005),
                        child: GestureDetector(
                          onTap: () => _removeAdditionalImage(image),
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig().width(0.005)),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: SizeConfig().height(0.02),
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
                fontSize: SizeConfig().responsiveFont(16),
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
          width: SizeConfig().height(0.05),
          height: SizeConfig().height(0.05),
          decoration: BoxDecoration(
            color: actionType.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            actionType.icon,
            color: Colors.white,
            size: SizeConfig().height(0.025),
          ),
        ),
        title: Text(
          actionType.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig().responsiveFont(14),
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
          activeColor: Colors.green,
        ),
        onTap: isSelected ? () => _setReminder(actionType) : null,
        subtitle: isSelected && _actionReminders[actionType] != null
            ? Text(
          'Reminder set for ${_actionReminders[actionType]!.time.toString().substring(0, 16)}',
          style: TextStyle(
            fontSize: SizeConfig().responsiveFont(12),
            color: Colors.green,
          ),
        )
            : null,
      ),
    );
  }

  Future<void> _showImageSourceSelection(
      Function(ImageSource) onSourceSelected,
      ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_camera,
                  size: SizeConfig().responsiveFont(24),
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  size: SizeConfig().responsiveFont(24),
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                ),
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
        builder: (context) => SetReminderView(
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
        SnackBar(
          content: Text(
            'Please select a main image',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
          ),
        ),
      );
      return;
    }

    final plantProvider = context.read<PlantProvider>();

    // Create actions list
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
          SnackBar(
            content: Text(
              'Error: ${plantProvider.error}',
              style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Plant added successfully!',
            style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
          ),
        ),
      );
    }
  }
}
