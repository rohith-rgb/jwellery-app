// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class PhotoUploadWidget extends StatefulWidget {
  final String bucket; // 'jewelry-photos' or 'customer-photos'
  final String? existingUrl; // show existing photo if any
  final void Function(String url) onUploaded;
  final double size;
  final IconData placeholder;
  final String label;

  const PhotoUploadWidget({
    super.key,
    required this.bucket,
    required this.onUploaded,
    this.existingUrl,
    this.size = 100,
    this.placeholder = Icons.add_a_photo_outlined,
    this.label = 'Add Photo',
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  bool _uploading = false;
  String? _uploadedUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.existingUrl;
  }

  String get _displayUrl => _uploadedUrl ?? widget.existingUrl ?? '';

  Future<void> _pickAndUpload() async {
    setState(() {
      _error = null;
    });

    // Open file picker — images only
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return;

    final file = input.files!.first;

    // Check size — max 5MB
    if (file.size > 5 * 1024 * 1024) {
      setState(() => _error = 'Image too large. Max 5MB.');
      return;
    }

    setState(() => _uploading = true);

    try {
      // Read file as bytes
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      final bytes = Uint8List.fromList((reader.result as List<int>));

      // Generate unique filename
      final ext = file.name.split('.').last.toLowerCase();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';

      // Upload to Supabase Storage
      final supabase = Supabase.instance.client;
      await supabase.storage.from(widget.bucket).uploadBinary(
            filename,
            bytes,
            fileOptions: FileOptions(
              contentType: file.type,
              upsert: true,
            ),
          );

      // Get public URL
      final url = supabase.storage.from(widget.bucket).getPublicUrl(filename);

      setState(() {
        _uploadedUrl = url;
        _uploading = false;
      });

      widget.onUploaded(url);
    } catch (e) {
      setState(() {
        _error = 'Upload failed. Check storage bucket settings.';
        _uploading = false;
      });
    }
  }

  void _removePhoto() {
    setState(() => _uploadedUrl = null);
    widget.onUploaded('');
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _displayUrl.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _uploading ? null : _pickAndUpload,
          child: Stack(
            children: [
              // Photo container
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color:
                      hasPhoto ? Colors.transparent : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(widget.size * 0.15),
                  border: Border.all(
                    color: hasPhoto
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.divider,
                    width: hasPhoto ? 2 : 1,
                  ),
                ),
                child: _uploading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 6),
                            const Text('Uploading...',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : hasPhoto
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(widget.size * 0.14),
                            child: Image.network(
                              _displayUrl,
                              width: widget.size,
                              height: widget.size,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: widget.size * 0.35,
                                  color: AppTheme.textHint,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.placeholder,
                                  size: widget.size * 0.35,
                                  color: AppTheme.textHint,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                      fontSize: 10, color: AppTheme.textHint),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
              ),

              // Edit badge (shows when photo exists)
              if (hasPhoto && !_uploading)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
        ),

        // Remove button
        if (hasPhoto && !_uploading) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _removePhoto,
            child: const Text('Remove',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.error,
                    decoration: TextDecoration.underline)),
          ),
        ],

        // Error message
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!,
              style: const TextStyle(fontSize: 10, color: AppTheme.error),
              textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

// ── Multi-photo upload (for jewelry — up to 4 photos) ─────────
class MultiPhotoUpload extends StatefulWidget {
  final String bucket;
  final List<String> existingUrls;
  final void Function(List<String> urls) onChanged;
  final int maxPhotos;

  const MultiPhotoUpload({
    super.key,
    required this.bucket,
    required this.onChanged,
    this.existingUrls = const [],
    this.maxPhotos = 4,
  });

  @override
  State<MultiPhotoUpload> createState() => _MultiPhotoUploadState();
}

class _MultiPhotoUploadState extends State<MultiPhotoUpload> {
  late List<String> _urls;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _urls = List.from(widget.existingUrls);
  }

  Future<void> _addPhoto() async {
    if (_urls.length >= widget.maxPhotos) return;
    setState(() {
      _error = null;
    });

    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return;

    final file = input.files!.first;
    if (file.size > 5 * 1024 * 1024) {
      setState(() => _error = 'Image too large. Max 5MB.');
      return;
    }

    setState(() => _uploading = true);

    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      final bytes = Uint8List.fromList((reader.result as List<int>));

      final ext = file.name.split('.').last.toLowerCase();
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${_urls.length}.$ext';

      final supabase = Supabase.instance.client;
      await supabase.storage.from(widget.bucket).uploadBinary(filename, bytes,
          fileOptions: FileOptions(contentType: file.type, upsert: true));

      final url = supabase.storage.from(widget.bucket).getPublicUrl(filename);

      setState(() {
        _urls.add(url);
        _uploading = false;
      });
      widget.onChanged(List.from(_urls));
    } catch (e) {
      setState(() {
        _error = 'Upload failed';
        _uploading = false;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => _urls.removeAt(index));
    widget.onChanged(List.from(_urls));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Existing photos
            ..._urls.asMap().entries.map((e) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        e.value,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.surfaceVariant,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppTheme.textHint),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removePhoto(e.key),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                )),

            // Add photo button
            if (_urls.length < widget.maxPhotos)
              GestureDetector(
                onTap: _uploading ? null : _addPhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.divider, style: BorderStyle.solid),
                  ),
                  child: _uploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppTheme.textHint, size: 26),
                            SizedBox(height: 4),
                            Text('Add Photo',
                                style: TextStyle(
                                    fontSize: 9, color: AppTheme.textHint)),
                          ],
                        ),
                ),
              ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!,
              style: const TextStyle(fontSize: 11, color: AppTheme.error)),
        ],
        const SizedBox(height: 4),
        Text(
          '${_urls.length}/${widget.maxPhotos} photos added',
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
