import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class PhotoWidget extends StatelessWidget {
  final String photoLink;

  const PhotoWidget({super.key, required this.photoLink});

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      photoLink,
      fit: BoxFit.cover,
      cache: true,
      enableSlideOutPage: true,
      filterQuality: FilterQuality.high,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
            break;
          case LoadState.completed:
            return null;
            break;
          case LoadState.failed:
            return GestureDetector(
              child: const Center(
                child: Text("Reload"),
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
            break;
        }
        return Text("");
      },
    );
  }
}
