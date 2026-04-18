import 'job_listing.dart';

class JobSearchResponse {
  final int total;
  final int page;
  final int size;
  final List<JobListing> items;

  const JobSearchResponse({
    required this.total,
    required this.page,
    required this.size,
    required this.items,
  });

  bool get hasNextPage => page * size < total;

  factory JobSearchResponse.fromJson(Map<String, dynamic> json) =>
      JobSearchResponse(
        total: (json['total'] as num).toInt(),
        page: json['page'] as int,
        size: json['size'] as int,
        items: (json['items'] as List)
            .map((e) => JobListing.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
