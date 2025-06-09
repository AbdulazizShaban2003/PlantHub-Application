import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildCircleIcon extends StatelessWidget {
   const BuildCircleIcon({super.key, required this.showBadge, required this.iconData, required this.onPressed});
 final  bool showBadge ;
 final IconData iconData;
 final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(iconData,size: 20,),
            splashRadius: 18,
          ),
        ),
        if (showBadge!)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}


