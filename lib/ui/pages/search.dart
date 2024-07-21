import 'package:datty/bloc/search/bloc.dart';
import 'package:datty/models/user.dart';
import 'package:datty/repositories/search_repository.dart';
import 'package:datty/ui/widgets/iconWidget.dart';
import 'package:datty/ui/widgets/profile.dart';
import 'package:datty/ui/widgets/user_gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Search extends StatefulWidget {
  final String userId;

  const Search({required this.userId});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final SearchRepository _searchRepository = SearchRepository();
  late SearchBloc _searchBloc;
  User? _user, _currentUser;
  int? difference;

  Future<void> getDifference(GeoPoint? userLocation) async {
    if (userLocation == null) return;

    Position position = await Geolocator.getCurrentPosition();

    double location = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      position.latitude,
      position.longitude,
    );

    setState(() {
      difference = location.toInt();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(searchRepository: _searchRepository);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<SearchBloc, SearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state is InitialSearchState) {
          _searchBloc.add(LoadUserEvent(userId: widget.userId));
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
            ),
          );
        }
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
            ),
          );
        }
        if (state is LoadUserState) {
          _user = state.user;
          _currentUser = state.currentUser;

          getDifference(_user!.location as GeoPoint?);
          if (_user?.location == null) {
            return const Text(
              "No One Here",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          } else {
            return profileWidget(
              padding: size.height * 0.035,
              photoHeight: size.height * 0.824,
              photoWidth: size.width * 0.95,
              photo: _user!.photo,
              clipRadius: size.height * 0.02,
              containerHeight: size.height * 0.3,
              containerWidth: size.width * 0.9,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: size.height * 0.06),
                    Row(
                      children: <Widget>[
                        userGender(_user!.gender),
                        Expanded(
                          child: Text(
                            " ${_user!.name}, ${_user!.age}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.height * 0.05,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.location_on, color: Colors.white),
                        Text(
                          difference != null
                              ? "${(difference! / 1000).floor()}km away"
                              : "away",
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    SizedBox(height: size.height * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        iconWidget(EvaIcons.flash, () {}, size.height * 0.04, Colors.yellow),
                        iconWidget(Icons.clear, () {
                          _searchBloc.add(PassUserEvent(widget.userId, _user!.uid));
                        }, size.height * 0.08, Colors.blue),
                        iconWidget(FontAwesomeIcons.solidHeart, () {
                          _searchBloc.add(
                            SelectUserEvent(
                              name: _currentUser!.name,
                              photoUrl: _currentUser!.photo,
                              currentUserId: widget.userId,
                              selectedUserId: _user!.uid,
                            ),
                          );
                        }, size.height * 0.06, Colors.red),
                        iconWidget(EvaIcons.options2, () {}, size.height * 0.04, Colors.white)
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        }
        return Container();
      },
    );
  }
}