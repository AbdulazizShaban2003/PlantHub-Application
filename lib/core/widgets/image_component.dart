import 'package:flutter/material.dart';

import '../utils/asstes_manager.dart';
import '../utils/size_config.dart';
class ImageComponent extends StatelessWidget {
  const ImageComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig().width(0.5),
      height: SizeConfig().height(0.2),
      child: Image(
        image: AssetImage(AsstesManager.getStartedLogo),
      ),
    );
  }
}
