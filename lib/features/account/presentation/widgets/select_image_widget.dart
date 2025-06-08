import 'dart:io';

import 'package:flutter/material.dart';

class SelectedImageWidget extends StatelessWidget {
  const SelectedImageWidget({
    super.key,
    required String? profileImagePath,
  }) : _profileImagePath = profileImagePath;

  final String? _profileImagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            image: _profileImagePath != null
                ? DecorationImage(
              image: FileImage(
                File(_profileImagePath!),
              ),
              fit: BoxFit.cover,
            )
                : const DecorationImage(
              image: NetworkImage(
                'https://i.pravatar.cc/150?img=11',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF00A86B),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
