import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sispadu/helpers/dialog.dart' as dialog;
import 'package:sispadu/helpers/helpers.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';
import 'package:sispadu/widgets/widgets.dart';

class ReportEditPage extends StatefulWidget {
  const ReportEditPage(this.id, {super.key});

  final String? id;

  @override
  State<ReportEditPage> createState() => _ReportEditPageState();
}

class _ReportEditPageState extends State<ReportEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _apiImages = []; // Gambar dari API
  final List<File> _uploadedImages = []; // Gambar yang baru di-upload
  final List<String?> _uploadedUrls = []; // URL hasil upload
  final List<LoadStatus> _uploadStatuses = []; // Status upload
  late BuildContext mainContext;
  final ImagePicker _picker = ImagePicker();
  UserSimple? _label;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
    // context.read<CompetitorLabelCubit>().getLabel();
  }

  Future<void> _fetchReportDetails() async {
    final reportCubit = context.read<ReportCubit>();
    await reportCubit.getReportDetail(widget.id!);
    final report = reportCubit.state.item;

    if (report != null) {
      setState(() {
        _titleController.text = report.title ?? '';
        _descriptionController.text = report.content ?? '';
        // _label = UserSimple(id: report.tempPositionId, name: report.label?.name);
        _apiImages
            .addAll(report.images?.map((image) => image.imagePath ?? '') ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
      ),
      body: BlocListener<ReportCreateCubit, DataState<void>>(
        listener: (context, state) {
          if (state.status == LoadStatus.success) {
            showSnackBar(
              context,
              'Competitor review updated successfully!',
            );
            Navigator.pop(context, true); // Kembalikan true setelah update
          } else if (state.status == LoadStatus.failure) {
            DioExceptions err =
                DioExceptions.fromDioError(state.error!, context);
            if (err.mappedMessage != null) {
              dialog.showDialogMsg(
                  context, concatAllMappedMessage(err.mappedMessage));
            } else {
              dialog.showDialogMsg(context, err.toString());
            }
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Description field
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration:
                          const InputDecoration(hintText: 'Enter title'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      minLines: 3,
                      maxLines: null,
                      decoration:
                          const InputDecoration(hintText: 'Enter description'),
                    ),
                  ],
                ),
              ),
              // Label dropdown
              // Container(
              //   color: Theme.of(context).colorScheme.surface,
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              //   margin: const EdgeInsets.only(bottom: 8),
              //   child: BlocBuilder<CompetitorLabelCubit,
              //       DataState<List<SimpleData>>>(
              //     builder: (context, state) {
              //       return DropdownSearch<SimpleData>(
              //         itemAsString: (item) => item.name ?? '--',
              //         selectedItem: _label,
              //         items: state.item ?? [],
              //         validator: (value) {
              //           if (value == null) {
              //             return "Label can't be empty";
              //           }
              //           return null;
              //         },
              //         onChanged: (value) {
              //           setState(() {
              //             _label = value;
              //           });
              //         },
              //       );
              //     },
              //   ),
              // ),
              // Section for Images
              _buildImageSection(),
              // Submit button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: MyButton(
                  text: 'Update',
                  onPressed: _submitReport,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteApiImage(String imageUrl) async {
    try {
      // await context.read<ReportCreateCubit>().deleteImage(imageUrl);
      setState(() {
        _apiImages.remove(imageUrl);
      });
    } catch (e) {
      dialog.showDialogMsg(context, title: 'Error', 'Failed to delete image.');
    }
  }

  Future<void> _addImage(BuildContext context) async {
    File? image = await getImage(context, ImageSource.gallery, _picker);
    if (image != null) {
      setState(() {
        _uploadedImages.add(image);
        _uploadedUrls.add(null);
        _uploadStatuses.add(LoadStatus.loading);
      });
      _uploadImage(image, _uploadedImages.length - 1);
    }
  }

  Future<void> _uploadImage(File image, int index) async {
    context.read<ReportUploadImageCubit>().uploadImage(image).then((_) {
      final state = context.read<ReportUploadImageCubit>().state;
      if (state.status == LoadStatus.success) {
        setState(() {
          _uploadedUrls[index] = state.item?.imagePath;
          _uploadStatuses[index] = LoadStatus.success;
        });
      } else {
        setState(() {
          _uploadStatuses[index] = LoadStatus.failure;
        });
        DioExceptions err = DioExceptions.fromDioError(state.error!, context);
        dialog.showDialogMsg(context, title: 'Upload Failed', err.toString());
      }
    });
  }

  Future<void> _retryUpload(File image, int index) async {
    setState(() {
      _uploadStatuses[index] = LoadStatus.loading;
    });
    _uploadImage(image, index);
  }

  Widget _buildImageSection() {
    // Gabungkan gambar dari API dan upload baru ke dalam satu list sementara
    final List<Map<String, dynamic>> combinedImages = [
      ..._apiImages.map((url) => {'image': url, 'isApiImage': true}),
      ..._uploadedImages.asMap().entries.map((entry) => {
            'image': entry.value,
            'isApiImage': false,
            'index': entry.key,
          }),
    ];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Images:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ...combinedImages.map((entry) {
                      final dynamic image = entry['image'];
                      final bool isApiImage = entry['isApiImage'];
                      final int? index =
                          entry['index']; // Index untuk uploaded images
                      return _getImage(image, index, isApiImage: isApiImage);
                    }).toList(),
                    if (combinedImages.length < 3)
                      GestureDetector(
                        onTap: () => _addImage(context),
                        child: Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImage(dynamic image, int? index, {required bool isApiImage}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isApiImage
              ? SizedBox(
                  height: 150.0,
                  child: ExtendedImage.network(
                    image,
                    headers: {
                      "Authorization":
                          "Bearer ${context.read<AuthCubit>().state.token}"
                    },
                    compressionRatio: kIsWeb ? null : 0.2,
                    clearMemoryCacheWhenDispose: true,
                    cache: false,
                    fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.loading) {
                        return Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state.extendedImageLoadState == LoadState.failed) {
                        return Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Failed to load image",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 126, 106, 106),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return null;
                    },
                  ),
                )
              : Image.file(
                  image,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
        ),
        if (!isApiImage &&
            (_uploadStatuses[index!] == LoadStatus.loading ||
                _uploadStatuses[index] == LoadStatus.failure))
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _uploadStatuses[index] == LoadStatus.loading
                          ? 'Uploading...'
                          : _uploadStatuses[index] == LoadStatus.failure
                              ? 'Upload Failed'
                              : '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (_uploadStatuses[index] == LoadStatus.failure)
                      Center(
                        child: GestureDetector(
                          onTap: () => _retryUpload(image, index),
                          child: const Icon(
                            Icons.replay,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: () {
              if (isApiImage) {
                dialog.showDialogConfirmation(
                  context,
                  () => _deleteApiImage(image),
                  title: 'Delete Image',
                  message: 'Are you sure you want to delete this image?',
                  positiveText: 'Delete',
                  minusText: 'Cancel',
                  buttonStyleNegative: TextButton.styleFrom(
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  buttonStylePositive: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                );
              } else {
                setState(() {
                  _uploadedImages.removeAt(index!);
                  _uploadedUrls.removeAt(index);
                  _uploadStatuses.removeAt(index);
                });
              }
            },
            child: Icon(
              Icons.cancel,
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_apiImages.isEmpty && _uploadedUrls.isEmpty) {
        dialog.showDialogMsg(
          context,
          title: 'No Images',
          'Please upload at least one image before submitting.',
        );
        return;
      }

      if (_uploadedUrls.any((url) => url == null)) {
        dialog.showDialogMsg(
          context,
          title: 'Incomplete Uploads',
          'Please wait for all images to finish uploading before submitting.',
        );
        return;
      }

      // if (_label == null) {
      //   dialog.showDialogMsg(
      //     context,
      //     title: 'Missing Label',
      //     'Please select a label for your report.',
      //   );
      //   return;
      // }

      context.read<ReportCreateCubit>().updateReport(
        id: widget.id!,
        title: _titleController.text,
        content: _descriptionController.text,
        postionId: "",
        imageUrls: [..._apiImages, ..._uploadedUrls.cast<String>()],
      );
    }
  }
}
