enum MediaType { image, drawing, voice, video }

class MediaFile {
  final String id;
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final int? duration;
  final Map<String, dynamic>? metadata;

  MediaFile({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.duration,
    this.metadata,
  });
}

