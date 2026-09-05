/// Entity representing sender/header intelligence data.
class SenderMetadata {
  final String id;
  final String header;
  final String brand;
  final String organization;
  final String industry;
  final int metadataVersion;
  final DateTime updatedAt;

  const SenderMetadata({
    required this.id,
    required this.header,
    required this.brand,
    required this.organization,
    required this.industry,
    this.metadataVersion = 1,
    required this.updatedAt,
  });

  SenderMetadata copyWith({
    String? id,
    String? header,
    String? brand,
    String? organization,
    String? industry,
    int? metadataVersion,
    DateTime? updatedAt,
  }) {
    return SenderMetadata(
      id: id ?? this.id,
      header: header ?? this.header,
      brand: brand ?? this.brand,
      organization: organization ?? this.organization,
      industry: industry ?? this.industry,
      metadataVersion: metadataVersion ?? this.metadataVersion,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
