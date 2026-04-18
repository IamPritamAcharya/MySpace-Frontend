class JobListing {
  final String id;
  final String? title;
  final String? company;
  final String? location;
  final String? description;
  final String? redirectUrl;
  final String? createdAt;
  final String? contractType;
  final String? contractTime;
  final double? salaryMin;
  final double? salaryMax;
  final bool salaryPredicted;
  final double? latitude;
  final double? longitude;
  final String? category;
  final String? categoryTag;
  final String source;
  final String? searchProfile;
  final String? searchedWhat;
  final String? searchedWhere;
  final String fetchedAt;
  final List<String> tags;

  const JobListing({
    required this.id,
    this.title,
    this.company,
    this.location,
    this.description,
    this.redirectUrl,
    this.createdAt,
    this.contractType,
    this.contractTime,
    this.salaryMin,
    this.salaryMax,
    this.salaryPredicted = false,
    this.latitude,
    this.longitude,
    this.category,
    this.categoryTag,
    required this.source,
    this.searchProfile,
    this.searchedWhat,
    this.searchedWhere,
    required this.fetchedAt,
    this.tags = const [],
  });

  factory JobListing.fromJson(Map<String, dynamic> json) => JobListing(
        id: json['id'] as String,
        title: json['title'] as String?,
        company: json['company'] as String?,
        location: json['location'] as String?,
        description: json['description'] as String?,
        redirectUrl: json['redirectUrl'] as String?,
        createdAt: json['createdAt'] as String?,
        contractType: json['contractType'] as String?,
        contractTime: json['contractTime'] as String?,
        salaryMin: (json['salaryMin'] as num?)?.toDouble(),
        salaryMax: (json['salaryMax'] as num?)?.toDouble(),
        salaryPredicted: json['salaryPredicted'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        category: json['category'] as String?,
        categoryTag: json['categoryTag'] as String?,
        source: json['source'] as String,
        searchProfile: json['searchProfile'] as String?,
        searchedWhat: json['searchedWhat'] as String?,
        searchedWhere: json['searchedWhere'] as String?,
        fetchedAt: json['fetchedAt'] as String,
        tags: List<String>.from(json['tags'] ?? []),
      );

  /// Returns a formatted salary range string, or null if unavailable.
  String? get salaryRange {
    if (salaryMin == null && salaryMax == null) return null;
    final suffix = salaryPredicted ? ' (estimated)' : '';
    if (salaryMin != null && salaryMax != null) {
      return '₹${_fmt(salaryMin!)} – ₹${_fmt(salaryMax!)}$suffix';
    }
    if (salaryMin != null) return '₹${_fmt(salaryMin!)}+$suffix';
    return 'Up to ₹${_fmt(salaryMax!)}$suffix';
  }

  /// Returns a human-readable contract label (e.g. "Full Time · Permanent").
  String? get contractLabel {
    final parts = <String>[];
    if (contractTime != null) {
      parts.add(contractTime!.replaceAll('_', ' ').capitalize());
    }
    if (contractType != null) {
      parts.add(contractType!.capitalize());
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// How long ago the job was posted.
  String get postedAgo {
    final posted = DateTime.tryParse(createdAt ?? '');
    if (posted == null) return 'Recently';
    final diff = DateTime.now().difference(posted);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  String _fmt(double v) =>
      v >= 100000 ? '${(v / 100000).toStringAsFixed(1)}L' : v.toStringAsFixed(0);
}

extension _StringCap on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
