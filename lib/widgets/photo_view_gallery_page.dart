import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

// import 'package:pumo_partner/features/auth/cubit/auth_cubit.dart';

class PhotoViewGalleryPage extends StatefulWidget {
  final List<dynamic> imageSources; // Accept both String (URL) and File
  final int initialIndex;

  const PhotoViewGalleryPage({
    super.key,
    required this.imageSources,
    this.initialIndex = 0,
  });

  @override
  State<PhotoViewGalleryPage> createState() => _PhotoViewGalleryPageState();
}

class _PhotoViewGalleryPageState extends State<PhotoViewGalleryPage> {
  bool _isAppBarVisible = true;

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isAppBarVisible
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBarVisibility, // Toggle AppBar visibility on tap
        child: PhotoViewGallery.builder(
          itemCount: widget.imageSources.length,
          builder: (context, index) {
            final imageSource = widget.imageSources[index];

            // Determine the ImageProvider based on the type of imageSource
            final ImageProvider<Object> imageProvider = imageSource is String
                ? NetworkImage(imageSource, headers: {
                    // "Authorization":
                    //     "Bearer ${context.read<AuthCubit>().state.token}"
                  }) as ImageProvider<Object> // URL
                : FileImage(imageSource as File)
                    as ImageProvider<Object>; // File

            return PhotoViewGalleryPageOptions(
              imageProvider: imageProvider,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              heroAttributes: PhotoViewHeroAttributes(tag: imageSource),
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          pageController: PageController(initialPage: widget.initialIndex),
        ),
      ),
    );
  }
}
