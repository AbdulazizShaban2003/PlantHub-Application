import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

Widget buildHeaderCard(
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
    ),
    child: Container(
      padding: EdgeInsets.all(SizeConfig().width(0.05)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: SizeConfig().responsiveFont(28),
              ),
              SizedBox(width: SizeConfig().width(0.03)),
              Expanded(
                child: Text(
                  AppStrings.headerCardTitle,
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig().height(0.015)),
          Text(
            AppStrings.headerCardDescription,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(15),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ),
  );
}
