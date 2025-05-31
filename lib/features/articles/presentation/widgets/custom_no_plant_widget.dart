import 'package:flutter/material.dart';

import '../../../../core/utils/size_config.dart';

class CustomNoPlantWidget extends StatelessWidget {
  const CustomNoPlantWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 150, bottom: 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/no_searsh.png'),
            height: 200,
          ),
          Text(
            'No Plants Found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            'Check your keywords or try searching with another keywords.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
