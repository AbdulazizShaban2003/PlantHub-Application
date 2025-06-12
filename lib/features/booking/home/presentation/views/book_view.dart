import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/home_view_body.dart';
class BookView extends StatelessWidget {
  const BookView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Popular Books",style: Theme.of(context).textTheme.headlineMedium,),
      ),
      body: BookViewBody(),
    );
  }
}
