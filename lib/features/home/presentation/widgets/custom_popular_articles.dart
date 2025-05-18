import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_header.dart';

class CustomPopularArticles extends StatelessWidget {
  const CustomPopularArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildHeader(header: AppKeyStringTr.popularArticles),
        SizedBox(height: SizeConfig().height(0.035)),
        SizedBox(
          height: SizeConfig().width(0.65),
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: SizeConfig().width(0.55),
                    height: SizeConfig().height(0.18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage("assets/images/testPhoto.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig().width(0.5),
                    child: Text(
                      'The Ultimate Guide to Growing Tomatoes History, Cultivation, and Care'
                      ,softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.03)),
            itemCount: 10,
          ),
        ),
      ],
    );
  }
}

