import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'empty_data.dart';
import 'error_data.dart';

class MyPagedGridView<T> extends StatelessWidget {
  const MyPagedGridView({
    super.key,
    required this.pagingController,
    required this.itemBuilder,
    this.isSliver = false,
    this.isMoreDataAvailable = false,
    this.notFound,
    this.firstLoading,
    this.totalColumn = 2,
  });

  final PagingController<int, T> pagingController;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool isSliver;
  final Widget Function(BuildContext context)? notFound;
  final Widget Function(BuildContext context)? firstLoading;
  final bool isMoreDataAvailable;
  final int totalColumn;

  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return PagedSliverGrid<int, T>(
        pagingController: pagingController,
        gridDelegate: gridDelegate(),
        builderDelegate: builderDelegate(),
      );
    }
    return PagedGridView<int, T>(
      pagingController: pagingController,
      gridDelegate: gridDelegate(),
      builderDelegate: builderDelegate(),
    );
  }

  SliverGridDelegate gridDelegate() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      childAspectRatio: 100 / 120,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      crossAxisCount: totalColumn,
    );
  }

  PagedChildBuilderDelegate<T> builderDelegate() {
    return PagedChildBuilderDelegate<T>(
      animateTransitions: true,
      itemBuilder: itemBuilder,
      noItemsFoundIndicatorBuilder: notFound ?? emptyData,
      noMoreItemsIndicatorBuilder: (context) {
        return (isMoreDataAvailable)
            ? const Center(
                child: Text('No More Data'),
              )
            : const SizedBox(height: 24);
      },
      firstPageProgressIndicatorBuilder: firstLoading,
      firstPageErrorIndicatorBuilder: (context) {
        return Center(
          child: errorData(
            context,
            pagingController.error,
            onRetry: () => pagingController.retryLastFailedRequest(),
          ),
        );
      },
    );
  }
}
