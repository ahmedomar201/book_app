import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookListItem extends StatefulWidget {
  final String title;
  final List<String> authors;
  final String? summary;
  final String? coverImageUrl;

  const BookListItem({
    super.key,
    required this.title,
    required this.authors,
    this.summary,
    this.coverImageUrl,
  });

  @override
  State<BookListItem> createState() => _BookListItemState();
}

class _BookListItemState extends State<BookListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCoverImage(),
                const SizedBox(width: 12),
                Expanded(child: buildBookInfo()),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.summary != null && widget.summary!.isNotEmpty)
              buildSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget buildCoverImage() {
    return widget.coverImageUrl != null
        ? ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: widget.coverImageUrl!,
            width: 80,
            height: 120,
            fit: BoxFit.cover,
            // Uses built‑in disk/memory cache; shows graceful fallbacks offline/failed.
            placeholder: (_, __) => placeholderImage(isLoading: true),
            errorWidget: (_, __, ___) => placeholderImage(),
          ),
        )
        : placeholderImage();
  }

  Widget placeholderImage({bool isLoading = false}) {
    return Container(
      width: 80,
      height: 120,
      color: Colors.grey[200],
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.book, size: 40),
    );
  }

  Widget buildBookInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.authors.join(', '),
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.summary ?? '',
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isExpanded ? 'See Less' : 'See More',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
