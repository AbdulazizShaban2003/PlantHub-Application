import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';
import 'package:plant_hub_app/features/auth/presentation/components/build_Text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = "Male";
  DateTime? _selectedDate;
  String _countryCode = "+1";
  bool _isLoading = true;
  String? _profileImagePath;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _genders = ["Male", "Female"];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Load profile image from shared preferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  // Save profile image path to shared preferences
  Future<void> _saveProfileImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Set email from Firebase Auth
        _emailController.text = currentUser.email ?? '';

        // Get additional user data from Firestore
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userData.exists) {
          final data = userData.data();
          if (data != null) {
            setState(() {
              _nameController.text = data['name'] ?? '';
              _phoneController.text = data['phoneNumber'] ?? '';
              _countryCode = data['countryCode'] ?? '+1';
              _selectedGender = data['gender'] ?? 'Male';

              // Convert Firestore timestamp to DateTime if exists
              if (data['birthdate'] != null) {
                _selectedDate = (data['birthdate'] as Timestamp).toDate();
              }
            });
          }
        } else {
          // Create a new document for the user if it doesn't exist
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': currentUser.displayName ?? '',
            'email': currentUser.email ?? '',
            'phoneNumber': '',
            'countryCode': '+1',
            'gender': 'Male',
            'birthdate': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

          _nameController.text = currentUser.displayName ?? '';
        }
      } else {
        // Handle case where user is not logged in
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save user data to Firebase
  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'countryCode': _countryCode,
          'gender': _selectedGender,
          'birthdate':
              _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving user data: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick and save profile image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImagePath = path.join(directory.path, fileName);

      // Copy the image to app documents directory
      final File imageFile = File(image.path);
      await imageFile.copy(savedImagePath);

      // Save the path to shared preferences
      await _saveProfileImagePath(savedImagePath);

      setState(() {
        _profileImagePath = savedImagePath;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00A86B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back
          },
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF00A86B)),
      )
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            image: _profileImagePath != null
                                ? DecorationImage(
                              image: FileImage(
                                File(_profileImagePath!),
                              ),
                              fit: BoxFit.cover,
                            )
                                : const DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/150?img=11',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A86B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.05)),
                Text("Full Name",
                    style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: SizeConfig().height(0.02)),
                BuildTextField(
                  hintText: '',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icon(Icons.person,
                      size: 18,
                      color: Theme.of(context).iconTheme.color),
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                Text("Email",
                    style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: SizeConfig().height(0.02)),
                BuildTextField(
                  hintText: '',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined,
                      size: 18,
                      color: Theme.of(context).iconTheme.color),
                  read: true,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                const Text("Phone Number",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                const SizedBox(height: 8),

                 BuildTextField(
                  hintText: '',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                   prefixIcon: SizedBox(
                     width: 150,
                     height: 70,
                     child: CountryCodePicker(
                       dialogBackgroundColor: Colors.black,
                       onChanged: (code) {
                         setState(() {
                           _countryCode = code.dialCode ?? "+1";
                         });
                       },
                       initialSelection: 'EG',
                       favorite: const ['EG', 'SA', 'AE'],
                       showCountryOnly: true,
                       showOnlyCountryWhenClosed: false,
                       alignLeft: true,
                       padding: EdgeInsets.all(10),

                       countryFilter: [
                         'EG', 'SA', 'AE', 'KW', 'QA', 'OM', 'BH', 'JO',
                         'LB', 'IQ', 'MA', 'DZ', 'TN', 'LY', 'SD', 'YE',
                         'SY', 'PS', 'MR', 'DJ', 'SO', 'KM',
                       ],
                       textStyle: const TextStyle(
                           color: Colors.black, fontSize: 16),
                       dialogTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onSecondary)
                     ),
                   ),
                ),
                const SizedBox(height: 20),
                const Text("Gender",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                      items: _genders
                          .map<DropdownMenuItem<String>>((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Birthdate",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? "Select date"
                              : DateFormat('MM/dd/yyyy')
                              .format(_selectedDate!),
                          style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButtonWidget(
                  nameButton: "Save",
                  onPressed: _saveUserData,
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

}
