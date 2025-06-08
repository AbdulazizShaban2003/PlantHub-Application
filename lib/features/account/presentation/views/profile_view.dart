import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/auth/presentation/controller/operation_controller.dart';
import 'package:plant_hub_app/features/auth/presentation/controller/vaildator_auth_controller.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/outlined_button_widget.dart';
import '../../../auth/presentation/components/build_Text_field.dart';
import '../controllers/country_controller.dart';
import '../manager/profile_provider.dart';
import '../widgets/headerEmailProfileWidget.dart';
import '../widgets/header_full_name_profile_widget.dart';
import '../widgets/select_image_widget.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String _selectedGender = "Male";
  DateTime? _selectedDate;
  String _countryCode = "+20"; // Changed default to Egypt
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile().then((_) {
        final profile = context.read<ProfileProvider>().profile;
        if (profile != null) {
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phoneNumber;
          _countryCode = profile.countryCode;
          _selectedGender = profile.gender;
          _selectedDate = profile.birthdate;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImagePath = path.join(directory.path, fileName);

      final File imageFile = File(image.path);
      await imageFile.copy(savedImagePath);

      await context.read<ProfileProvider>().updateProfileImage(savedImagePath);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.copyWith(
              labelLarge: TextStyle(
                fontSize: 16,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                minimumSize: Size(64, 50),
                padding: EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 0.85,
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      FlushbarHelper.createInformation(
        message: AppStrings.fillRequiredFields,
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    final provider = context.read<ProfileProvider>();
    final currentProfile = provider.profile;

    if (currentProfile != null) {
      try {
        OperationController().showLoadingDialog(
          context,
          AppStrings.savingProfile,
        );

        final updatedProfile = currentProfile.copyWith(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          countryCode: _countryCode,
          gender: _selectedGender,
          birthdate: _selectedDate,
        );

        await provider.updateProfile(updatedProfile);

        Navigator.of(context, rootNavigator: true).pop();

        FlushbarHelper.createSuccess(
          message: AppStrings.profileSaved,
          duration: const Duration(seconds: 3),
        ).show(context);

      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();

        FlushbarHelper.createError(
          message: '${AppStrings.profileSaveFailed}${e.toString()}',
          duration: const Duration(seconds: 5),
        ).show(context);
      }
    } else {
      FlushbarHelper.createError(
        message: AppStrings.noProfileData,
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      body: provider.isLoading && provider.profile == null
          ? const Center(
        child: CircularProgressIndicator(
          color: ColorsManager.greenPrimaryColor,
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              AppKeyStringTr.myProfile,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: SizeConfig().height(0.03)),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: SelectedImageWidget(
                      profileImagePath: provider.profileImagePath,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.05)),
                HeaderFullNameProfileWidget(
                  nameController: _nameController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                HeaderEmailProfileWidget(
                  emailController: _emailController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppKeyStringTr.phoneNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),
                    BuildTextField(
                      hintText: '',
                      controller: _phoneController,
                      validator: (value) => ValidatorController().phoneValid(
                        value,
                        country: getCountryFromCode(_countryCode),
                      ),
                      keyboardType: TextInputType.phone,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: SizeConfig().width(0.25),
                          height: SizeConfig().height(0.01),
                          child: CountryCodePicker(
                            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            dialogSize: Size(
                              SizeConfig().width(0.9),
                              SizeConfig().height(0.7),
                            ),
                            searchDecoration: InputDecoration(
                              hintText: AppKeyStringTr.searchCountry,
                              hintStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: SizeConfig().responsiveFont(13),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: SizeConfig().height(0.001),
                                horizontal: SizeConfig().width(0.01),
                              ),
                            ),
                            onChanged: (code) {
                              setState(() {
                                _countryCode = code.dialCode ?? "+20";
                              });
                            },
                            initialSelection: 'EG',
                            favorite: const ['EG', 'SA', 'AE', 'KW', 'QA', 'OM', 'BH'],
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: true,
                            padding: EdgeInsets.all(1),
                            margin: EdgeInsets.all(5),
                            countryFilter: arabCountries,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: SizeConfig().responsiveFont(12),
                            ),
                            dialogTextStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: SizeConfig().responsiveFont(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppKeyStringTr.gender,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: SizeConfig().height(0.02)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: ColorsManager.whiteColor.withOpacity(0.1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          dropdownColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig().width(0.05),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGender = newValue!;
                            });
                          },
                          items: [AppKeyStringTr.male, AppKeyStringTr.female]
                              .map<DropdownMenuItem<String>>(
                                (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value, style: Theme.of(context).textTheme.bodySmall),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppKeyStringTr.birthdate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig().width(0.03),
                          vertical: SizeConfig().height(0.008),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: ColorsManager.whiteColor.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? AppKeyStringTr.selectDate
                                  : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: _selectedDate == null
                                    ? ColorsManager.greyColor
                                    : ColorsManager.whiteColor,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: ColorsManager.greyColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig().height(0.05)),
                OutlinedButtonWidget(
                  nameButton: AppKeyStringTr.save,
                  onPressed: _saveProfile,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

