import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_Text_field.dart';
class InputUsernameTextField extends StatelessWidget {
  const InputUsernameTextField({super.key, required this.usernameController});
final TextEditingController usernameController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            AppKeyStringTr.username,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        BuildTextField(
          keyboardType: TextInputType.text,
          hintText:  AppKeyStringTr.username,
          controller: usernameController,
          prefixIcon: Icon(Icons.person,size: 18,)
        ),
      ],
    );
  }
}
