import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    Key key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    TextInputType keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = true,
    this.maxLengthEnforced = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
  })  : assert(textAlign != null),
        assert(autofocus != null),
        assert(obscureText != null),
        assert(autocorrect != null),
        assert(maxLengthEnforced != null),
        assert(scrollPadding != null),
        assert(maxLines == null || maxLines > 0),
        assert(maxLength == null || maxLength > 0),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        super(key: key);

  final TextEditingController controller;

  final FocusNode focusNode;

  final InputDecoration decoration;

  final TextInputType keyboardType;

  final TextInputAction textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle style;

  final TextAlign textAlign;

  final bool autofocus;

  final bool obscureText;

  final bool autocorrect;

  final int maxLines;

  final int maxLength;
  final bool showCounter;

  final bool maxLengthEnforced;

  final ValueChanged<String> onChanged;

  final VoidCallback onEditingComplete;

  final ValueChanged<String> onSubmitted;

  final List<TextInputFormatter> inputFormatters;

  final bool enabled;

  final double cursorWidth;

  final Radius cursorRadius;

  final Color cursorColor;

  final Brightness keyboardAppearance;

  final EdgeInsets scrollPadding;

  @override
  _MyTextFieldState createState() => new _MyTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DiagnosticsProperty<TextEditingController>(
        'controller', controller,
        defaultValue: null));
    properties.add(new DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
    properties.add(
        new DiagnosticsProperty<InputDecoration>('decoration', decoration));
    properties.add(new DiagnosticsProperty<TextInputType>(
        'keyboardType', keyboardType,
        defaultValue: TextInputType.text));
    properties.add(
        new DiagnosticsProperty<TextStyle>('style', style, defaultValue: null));
    properties.add(new DiagnosticsProperty<bool>('autofocus', autofocus,
        defaultValue: false));
    properties.add(new DiagnosticsProperty<bool>('obscureText', obscureText,
        defaultValue: false));
    properties.add(new DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: false));
    properties.add(new IntProperty('maxLines', maxLines, defaultValue: 1));
    properties.add(new IntProperty('maxLength', maxLength, defaultValue: null));
    properties.add(new FlagProperty('maxLengthEnforced',
        value: maxLengthEnforced, ifTrue: 'max length enforced'));
  }
}

