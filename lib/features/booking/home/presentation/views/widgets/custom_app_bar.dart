import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import '../../../../../../core/utils/size_config.dart';
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(top: SizeConfig().height(0.06), bottom: SizeConfig().height(0.02)),
      child: Column(
        children: [
          Center(child: Text(AppKeyStringTr.popularBook,style: Theme.of(context).textTheme.headlineMedium,textAlign: TextAlign.center,)),
          SizedBox(height: SizeConfig().height(0.02),),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig().width(0.04),
                vertical: SizeConfig().height(0.03)),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppKeyStringTr.searchArticles,

              ),
            ),
          ),
        ],
      ),
    );
  }
}
