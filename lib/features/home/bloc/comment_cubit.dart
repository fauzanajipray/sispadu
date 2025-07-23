import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sispadu/features/features.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  final ReportRepository repository;
  final String reportId;

  int _page = 1;
  bool _hasMore = true;

  CommentCubit(this.repository, this.reportId) : super(CommentState.initial());

  Future<void> fetchComments({bool loadMore = false}) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (!loadMore) {
        _page = 1;
        _hasMore = true;
      }
      final comments = await repository.fetchComments(reportId, page: _page);
      emit(state.copyWith(
        comments: loadMore ? [...state.comments, ...comments] : comments,
        hasMore: comments.length >= 5,
        isLoading: false,
      ));
      if (comments.length >= 5) _page++;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addComment(String content) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.addComment(reportId, content);
      await fetchComments();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> editComment(Comment comment, String content) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.editComment(reportId, comment.id!, content);
      await fetchComments();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteComment(Comment comment) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.deleteComment(reportId, comment.id!);
      await fetchComments();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
