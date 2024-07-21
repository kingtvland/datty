import 'dart:io';
import 'package:datty/bloc/authentication/authentication_bloc.dart';
import 'package:datty/bloc/authentication/authentication_event.dart';
import 'package:datty/bloc/profile/bloc.dart';
import 'package:datty/repositories/user_repository.dart';
import 'package:datty/ui/constants.dart';
import 'package:datty/ui/widgets/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key, required UserRepository userRepository}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();

  String? gender;
  String? interestedIn;
  DateTime? age;
  File? photo;
  GeoPoint? location;
  late ProfileBloc _profileBloc;

  bool get isFilled =>
      _nameController.text.isNotEmpty &&
          gender != null &&
          interestedIn != null &&
          photo != null &&
          age != null;

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting;
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    location = GeoPoint(position.latitude, position.longitude);
  }

  Future<void> _onSubmitted() async {
    await _getLocation();
    if (isFilled) {
      _profileBloc.add(
        Submitted(
          name: _nameController.text,
          age: age!,
          location: location!,
          gender: gender!,
          interestedIn: interestedIn!,
          photo: photo!,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        photo = File(result.files.single.path!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Profile Creation Unsuccessful'),
                  Icon(Icons.error)
                ],
              ),
            ),
          );
        }
        if (state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Submitting'),
                  CircularProgressIndicator()
                ],
              ),
            ),
          );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              color: backgroundColor,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildProfilePhoto(size),
                  _buildTextField(_nameController, "Name", size),
                  _buildBirthdayPicker(size),
                  SizedBox(height: size.height * 0.02),
                  _buildGenderSection("You Are", gender, size),
                  SizedBox(height: size.height * 0.02),
                  _buildGenderSection("Looking For", interestedIn, size),
                  _buildSubmitButton(state, size),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePhoto(Size size) {
    return Container(
      width: size.width,
      child: GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: size.width * 0.3,
          backgroundColor: Colors.transparent,
          backgroundImage: photo != null ? FileImage(photo!) : null,
          child: photo == null
              ? Image.asset('assets/profilephoto.png')
              : null,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String text, Size size) {
    return Padding(
      padding: EdgeInsets.all(size.height * 0.02),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(color: Colors.white, fontSize: size.height * 0.03),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayPicker(Size size) {
    return GestureDetector(
      onTap: () {
        DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(1900, 1, 1),
          maxTime: DateTime(DateTime.now().year - 19, 1, 1),
          onConfirm: (date) {
            setState(() {
              age = date;
            });
          },
        );
      },
      child: Text(
        "Enter Birthday",
        style: TextStyle(color: Colors.white, fontSize: size.width * 0.09),
      ),
    );
  }

  Widget _buildGenderSection(String title, String? selectedGender, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.height * 0.02),
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: size.width * 0.09),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildGenderWidget(FontAwesomeIcons.venus, "Female", size, selectedGender),
            _buildGenderWidget(FontAwesomeIcons.mars, "Male", size, selectedGender),
            _buildGenderWidget(FontAwesomeIcons.transgender, "Transgender", size, selectedGender),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderWidget(IconData icon, String label, Size size, String? selectedGender) {
    return genderWidget(
      icon,
      label,
      size,
      selectedGender,
          () {
        setState(() {
          if (selectedGender == gender) {
            gender = label;
          } else {
            interestedIn = label;
          }
        });
      },
    );
  }

  Widget _buildSubmitButton(ProfileState state, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: GestureDetector(
        onTap: isButtonEnabled(state) ? _onSubmitted : null,
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.06,
          decoration: BoxDecoration(
            color: isButtonEnabled(state) ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(size.height * 0.05),
          ),
          child: Center(
            child: Text(
              "Save",
              style: TextStyle(fontSize: size.height * 0.025, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}

class DatePicker {
}