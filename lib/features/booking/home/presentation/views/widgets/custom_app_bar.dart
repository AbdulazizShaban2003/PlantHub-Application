import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../config/routes/route_helper.dart';
import '../../../../search/presentation/views/search_view.dart';
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
              onPressed: () {
                Navigator.push(context, RouteHelper.navigateTo(const SearchView()));
              },
              icon: const Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 22,
              ))
        ],
      ),
    );
  }
}
