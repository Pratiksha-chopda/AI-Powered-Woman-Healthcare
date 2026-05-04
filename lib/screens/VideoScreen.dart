import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatefulWidget {
  final String title;
  final String videoUrl; // raw URL from Firestore
  final String description;

  const VideoScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.description,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController? _controller;
  String? _videoId;
  String? _error;

  @override
  void initState() {
    super.initState();

    final normalizedUrl = _normalizeYouTubeUrl(widget.videoUrl);
    debugPrint('RAW Firestore URL => "${widget.videoUrl}"');
    debugPrint('NORMALIZED URL   => "$normalizedUrl"');

    _videoId = YoutubePlayer.convertUrlToId(normalizedUrl);
    debugPrint('EXTRACTED videoId => $_videoId');

    if (_videoId == null || _videoId!.isEmpty) {
      _error = 'Invalid YouTube URL';
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // FIXED: handle youtu.be links with extra params
  String _normalizeYouTubeUrl(String raw) {
    String url = raw.trim();
    if (url.isEmpty) return '';

    // If only ID is stored
    final onlyIdReg = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (onlyIdReg.hasMatch(url)) {
      return 'https://www.youtube.com/watch?v=$url';
    }

    // youtu.be short link: https://youtu.be/ID?anything
    if (url.contains('youtu.be/')) {
      final afterHost = url.split('youtu.be/').last;
      final id = afterHost.split('?').first; // remove ?si=...
      return 'https://www.youtube.com/watch?v=$id';
    }

    // shorts format
    if (url.contains('/shorts/')) {
      final parts = url.split('/shorts/');
      if (parts.length > 1) {
        final id = parts[1].split('?').first;
        return 'https://www.youtube.com/watch?v=$id';
      }
    }

    // m.youtube.com → www.youtube.com
    url = url.replaceFirst('m.youtube.com', 'www.youtube.com');
    return url;
  }

  Future<void> _launchYouTubeVideo() async {
    final Uri url = Uri.parse(_normalizeYouTubeUrl(widget.videoUrl));
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_error != null)
              Container(
                height: 200,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_controller == null)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.redAccent,
                  onReady: () => debugPrint('YouTube player ready'),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _launchYouTubeVideo,
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open in YouTube"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}