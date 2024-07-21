import 'package:datty/bloc/matches/bloc.dart';
import 'package:datty/models/user.dart';
import 'package:datty/repositories/matches_repository.dart';
import 'package:datty/ui/widgets/iconWidget.dart';
import 'package:datty/ui/widgets/pageTurn.dart';
import 'package:datty/ui/widgets/profile.dart';
import 'package:datty/ui/widgets/user_gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'messaging.dart';

class Matches extends StatefulWidget {
  final String userId;

  const Matches({super.key, required this.userId});

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  final MatchesRepository matchesRepository = MatchesRepository();
  late final MatchesBloc _matchesBloc;

  @override
  void initState() {
    super.initState();
    _matchesBloc = MatchesBloc(matchesRepository: matchesRepository);
    _matchesBloc.add(LoadListsEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    _matchesBloc.close();
    super.dispose();
  }

  Future<int> getDifference(GeoPoint userLocation) async {
    final position = await Geolocator.getCurrentPosition();
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      position.latitude,
      position.longitude,
    );
    return distance.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<MatchesBloc, MatchesState>(
      bloc: _matchesBloc,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LoadUserState) {
          return CustomScrollView(
            slivers: <Widget>[
              const SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                title: Text(
                  "Matched User",
                  style: TextStyle(color: Colors.black, fontSize: 30.0),
                ),
              ),
              _buildMatchedList(state.matchedList, size),
              const SliverAppBar(
                backgroundColor: Colors.white,
                pinned: true,
                title: Text(
                  "Someone Likes You",
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
              _buildSelectedList(state.selectedList, size),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _buildMatchedList(Stream<QuerySnapshot> matchedList, Size size) {
    return StreamBuilder<QuerySnapshot>(
      stream: matchedList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final users = snapshot.data!.docs;
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (context, index) => _buildUserTile(users[index], size, isMatched: true),
            childCount: users.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        );
      },
    );
  }

  Widget _buildSelectedList(Stream<QuerySnapshot> selectedList, Size size) {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final users = snapshot.data!.docs;
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (context, index) => _buildUserTile(users[index], size, isMatched: false),
            childCount: users.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        );
      },
    );
  }

  Widget _buildUserTile(DocumentSnapshot userDoc, Size size, {required bool isMatched}) {
    return GestureDetector(
      onTap: () => _showUserDialog(userDoc, size, isMatched),
      child: profileWidget(
        padding: size.height * 0.01,
        photo: userDoc['photoUrl'],
        photoWidth: size.width * 0.5,
        photoHeight: size.height * 0.3,
        clipRadius: size.height * 0.01,
        containerHeight: size.height * 0.03,
        containerWidth: size.width * 0.5,
        child: Text(
          "  ${userDoc['name']}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showUserDialog(DocumentSnapshot userDoc, Size size, bool isMatched) async {
    final selectedUser = await matchesRepository.getUserDetails(userDoc.id);
    final currentUser = await matchesRepository.getUserDetails(widget.userId);
    final difference = await getDifference(selectedUser.location);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildUserProfileWidget(selectedUser, currentUser, size, difference, isMatched),
      ),
    );
  }

  Widget _buildUserProfileWidget(User selectedUser, User currentUser, Size size, int difference, bool isMatched) {
    return profileWidget(
      photo: selectedUser.photo,
      photoHeight: size.height,
      padding: size.height * 0.01,
      photoWidth: size.width,
      clipRadius: size.height * 0.01,
      containerWidth: size.width,
      containerHeight: size.height * 0.2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.height * 0.02),
        child: ListView(
          children: <Widget>[
            SizedBox(height: size.height * 0.02),
            _buildUserInfo(selectedUser, size),
            _buildLocationInfo(difference),
            SizedBox(height: size.height * 0.01),
            _buildActionButtons(selectedUser, currentUser, size, isMatched),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user, Size size) {
    return Row(
      children: <Widget>[
        userGender(user.gender),
        Expanded(
          child: Text(
            " ${user.name}, ${user.age}",
            style: TextStyle(color: Colors.white, fontSize: size.height * 0.05),
          ),
        )
      ],
    );
  }
  Widget _buildLocationInfo(int difference) {
    return Row(
      children: <Widget>[
        const Icon(Icons.location_on, color: Colors.white),
        Text(
          "${(difference / 1000).floor()} km away",
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }

  Widget _buildActionButtons(User selectedUser, User currentUser, Size size, bool isMatched) {
    if (isMatched) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(size.height * 0.02),
            child: iconWidget(
              Icons.message,
                  () {
                _matchesBloc.add(OpenChatEvent(
                  currentUser: widget.userId,
                  selectedUser: selectedUser.uid,
                ));
                pageTurn(Messaging(currentUser: currentUser, selectedUser: selectedUser), context);
              },
              size.height * 0.04,
              Colors.white,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          iconWidget(
            Icons.clear,
                () {
              _matchesBloc.add(DeleteUserEvent(
                currentUser: currentUser.uid,
                selectedUser: selectedUser.uid,
              ));
              Navigator.of(context).pop();
            },
            size.height * 0.08,
            Colors.blue,
          ),
          SizedBox(width: size.width * 0.05),
          iconWidget(
            FontAwesomeIcons.solidHeart,
                () {
              _matchesBloc.add(AcceptUserEvent(
                selectedUser: selectedUser.uid,
                currentUser: currentUser.uid,
                currentUserPhotoUrl: currentUser.photo,
                currentUserName: currentUser.name,
                selectedUserPhotoUrl: selectedUser.photo,
                selectedUserName: selectedUser.name,
              ));
              Navigator.of(context).pop();
            },
            size.height * 0.06,
            Colors.red,
          ),
        ],
      );
    }
  }
}