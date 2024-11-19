import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.maxLines,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const String _ellipsis = "\u2026\u0020";
  bool _isExpanded = false;
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      };
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: widget.text,
          style: Theme.of(context).textTheme.bodyMedium,
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines || _isExpanded) {
          return Text(widget.text);
        }

        final pos = _getPositionForEllipsis(textPainter, constraints.maxWidth);
        if (pos == -1) {
          return Text(widget.text);
        }

        final truncatedText = widget.text.substring(0, pos);
        return RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: truncatedText),
              TextSpan(text: _ellipsis),
              TextSpan(
                text: 'Read more',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: _tapRecognizer,
              ),
            ],
          ),
        );
      },
    );
  }

  int _getPositionForEllipsis(TextPainter textPainter, double maxWidth) {
    int low = 0;
    int high = widget.text.length;
    int lastGood = -1;

    while (low <= high) {
      final int mid = (low + high) ~/ 2;

      final textSpan = TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        text: widget.text.substring(0, mid) + _ellipsis + 'Read more',
      );

      final painter = TextPainter(
        text: textSpan,
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      );

      painter.layout(maxWidth: maxWidth);

      if (painter.didExceedMaxLines) {
        high = mid - 1;
      } else {
        lastGood = mid;
        low = mid + 1;
      }
    }

    return lastGood;
  }
}
