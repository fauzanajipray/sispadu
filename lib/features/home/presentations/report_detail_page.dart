import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/helpers/helpers.dart';
import 'package:sispadu/utils/utils.dart';
import 'package:sispadu/widgets/widgets.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage(this.id, {super.key});

  final String? id;

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Report? item;
  bool isAuth = true;
  bool? isUpdate = false;

  @override
  void initState() {
    super.initState();
    _fetchReviewDetail();
  }

  void _fetchReviewDetail() {
    if (widget.id != null) {
      AuthState state = context.read<AuthCubit>().state;
      final bool isAuthenticated =
          state.status == AuthStatus.authenticated && state.token != "";
      context
          .read<ReportCubit>()
          .getReportDetail(widget.id!, isAuth: isAuthenticated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Kembalikan nilai true untuk memperbarui data di halaman sebelumnya
        Navigator.pop(context, isUpdate);
        return false; // Mencegah pop default karena sudah di-handle
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Detail")),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() {
            _fetchReviewDetail();
            // context.read<CompetitorLabelCubit>().getLabel();
          }),
          child: BlocConsumer<ReportCubit, DataState<Report>>(
            listener: (context, state) {
              if (state.status == LoadStatus.success) {
                setState(() {
                  item = state.item;
                });
              }
            },
            builder: (context, state) {
              if (state.status == LoadStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == LoadStatus.failure) {
                return Center(
                  child: Text(
                    'Failed to load review details: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return ListView(
                children: [
                  // User
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item?.user?.name ?? '-',
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 14),
                              ),
                              // const SizedBox(height: 8),
                              Text(
                                formatDateTimeCustom(item?.createdAt,
                                    format: 'EEE, dd MMM yyyy HH:mm'),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextBadge(
                          text: Text(
                            item?.status ?? '-',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  // Review Details
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Reported :',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // const SizedBox(height: 8),
                        //     Text(
                        //       formatDateTimeCustom(item?.createdAt,
                        //           format: 'EEE, dd MMM yyyy HH:mm'),
                        //       textAlign: TextAlign.start,
                        //       style: const TextStyle(fontSize: 12),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 8),
                        Text(
                          item?.content ?? '-',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Images
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    margin: const EdgeInsets.only(bottom: 8, top: 4),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Image Attached :',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ((item?.images ?? []).isEmpty)
                            ? const Text(
                                'No image attached',
                                style: TextStyle(fontSize: 14),
                              )
                            : const SizedBox(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: item?.images?.map((image) {
                                  return GestureDetector(
                                      onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PhotoViewGalleryPage(
                                                      imageSources: item?.images
                                                              ?.map((e) =>
                                                                  e.imagePath ??
                                                                  '')
                                                              .toList() ??
                                                          [],
                                                      initialIndex: item?.images
                                                              ?.indexOf(
                                                                  image) ??
                                                          0),
                                            ),
                                          ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          height: 150.0,
                                          // decoration: BoxDecoration(
                                          //     borderRadius: BorderRadius.circular(8),
                                          //     color: Colors.transparent),
                                          child: ExtendedImage.network(
                                            image.imagePath ?? '',
                                            headers: {
                                              "Authorization":
                                                  "Bearer ${context.read<AuthCubit>().state.token}"
                                            },
                                            compressionRatio:
                                                kIsWeb ? null : 0.2,
                                            clearMemoryCacheWhenDispose: true,
                                            cache: false,
                                            fit: BoxFit.cover,
                                            loadStateChanged:
                                                (ExtendedImageState state) {
                                              if (state
                                                      .extendedImageLoadState ==
                                                  LoadState.loading) {
                                                // Custom loading progress widget
                                                return Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              if (state
                                                      .extendedImageLoadState ==
                                                  LoadState.failed) {
                                                // Print error message
                                                debugPrint(
                                                    'Failed to load image: ${state.lastException}');
                                                // Fallback widget for failed image loading
                                                return Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                                          color: Color.fromARGB(
                                                              255,
                                                              126,
                                                              106,
                                                              106),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }

                                              // Default behavior for successfully loaded images
                                              return null;
                                            },
                                          ),
                                        ),
                                      ));
                                }).toList() ??
                                [],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History
                  if ((item?.statusLogs ?? []).isNotEmpty)
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      margin: const EdgeInsets.only(bottom: 8, top: 4),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Log :',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: item?.statusLogs?.length ?? 0,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 24),
                            itemBuilder: (context, idx) {
                              final log = item!.statusLogs![idx];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline dot
                                  Column(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            size: 12, color: Colors.white),
                                      ),
                                      if (idx != item!.statusLogs!.length - 1)
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: Colors.grey[300],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Log details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              log.toStatus?.toUpperCase() ??
                                                  '-',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatDateTimeCustom(
                                                  log.createdAt,
                                                  format: 'dd MMM yyyy HH:mm'),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.note ?? '-',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.person,
                                                size: 14,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              log.user?.name ?? '-',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87),
                                            ),
                                            if (log.disposition?.toPosition
                                                    ?.name !=
                                                null) ...[
                                              const SizedBox(width: 12),
                                              Icon(Icons.arrow_forward,
                                                  size: 14,
                                                  color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                log.disposition!.toPosition!
                                                    .name!,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (log.disposition?.note != null &&
                                            log.disposition!.note!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                log.disposition!.note!,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  // item.statusLogs ->
                  // "status_logs": [
                  //     {
                  //         "id": 1,
                  //         "report_id": 1,
                  //         "user_id": 2,
                  //         "position_id": null,
                  //         "from_status": null,
                  //         "to_status": "submitted",
                  //         "note": "Report created with status Submitted",
                  //         "disposition_id": null,
                  //         "created_at": "2025-07-23T05:25:00.000000Z",
                  //         "updated_at": "2025-07-23T05:25:00.000000Z",
                  //         "user": {
                  //             "id": 2,
                  //             "name": "Andi Pratama"
                  //         },
                  //         "position": null,
                  //         "disposition": null
                  //     },
                  //     {
                  //         "id": 5,
                  //         "report_id": 1,
                  //         "user_id": 1,
                  //         "position_id": null,
                  //         "from_status": "submitted",
                  //         "to_status": "pending",
                  //         "note": "Laporan diteruskan ke Kepala Desa",
                  //         "disposition_id": 1,
                  //         "created_at": "2025-07-23T05:25:01.000000Z",
                  //         "updated_at": "2025-07-23T05:25:01.000000Z",
                  //         "user": {
                  //             "id": 1,
                  //             "name": "Superadmin"
                  //         },
                  //         "position": null,
                  //         "disposition": {
                  //             "id": 1,
                  //             "report_id": 1,
                  //             "from_position_id": null,
                  //             "to_position_id": 1,
                  //             "note": "Saya teruskan ke Kepala Desa, mohon diperhatikan.",
                  //             "created_at": "2025-07-23T05:25:01.000000Z",
                  //             "updated_at": "2025-07-23T05:25:01.000000Z",
                  //             "from_position": null,
                  //             "to_position": {
                  //                 "id": 1,
                  //                 "name": "Kepala Desa"
                  //             }
                  //         }
                  //     }
                  // ]
                  // Edit and Delete Buttons
                  /*
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Edit Button
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: MyButton(
                                  color: Theme.of(context).colorScheme.primary,
                                  verticalPadding: 0,
                                  horizontalPadding: 0,
                                  onPressed: () {
                                    // context
                                    //     .push(Destination.ReportEditPath
                                    //         .replaceAll(
                                    //             ':id', item?.id.toString() ?? ''))
                                    //     .then((result) {
                                    //   if (result == true) {
                                    //     // Reload detail data
                                    //     _fetchReviewDetail();
                  
                                    //     setState(() {
                                    //       isUpdate = true;
                                    //     });
                                    //   }
                                    // });
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text("Edit"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Delete Button
                            BlocConsumer<ReportDeleteCubit,
                                DataState<void>>(listener: (context, statedelete) {
                              if (statedelete.status == LoadStatus.deleted) {
                                dialog.showSnackBar(context,
                                    'Competitor review deleted successfully!');
                                context.pop(true);
                              } else if (statedelete.status == LoadStatus.failure) {
                                DioExceptions err = DioExceptions.fromDioError(
                                    statedelete.error!, context);
                                if (err.mappedMessage != null) {
                                  dialog.showDialogMsg(context,
                                      concatAllMappedMessage(err.mappedMessage));
                                } else {
                                  dialog.showDialogMsg(context, err.toString());
                                }
                              }
                            }, builder: (context, statedelete) {
                              return Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: MyButton(
                                    color: Theme.of(context).colorScheme.error,
                                    verticalPadding: 0,
                                    horizontalPadding: 0,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title: const Text("Confirmation"),
                                            content: const Text(
                                                "Are you sure you want to delete this review?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<
                                                          ReportDeleteCubit>()
                                                      .deleteReview("${widget.id}");
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete, size: 20),
                                        SizedBox(width: 8),
                                        Text("Delete"),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        
                          ],
                        ),
                      ),
                      */
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
