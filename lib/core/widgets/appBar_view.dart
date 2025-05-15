import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/size_config.dart';
class CustomAppBarView extends StatelessWidget {
  const CustomAppBarView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        width: SizeConfig().width(0.1),
        height: SizeConfig().height(0.055),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(CupertinoIcons.back,color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}
