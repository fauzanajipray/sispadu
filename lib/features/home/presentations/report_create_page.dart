import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sispadu/helpers/dialog.dart';
import 'package:sispadu/helpers/helpers.dart' as helpers;
import 'package:sispadu/features/features.dart';
import 'package:sispadu/utils/utils.dart';
import 'package:sispadu/widgets/widgets.dart';

class ReportCreatePage extends StatefulWidget {
  const ReportCreatePage({Key? key}) : super(key: key);

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<File> _images = [];
  final List<String?> _uploadedUrls = [];
  final List<LoadStatus> _uploadStatuses = []; // Track upload statuses

  late BuildContext mainContext;
  final ImagePicker _picker = ImagePicker();
  UserSimple? _label;

  @override
  void initState() {
    super.initState();
    initAsycn();
  }

  void initAsycn() async {
    // context.read<PositionCubit>().getData();
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
      ),
      body: BlocListener<ReportCreateCubit, DataState<void>>(
        listener: (context, state) {
          if (state.status == LoadStatus.success) {
            helpers.showSnackBar(
              context,
              'Report created successfully!',
            );
            context.pop(true);
          } else if (state.status == LoadStatus.failure) {
            DioExceptions err =
                DioExceptions.fromDioError(state.error!, context);
            if (err.mappedMessage != null) {
              showDialogMsg(
                  context,
                  title: 'Submission Failed',
                  helpers.concatAllMappedMessage(err.mappedMessage));
            } else {
              showDialogMsg(
                  context, title: 'Submission Failed', err.toString());
            }
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.only(bottom: 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Report :',
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
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      decoration:
                          const InputDecoration(hintText: 'Enter description'),
                    ),
                    const SizedBox(height: 16),
                    /*
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: BlocBuilder<CompetitorLabelCubit,
                          DataState<List<SimpleData>>>(
                        builder: (context, state) {
                          return DropdownSearch<SimpleData>(
                            itemAsString: (item) => item.name ?? '--',
                            selectedItem: _label,
                            items: state.item ?? [],
                            validator: (value) {
                              if (value == null) {
                                return "Label can't be empty";
                              }
                              return null;
                            },
                            popupProps: PopupProps.menu(
                                showSearchBox: true,
                                itemBuilder: (context, item, _) {
                                  bool isSelected = _label == item;
                                  return Container(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : Theme.of(context).colorScheme.surface,
                                    child: ListTile(
                                      selected: isSelected,
                                      title: Text(
                                        '${item.name}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                filled: false,
                                errorMaxLines: 3,
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                label: const Text('Label'),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _label = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const Text(
                      'Select label for your Report',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    */
                  ],
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.only(bottom: 8, top: 0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Image Attach :',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ..._images.asMap().entries.map((entry) {
                            int index = entry.key;
                            File image = entry.value;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PhotoViewGalleryPage(
                                          imageSources: _images,
                                          initialIndex: index),
                                    ),
                                  ),
                                  child: _getImage(image, index),
                                ),
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                        _uploadedUrls.removeAt(index);
                                        _uploadStatuses.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          if (_images.length < 3)
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
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add images to your report',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.only(bottom: 8, top: 4),
                width: double.infinity,
                child: MyButton(
                  text: 'Submit',
                  onPressed: _submitReport,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage(BuildContext context) async {
    File? image = await helpers.getImage(context, ImageSource.gallery, _picker);
    if (image != null) {
      setState(() {
        _images.add(image);
        _uploadedUrls.add(null); // Placeholder for uploaded URL
        _uploadStatuses.add(LoadStatus.loading); // Initial status
      });
      _uploadImage(image, _images.length - 1);
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

        // Handle error
        DioExceptions err = DioExceptions.fromDioError(state.error!, context);
        if (err.mappedMessage != null) {
          showDialogMsg(
              context,
              title: 'Upload Failed',
              helpers.concatAllMappedMessage(err.mappedMessage));
        } else {
          showDialogMsg(context, title: 'Upload Failed', err.toString());
        }
      }
    });
  }

  Future<void> _retryUpload(File image, int index) async {
    setState(() {
      _uploadStatuses[index] = LoadStatus.loading;
    });
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
        // Handle error
        DioExceptions err = DioExceptions.fromDioError(state.error!, context);
        if (err.mappedMessage != null) {
          showDialogMsg(
              context,
              title: 'Upload Failed',
              helpers.concatAllMappedMessage(err.mappedMessage));
        } else {
          showDialogMsg(context, title: 'Upload Failed', err.toString());
        }
      }
    });
  }

  Widget _getImage(dynamic image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _uploadedUrls[index] != null
              ? SizedBox(
                  height: 150.0,
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(8),
                  //     color: Colors.transparent),
                  child: ExtendedImage.network(
                    _uploadedUrls[index]!,
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
                        // Custom loading progress widget
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
                        // Print error message
                        debugPrint(
                            'Failed to load image: ${state.lastException}');
                        // Fallback widget for failed image loading
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

                      // Default behavior for successfully loaded images
                      return null;
                    },
                  ),
                )
              : Image.file(
                  image,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
          // : Container(),
        ),
        if (_uploadStatuses[index] == LoadStatus.loading ||
            _uploadStatuses[index] == LoadStatus.failure)
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
                        onTap: () => _retryUpload(image, index), // Retry upload
                        child: const Icon(
                          Icons.replay,
                          // size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_uploadedUrls.isEmpty) {
        showDialogMsg(
          context,
          title: 'No Images',
          'Please upload at least one image before submitting.',
        );
        return;
      }

      if (_uploadedUrls.any((url) => url == null)) {
        showDialogMsg(
          context,
          title: 'Incomplete Uploads',
          'Please wait for all images to finish uploading before submitting.',
        );
        return;
      }

      // if (_label == null) {
      //   showDialogMsg(
      //     context,
      //     title: 'Missing Label',
      //     'Please select a label for your report.',
      //   );
      //   return;
      // }

      context.read<ReportCreateCubit>().createReport(
            title: _titleController.text,
            content: _descriptionController.text,
            postionId: '${_label?.id ?? ''}',
            imageUrls: _uploadedUrls.cast<String>(),
          );
    }
  }
}
