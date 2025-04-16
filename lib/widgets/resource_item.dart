import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceItem extends StatelessWidget {
  final Map<String, dynamic> resource;

  const ResourceItem({
    Key? key,
    required this.resource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconData icon =
        _getIconForResourceType(resource['type'] as String? ?? 'article');
    final String? resourceUrl = resource['url'] as String?;
    final bool isValidUrl = _isValidUrl(resourceUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (!isValidUrl) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resourceUrl == null
                    ? 'No URL provided for this resource'
                    : 'Invalid or placeholder URL: $resourceUrl'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          try {
            // Open in browser
            await launchUrl(Uri.parse(resourceUrl!),
                mode: LaunchMode.externalApplication);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Could not open URL: $resourceUrl\nError: ${e.toString()}'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isValidUrl
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'] ?? 'Untitled Resource',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isValidUrl
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    if (isValidUrl && resourceUrl != null)
                      Text(
                        _formatUrlForDisplay(resourceUrl),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
              ),
              if (isValidUrl)
                const Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: Color(0xFF4F46E5),
                )
              else
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.video_library_outlined;
      case 'book':
        return Icons.book_outlined;
      case 'course':
        return Icons.school_outlined;
      case 'tool':
        return Icons.build_outlined;
      case 'article':
      default:
        return Icons.article_outlined;
    }
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final List<String> placeholderDomains = [
      'example.com',
      'example.org',
      'example.net',
      'domain.com',
      'yourwebsite.com',
      'placeholder.com'
    ];

    for (final domain in placeholderDomains) {
      if (url.contains(domain)) return false;
    }

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  String _formatUrlForDisplay(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path.length > 1 ? (uri.path.length > 20 ? '${uri.path.substring(0, 20)}...' : uri.path) : ''}';
    } catch (e) {
      return url;
    }
  }
}
