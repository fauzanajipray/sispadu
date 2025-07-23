import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sispadu/features/features.dart';
import 'package:sispadu/helpers/helpers.dart';
import 'package:sispadu/services/routes/app_routes.dart';
import 'package:sispadu/utils/utils.dart';
import 'package:sispadu/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PagingController<int, Report> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _controllerSearch = TextEditingController();
  String? _searchTerm = '';
  int? _selectedLabelId; // Track selected label ID
  late Timer _debounceTimer;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<ReportListBloc>().add(FetchEvent(pageKey));
    });
    context.read<ReportListBloc>().stream.listen((event) {
      if (event.status == LoadStatus.success) {
        _pagingController.value = PagingState(
            nextPageKey: event.nextPageKey,
            itemList: event.itemList,
            error: null);
      } else if (event.status == LoadStatus.failure) {
        _pagingController.error = event.error;
      }
    });
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {});
    // context.read<CompetitorLabelCubit>().getLabel(); // Fetch labels
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    _pagingController.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  void _resetSearchTerm() {
    context.read<ReportListBloc>().add(
          ResetSearchTermEvent(
            _searchTerm,
            // filters: _selectedLabelId != null
            //     ? {'label_id': _selectedLabelId.toString()}
            //     : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitor Review'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(Destination.homePath).then((result) {
            if (result is bool) {
              if (result == true) {
                context.read<ReportListBloc>().add(FetchEvent(1));
              }
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: _buildView(),
    );
  }

  Widget _buildView() {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        context.read<ReportListBloc>().add(FetchEvent(1));
        // context.read<CompetitorLabelCubit>().getLabel();
      }),
      child: BlocConsumer<ReportListBloc, DataListState<Report>>(
        listener: (context, state) {
          if (state.status == LoadStatus.reset) {
            context.read<ReportListBloc>().add(FetchEvent(1));
          }
        },
        builder: (context, state) {
          if (state.status == LoadStatus.failure) {
            return Center(child: Text('Failed to load data: ${state.error}'));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: MyTextField(
                    controller: _controllerSearch,
                    hintText: 'Search Laporan',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchTerm != ''
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchTerm = '';
                                _controllerSearch.text = '';
                              });

                              _resetSearchTerm();
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: false,
                    onChange: (value) {
                      if (_debounceTimer.isActive) {
                        _debounceTimer.cancel();
                      }
                      _debounceTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _searchTerm = value;
                        });
                        _resetSearchTerm();
                      });
                    },
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: BlocBuilder<CompetitorLabelCubit,
              //       DataState<List<SimpleData>>>(
              //     builder: (context, state) {
              //       if (state.status == LoadStatus.loading) {
              //         return const SizedBox(); // Kosongkan loading di sini
              //       }
              //       if (state.status == LoadStatus.failure) {
              //         return Center(
              //             child: Text('Failed to load labels: ${state.error}'));
              //       }
              //       final labels = state.item ?? [];
              //       int index = -1;
              //       return SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         child: Row(
              //           children: labels.map((label) {
              //             index++;
              //             return Padding(
              //               padding: (index == 0)
              //                   ? const EdgeInsets.only(left: 16, right: 4)
              //                   : (index == labels.length - 1)
              //                       ? const EdgeInsets.only(right: 16, left: 4)
              //                       : const EdgeInsets.symmetric(horizontal: 4),
              //               child: FilterChip(
              //                 label: Text(label.name ?? '-'),
              //                 selected: _selectedLabelId == label.id,
              //                 backgroundColor:
              //                     Theme.of(context).colorScheme.surface,
              //                 shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(12),
              //                 ),
              //                 onSelected: (bool selected) {
              //                   setState(() {
              //                     _selectedLabelId = selected ? label.id : null;
              //                   });
              //                   _resetSearchTerm();
              //                 },
              //               ),
              //             );
              //           }).toList(),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              MyPagedListView<Report>(
                pagingController: _pagingController,
                isSliver: true,
                itemBuilder: (context, item, index) {
                  // Gambar diatas
                  return Card(
                    color: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Colors.white,
                    elevation: 0.5,
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context
                            .push(Destination.reportDetailPath
                                .replaceAll(":id", "${item.id ?? 0}"))
                            .then((result) {
                          if (result == true) {
                            // Reload list data jika hasilnya true
                            context.read<ReportListBloc>().add(FetchEvent(1));
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User
                            Container(
                              width: double.infinity,
                              // height: 40,
                              // margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // User
                                    Text(
                                      item.user?.name ?? '-',
                                    ),
                                    // Time Created
                                    Text(
                                      formatDateTimeCustom(item.createdAt),
                                    )
                                  ]),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Divider(),
                            ),
                            if ((item.images ?? []).isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 120, // Perbesar tinggi gambar
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: ImageRect(
                                  (item.images ?? []).isNotEmpty
                                      ? item.images![0].imagePath
                                      : null,
                                  item.title,
                                  headers: {
                                    "Authorization":
                                        "Bearer ${context.read<AuthCubit>().state.token}"
                                  },
                                  fontSize: 18,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              item.title ?? '-',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.content ?? '-',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextBadge(
                              text: Text(
                                item.status ?? '-',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  // Gambar disamping
                  // return Card(
                  //   color: Theme.of(context).colorScheme.surface,
                  //   surfaceTintColor: Colors.white,
                  //   elevation: 0.5,
                  //   margin:
                  //       const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: InkWell(
                  //     borderRadius: BorderRadius.circular(12),
                  //     onTap: () {
                  //       context
                  //           .push(Destination.homePath
                  //               .replaceAll(":id", "${item.id ?? 0}"))
                  //           .then((result) {
                  //         if (result == true) {
                  //           // Reload list data jika hasilnya true
                  //           context.read<ReportListBloc>().add(FetchEvent(1));
                  //         }
                  //       });
                  //     },
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(16.0),
                  //       child: Row(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             width: 80,
                  //             height: 80,
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(8),
                  //               color: Theme.of(context).colorScheme.secondary,
                  //             ),
                  //             child: ImageRect(
                  //               (item.images ?? []).isNotEmpty
                  //                   ? item.images![0].imagePath
                  //                   : null,
                  //               item.content,
                  //               headers: {
                  //                 "Authorization":
                  //                     "Bearer ${context.read<AuthCubit>().state.token}"
                  //               },
                  //               fontSize: 18,
                  //             ),
                  //           ),
                  //           const SizedBox(width: 16),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   item.title ?? '-',
                  //                   overflow: TextOverflow.ellipsis,
                  //                   maxLines: 3,
                  //                   style: const TextStyle(
                  //                     fontSize: 14,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 8),
                  //                 Text(
                  //                   item.content ?? '-',
                  //                   overflow: TextOverflow.ellipsis,
                  //                   maxLines: 3,
                  //                   style: const TextStyle(
                  //                     fontSize: 14,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
