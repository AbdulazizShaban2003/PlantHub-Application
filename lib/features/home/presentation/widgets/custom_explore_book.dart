import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_header.dart';

class CustomExplorBook extends StatelessWidget {
  const CustomExplorBook({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildHeader(header: AppKeyStringTr.exploreBooks),
        SizedBox(height: SizeConfig().height(0.03)),
      ],
    );
  }
}
