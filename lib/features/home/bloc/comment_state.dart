part of 'comment_cubit.dart';

class CommentState extends Equatable {
  final List<Comment> comments;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const CommentState({
    required this.comments,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  factory CommentState.initial() => const CommentState(
        comments: [],
        isLoading: false,
        hasMore: false,
        error: null,
      );

  CommentState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [comments, isLoading, hasMore, error];
}
