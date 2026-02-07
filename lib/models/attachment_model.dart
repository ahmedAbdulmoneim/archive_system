class AttachmentModel {
  final String name;      // اسم الملف
  final String type;      // pdf / image / doc ...
  final String? url;      // رابط التخزين (ممكن فاضي الآن)
  final String? localPath; // مسار محلي مؤقت (لو انت بتختار ملف بدون رفع)

  const AttachmentModel({
    required this.name,
    required this.type,
    this.url,
    this.localPath,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      name: (map['name'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      url: map['url']?.toString(),
      localPath: map['localPath']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'localPath': localPath,
    };
  }
}
