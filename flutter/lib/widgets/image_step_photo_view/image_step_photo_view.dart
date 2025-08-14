import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

class ImageStepPhotoView extends ConsumerWidget {
  final String path;

  const ImageStepPhotoView({super.key, required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: PhotoView(imageProvider: AssetImage(path)),
    );
  }
}
