
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../../../core/utils/size_config.dart';
import '../../../auth/presentation/components/build_Text_field.dart' show BuildTextField;

class HeaderEmailProfileWidget extends StatelessWidget {
  const HeaderEmailProfileWidget({
    super.key,
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppKeyStringTr.email,
            style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: SizeConfig().height(0.01)),
        BuildTextField(
          hintText: '',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined,
              size: 18,
              color: Theme.of(context).iconTheme.color),
          read: true,
        ),
      ],
    );
  }
}