class _MyTextFieldState extends State<MyTextField>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<EditableTextState> _editableTextKey =
      new GlobalKey<EditableTextState>();

  Set<InteractiveInkFeature> _splashes;
  InteractiveInkFeature _currentSplash;

  TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  FocusNode _focusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= new FocusNode());

  bool get needsCounter => widget.showCounter
      ? widget.maxLength != null &&
          widget.decoration != null &&
          widget.decoration.counterText == null
      : false;

  InputDecoration _getEffectiveDecoration() {
    final InputDecoration effectiveDecoration =
        (widget.decoration ?? const InputDecoration())
            .applyDefaults(Theme.of(context).inputDecorationTheme)
            .copyWith(
              enabled: widget.enabled,
            );

    if (!needsCounter) return effectiveDecoration;

    final String counterText =
        '${_effectiveController.value.text.runes.length}/${widget.maxLength}';
    if (_effectiveController.value.text.runes.length > widget.maxLength) {
      final ThemeData themeData = Theme.of(context);
      return effectiveDecoration.copyWith(
        errorText: effectiveDecoration.errorText ?? '',
        counterStyle: effectiveDecoration.errorStyle ??
            themeData.textTheme.caption.copyWith(color: themeData.errorColor),
        counterText: counterText,
      );
    }
    return effectiveDecoration.copyWith(counterText: counterText);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _controller = new TextEditingController();
  }

  @override
  void didUpdateWidget(MyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null)
      _controller =
          new TextEditingController.fromValue(oldWidget.controller.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _controller = null;
    final bool isEnabled = widget.enabled ?? widget.decoration?.enabled ?? true;
    final bool wasEnabled =
        oldWidget.enabled ?? oldWidget.decoration?.enabled ?? true;
    if (wasEnabled && !isEnabled) {
      _effectiveFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  void _requestKeyboard() {
    _editableTextKey.currentState?.requestKeyboard();
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    if (cause == SelectionChangedCause.longPress)
      Feedback.forLongPress(context);
  }

  InteractiveInkFeature _createInkFeature(TapDownDetails details) {
    final MaterialInkController inkController = Material.of(context);
    final BuildContext editableContext = _editableTextKey.currentContext;
    final RenderBox referenceBox =
        InputDecorator.containerOf(editableContext) ??
            editableContext.findRenderObject();
    final Offset position = referenceBox.globalToLocal(details.globalPosition);
    final Color color = Theme.of(context).splashColor;

    InteractiveInkFeature splash;
    void handleRemoved() {
      if (_splashes != null) {
        assert(_splashes.contains(splash));
        _splashes.remove(splash);
        if (_currentSplash == splash) _currentSplash = null;
        updateKeepAlive();
      }
    }

    splash = Theme.of(context).splashFactory.create(
          textDirection: TextDirection.ltr,
          controller: inkController,
          referenceBox: referenceBox,
          position: position,
          color: color,
          containedInkWell: true,
          borderRadius: BorderRadius.zero,
          onRemoved: handleRemoved,
        );

    return splash;
  }

  RenderEditable get _renderEditable =>
      _editableTextKey.currentState.renderEditable;

  void _handleTapDown(TapDownDetails details) {
    _renderEditable.handleTapDown(details);
    _startSplash(details);
  }

  void _handleTap() {
    _renderEditable.handleTap();
    _requestKeyboard();
    _confirmCurrentSplash();
  }

  void _handleTapCancel() {
    _cancelCurrentSplash();
  }

  void _handleLongPress() {
    _renderEditable.handleLongPress();
    _confirmCurrentSplash();
  }

  void _startSplash(TapDownDetails details) {
    if (_effectiveFocusNode.hasFocus) return;
    final InteractiveInkFeature splash = _createInkFeature(details);
    _splashes ??= new HashSet<InteractiveInkFeature>();
    _splashes.add(splash);
    _currentSplash = splash;
    updateKeepAlive();
  }

  void _confirmCurrentSplash() {
    _currentSplash?.confirm();
    _currentSplash = null;
  }

  void _cancelCurrentSplash() {
    _currentSplash?.cancel();
  }

  @override
  bool get wantKeepAlive => _splashes != null && _splashes.isNotEmpty;

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes;
      _splashes = null;
      for (InteractiveInkFeature splash in splashes) splash.dispose();
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = widget.style ?? themeData.textTheme.subhead;
    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? themeData.primaryColorBrightness;
    final TextEditingController controller = _effectiveController;
    final FocusNode focusNode = _effectiveFocusNode;
    final List<TextInputFormatter> formatters =
        widget.inputFormatters ?? <TextInputFormatter>[];
    if (widget.maxLength != null && widget.maxLengthEnforced)
      formatters.add(new LengthLimitingTextInputFormatter(widget.maxLength));

    Widget child = new RepaintBoundary(
      child: new EditableText(
        key: _editableTextKey,
        controller: controller,
        focusNode: focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: style,
        textAlign: widget.textAlign,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        maxLines: widget.maxLines,
        selectionColor: themeData.textSelectionColor,
        selectionControls: themeData.platform == TargetPlatform.iOS
            ? cupertinoTextSelectionControls
            : materialTextSelectionControls,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        onSelectionChanged: _handleSelectionChanged,
        inputFormatters: formatters,
        rendererIgnoresPointer: true,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor ?? Theme.of(context).cursorColor,
        scrollPadding: widget.scrollPadding,
        keyboardAppearance: keyboardAppearance,
      ),
    );

    if (widget.decoration != null) {
      child = new AnimatedBuilder(
        animation: new Listenable.merge(<Listenable>[focusNode, controller]),
        builder: (BuildContext context, Widget child) {
          return new InputDecorator(
            decoration: _getEffectiveDecoration(),
            baseStyle: widget.style,
            textAlign: widget.textAlign,
            isFocused: focusNode.hasFocus,
            isEmpty: controller.value.text.isEmpty,
            child: child,
          );
        },
        child: child,
      );
    }

    return new Semantics(
      onTap: () {
        if (!_effectiveController.selection.isValid)
          _effectiveController.selection = new TextSelection.collapsed(
              offset: _effectiveController.text.length);
        _requestKeyboard();
      },
      child: new IgnorePointer(
        ignoring: !(widget.enabled ?? widget.decoration?.enabled ?? true),
        child: new GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: _handleTapDown,
          onTap: _handleTap,
          onTapCancel: _handleTapCancel,
          onLongPress: _handleLongPress,
          excludeFromSemantics: true,
          child: child,
        ),
      ),
    );
  }
}
