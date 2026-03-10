import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/values/colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  final String? audioPath;
  final dynamic provider;

  const AudioPlayerWidget({super.key, this.audioUrl, this.audioPath, required this.provider});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isSeeking = false;
  bool _audioLoadError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      if (mounted) {
        setState(() {
          _isPlaying = playing;
          if (state.processingState == ProcessingState.completed) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      } else {
        Log.e(' Audio Player: Context not mounted (playerStateStream)');
      }
    });
    _audioPlayer.durationStream.listen((d) {
      if (mounted) {
        setState(() => _duration = d ?? Duration.zero);
      } else {
        Log.e(' Audio Player: Context not mounted (durationStream)');
      }
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted && !_isSeeking) {
        setState(() => _position = p);
      } else {
        Log.e(' Audio Player: Context not mounted (positionStream)');
      }
    });
    if (widget.audioUrl != null) {
      _audioPlayer.setUrl(widget.audioUrl!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio);
      });
    }
    if (widget.audioPath != null) {
      _audioPlayer.setFilePath(widget.audioPath!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio file: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio_file);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration d) {
    twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_audioLoadError && widget.audioUrl != null) {
      final strings = Helper.getLocalization()!;
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(strings.media_unavailable, style: const TextStyle(color: MColors.red, fontSize: 14), textAlign: TextAlign.center),
      );
    }
    final fileName = widget.audioPath != null ? widget.audioPath!.split('/').last : widget.audioUrl!.split('/').last;
    return Card(
      color: MColors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: MColors.primaryGreen, size: 25),
                  onPressed: () => GlobalTap.safeTap(_togglePlayPause),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      activeColor: MColors.primaryGreen,
                      thumbColor: MColors.primaryGreen,
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _position = Duration(milliseconds: value.round());
                            _isSeeking = true;
                          });
                        } else {
                          Log.e(' Audio Player Widget: Context not mounted (Slider onChanged)');
                        }
                      },
                      onChangeEnd: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.round()));
                        if (mounted) {
                          setState(() => _isSeeking = false);
                        } else {
                          Log.e(' Audio Player Widget: Context not mounted (Slider onChangeEnd)');
                        }
                      },
                    ),
                  ),
                ),
                Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}', style: Theme.of(context).textTheme.bodyMedium),
                if (widget.audioPath != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: MColors.red, size: 25),
                    onPressed: () => GlobalTap.safeTap(() {
                      widget.provider.deleteRecording(widget.audioPath!);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AudioPlayerWithTitleWidget extends StatefulWidget {
  final String? audioUrl;
  final String? audioPath;
  final String title;
  final String timestamp;
  final dynamic provider;

  const AudioPlayerWithTitleWidget({super.key, this.audioUrl, this.audioPath, required this.title, required this.timestamp, required this.provider});

  @override
  State<AudioPlayerWithTitleWidget> createState() => _AudioPlayerWithTitleWidgetState();
}

class _AudioPlayerWithTitleWidgetState extends State<AudioPlayerWithTitleWidget> {
  late final AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isSeeking = false;
  bool _audioLoadError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      if (mounted) {
        setState(() {
          _isPlaying = playing;
          if (state.processingState == ProcessingState.completed) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      } else {
        Log.e(' Audio Player With Title: Context not mounted (playerStateStream)');
      }
    });
    _audioPlayer.durationStream.listen((d) {
      if (mounted) {
        setState(() => _duration = d ?? Duration.zero);
      } else {
        Log.e(' Audio Player With Title: Context not mounted (durationStream)');
      }
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted && !_isSeeking) {
        setState(() => _position = p);
      } else {
        Log.e(' Audio Player With Title: Context not mounted (positionStream)');
      }
    });
    if (widget.audioUrl != null) {
      _audioPlayer.setUrl(widget.audioUrl!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio);
      });
    }
    if (widget.audioPath != null) {
      _audioPlayer.setFilePath(widget.audioPath!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio file: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio_file);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration d) {
    twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_audioLoadError && widget.audioUrl != null) {
      final strings = Helper.getLocalization()!;
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(strings.media_unavailable, style: const TextStyle(color: MColors.red, fontSize: 14), textAlign: TextAlign.center),
      );
    }
    return Card(
      color: MColors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              widget.timestamp,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: MColors.primaryGreen, size: 25),
                  onPressed: () => GlobalTap.safeTap(_togglePlayPause),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      activeColor: MColors.primaryGreen,
                      thumbColor: MColors.primaryGreen,
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _position = Duration(milliseconds: value.round());
                            _isSeeking = true;
                          });
                        } else {
                          Log.e(' Audio Player With Title: Context not mounted (Slider onChanged)');
                        }
                      },
                      onChangeEnd: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.round()));
                        if (mounted) {
                          setState(() => _isSeeking = false);
                        } else {
                          Log.e(' Audio Player With Title: Context not mounted (Slider onChangeEnd)');
                        }
                      },
                    ),
                  ),
                ),
                Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}', style: Theme.of(context).textTheme.bodyMedium),
                if (widget.audioPath != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: MColors.red, size: 25),
                    onPressed: () => GlobalTap.safeTap(() {
                      widget.provider.deleteRecording(widget.audioPath!);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CenteredAudioWaveAnimation extends StatefulWidget {
  const CenteredAudioWaveAnimation({super.key});

  @override
  State<CenteredAudioWaveAnimation> createState() => _CenteredAudioWaveAnimationState();
}

class _CenteredAudioWaveAnimationState extends State<CenteredAudioWaveAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(double value, int index) {
    final delay = index * 0.2;
    final animValue = (value + delay) % 1.0;
    return 8 + (16 * (0.5 + 0.5 * math.sin(animValue * 2 * math.pi)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // total space to grow up and down
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final height = _barHeight(value, index);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(width: 4, height: height, decoration: BoxDecoration(color: MColors.red, borderRadius: BorderRadius.circular(2))),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
