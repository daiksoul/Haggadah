import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../custom_selectable_text.dart';

class CustomTextSelectionControls extends MaterialTextSelectionControls {
  // Padding between the toolbar and the anchor.
  static const double _kToolbarContentDistanceBelow = 20.0;
  static const double _kToolbarContentDistance = 8.0;

  CustomTextSelectionControls({
    required this.items,
  });

  final List<CustomSelectableTextItem> items;

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset selectionMidpoint,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            _kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return MyTextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus,
      items: items,
      selectionStart: delegate.textEditingValue.selection.start,
      selectionEnd: delegate.textEditingValue.selection.end,
      handleCopy: () => handleCopy(delegate),
      handleCut: () => handleCut(delegate),
      handlePaste: () => handlePaste(delegate),
      handleSelectAll: () => handleSelectAll(delegate),
      callback: () {
        delegate.userUpdateTextEditingValue(
            delegate.textEditingValue.copyWith(
                selection: TextSelection.collapsed(
                    offset: delegate.textEditingValue.selection.baseOffset)),
            SelectionChangedCause.doubleTap);

        delegate.hideToolbar();
      },
    );
  }
}

/// A toolbar containing the given [items].
class MyTextSelectionToolbar extends StatefulWidget {
  const MyTextSelectionToolbar({
    Key? key,
    required this.anchorAbove,
    required this.anchorBelow,
    this.clipboardStatus,
    this.handleCopy,
    this.handleCut,
    this.handlePaste,
    this.handleSelectAll,
    required this.items,
    // required this.selectionText,
    required this.selectionStart,
    required this.selectionEnd,
    required this.callback,
  }) : super(key: key);

  final Offset anchorAbove;
  final Offset anchorBelow;
  final ValueListenable<ClipboardStatus>? clipboardStatus;
  final void Function()? handleCopy;
  final void Function()? handleCut;
  final void Function()? handlePaste;
  final void Function()? handleSelectAll;
  final List<CustomSelectableTextItem> items;
  // final String selectionText;
  final int selectionStart;
  final int selectionEnd;
  final void Function()? callback;

  @override
  MyTextSelectionToolbarState createState() => MyTextSelectionToolbarState();
}

class MyTextSelectionToolbarState extends State<MyTextSelectionToolbar> {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
    // widget.clipboardStatus
  }

  @override
  void didUpdateWidget(MyTextSelectionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
    }
    // widget.clipboardStatus?.update();
  }

  @override
  void dispose() {
    super.dispose();
    widget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    Map<SelectionControlType, void Function()?> selectorItem = {
      SelectionControlType.copy: widget.handleCopy,
      SelectionControlType.cut: widget.handleCut,
      SelectionControlType.paste: widget.handlePaste,
      SelectionControlType.selectAll: widget.handleSelectAll,
      SelectionControlType.other: widget.callback,
    };

    Map<SelectionControlType, String> selectorLabel = {
      SelectionControlType.copy: localizations.copyButtonLabel,
      SelectionControlType.cut: localizations.cutButtonLabel,
      SelectionControlType.paste: localizations.pasteButtonLabel,
      SelectionControlType.selectAll: localizations.selectAllButtonLabel,
    };

    return TextSelectionToolbar(
      anchorAbove: widget.anchorAbove,
      anchorBelow: widget.anchorBelow,
      toolbarBuilder: (BuildContext context, Widget child) {
        return Card(child: child);
      },
      children: [
        for (var i = 0; i < widget.items.length; i++)
          TextSelectionToolbarTextButton(
            padding: TextSelectionToolbarTextButton.getPadding(
                i, widget.items.length),
            onPressed: () {
              if (widget.items[i].onPressed != null) {
                widget.items[i].onPressed!(widget.selectionStart, widget.selectionEnd);
              }
              if (selectorItem[widget.items[i].controlType] != null) {
                selectorItem[widget.items[i].controlType]!();
              }
            },
            child: _child(
                popupMenuButton: widget.items[i].popupMenuButton,
                icon: widget.items[i].icon,
                text: Text(widget.items[i].label ??
                    selectorLabel[widget.items[i].controlType] ??
                    "")),
          ),
      ],
    );
  }

  Widget _child(
      {required Widget? popupMenuButton,
      required Widget? icon,
      required Widget text}) {
    if (popupMenuButton != null) {
      return popupMenuButton;
    } else if (icon != null) {
      return icon;
    }
    return text;
  }
}
