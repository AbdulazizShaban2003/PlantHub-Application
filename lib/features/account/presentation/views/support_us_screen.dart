import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.contactSupportTitle,
          style: Theme.of(context).textTheme.bodyLarge
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          children: [
            SizedBox(height: SizeConfig().height(0.02)),
            _buildContactItem(
              icon: Icons.email,
              iconColor: const Color(0xFF00D4AA),
              title: AppStrings.contactEmail,
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: AppStrings.emailAddress,
                  queryParameters: {
                    'subject': AppStrings.emailSubject,
                    'body': AppStrings.emailBody,
                  },
                );

                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.emailError)),
                  );
                }
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildContactItem(
              icon: Icons.language,
              iconColor: const Color(0xFF00D4AA),
              title: AppStrings.website,
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(AppStrings.websiteUrl))) {
                  await launchUrl(Uri.parse(AppStrings.websiteUrl));
                }
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildContactItem(
              icon: Icons.chat,
              iconColor: const Color(0xFF25D366),
              title: AppStrings.whatsApp,
              onTap: () async {
                const appUrl = 'https://wa.me/${AppStrings.whatsAppNumber}';
                const webUrl = 'https://web.whatsapp.com/send?phone=${AppStrings.whatsAppNumber}';

                if (await canLaunchUrl(Uri.parse(appUrl))) {
                  await launchUrl(Uri.parse(appUrl));
                } else {
                  await launchUrl(Uri.parse(webUrl));
                }
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildContactItem(
              icon: Icons.facebook,
              iconColor: const Color(0xFF1877F2),
              title: AppStrings.facebook,
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(AppStrings.facebookUrl))) {
                  await launchUrl(Uri.parse(AppStrings.facebookUrl));
                }
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig().width(0.06),
            vertical: SizeConfig().height(0.02)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig().width(0.02)),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: SizeConfig().responsiveFont(24),
              ),
            ),
            SizedBox(width: SizeConfig().width(0.04)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(16), // Responsive font size
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: SizeConfig().responsiveFont(16), // Responsive icon size
            ),
          ],
        ),
      ),
    );
  }
}