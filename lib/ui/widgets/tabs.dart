import 'package:datty/bloc/authentication/authentication_bloc.dart';
import 'package:datty/bloc/authentication/authentication_event.dart';
import 'package:datty/ui/pages/matches.dart';
import 'package:datty/ui/pages/messages.dart';
import 'package:datty/ui/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';

class Tabs extends StatelessWidget {
  final String userId;

  const Tabs({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Search(userId: userId),
      Matches(userId: userId),
      Messages(userId: userId),
    ];

    return Theme(
      data: ThemeData(
        primaryColor: backgroundColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Chill",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                },
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                height: 48.0,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TabBar(
                      tabs: <Widget>[
                        Tab(icon: Icon(Icons.search)),
                        Tab(icon: Icon(Icons.people)),
                        Tab(icon: Icon(Icons.message)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: pages,
          ),
        ),
      ),
    );
  }
}