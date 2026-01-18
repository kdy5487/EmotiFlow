import '../../domain/entities/media_file.dart';

class MediaFileModel extends MediaFile {
  MediaFileModel({
    required super.id,
    required super.url,
    required super.type,
    super.thumbnailUrl,
    super.duration,
    super.metadata,
  });

  factory MediaFileModel.fromMap(Map<String, dynamic> map) {
    return MediaFileModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${map['type']}',
        orElse: () => MediaType.image,
      ),
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'type': type.toString().split('.').last,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'metadata': metadata,
    };
  }
}
