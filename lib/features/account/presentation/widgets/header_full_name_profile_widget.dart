import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../../../core/utils/size_config.dart';
import '../../../auth/presentation/components/build_Text_field.dart' show BuildTextField;

class HeaderFullNameProfileWidget extends StatelessWidget {
  const HeaderFullNameProfileWidget({
    super.key,
    required TextEditingController nameController,
  }) : _nameController = nameController;

  final TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppKeyStringTr.fullName,
            style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: SizeConfig().height(0.01)),
        BuildTextField(
          hintText: '',
          controller: _nameController,
          keyboardType: TextInputType.name,
          prefixIcon: Icon(Icons.person,
              size: 18,
              color: Theme.of(context).iconTheme.color),
        ),
      ],
    );
  }
}
