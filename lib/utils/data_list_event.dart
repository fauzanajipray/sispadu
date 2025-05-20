abstract class DataListingEvent {}

class FetchEvent extends DataListingEvent {
  final int pageKey;
  FetchEvent(this.pageKey);
}

class ResetSearchTermEvent extends DataListingEvent {
  final String? search;
  final Map<String, String>? filters;
  ResetSearchTermEvent(this.search, {this.filters});
}

class ResetPage extends DataListingEvent {}
