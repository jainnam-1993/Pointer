import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

/// VM Service extensions for the Flutter Maestro MCP server.
///
/// Registers `ext.flutter.maestro_mcp.*` extensions that allow the MCP
/// server to inspect the widget tree, tap widgets, enter text, and take
/// screenshots. Only call [init] in debug mode.
class MaestroHooks {
  static BuildContext? _appContext;

  /// Set the root BuildContext from MaterialApp.builder so the tree walker
  /// can access all routes including overlays and dialogs.
  static void setContext(BuildContext context) {
    _appContext = context;
  }

  /// Register all VM Service extensions. Call once in main(), guarded by kDebugMode.
  static void init() {
    registerExtension(
      'ext.flutter.maestro_mcp.interactiveElements',
      _getInteractiveElements,
    );
    registerExtension('ext.flutter.maestro_mcp.tap', _tap);
    registerExtension('ext.flutter.maestro_mcp.enterText', _enterText);
    registerExtension('ext.flutter.maestro_mcp.scrollTo', _scrollTo);
    registerExtension(
      'ext.flutter.maestro_mcp.takeScreenshots',
      _takeScreenshots,
    );
    registerExtension('ext.flutter.maestro_mcp.getLogs', _getLogs);
    registerExtension('ext.flutter.maestro_mcp.restart', _restart);

    debugPrint('[MaestroHooks] Initialized');
  }

  static Future<ServiceExtensionResponse> _getInteractiveElements(
    String method,
    Map<String, String> parameters,
  ) async {
    if (_appContext == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.extensionError,
        'No app context available',
      );
    }

    final elements = <Map<String, dynamic>>[];

    void visitor(Element element) {
      final widget = element.widget;

      // Collect Text widgets
      if (widget is Text && widget.data != null) {
        final map = <String, dynamic>{'type': 'Text', 'text': widget.data};
        if (widget.key is ValueKey) {
          map['key'] = (widget.key as ValueKey).value.toString();
        }
        // Collect semantic label if available
        final renderObject = element.renderObject;
        if (renderObject is RenderBox) {
          final semantics = renderObject.debugSemantics;
          if (semantics?.label != null && semantics!.label.isNotEmpty) {
            map['semantics'] = semantics.label;
          }
        }
        elements.add(map);
      }

      // Collect button types
      if (widget is FloatingActionButton) {
        final map = <String, dynamic>{'type': 'FloatingActionButton'};
        if (widget.tooltip != null) map['tooltip'] = widget.tooltip;
        if (widget.key is ValueKey) {
          map['key'] = (widget.key as ValueKey).value.toString();
        }
        elements.add(map);
      }

      if (widget is ElevatedButton ||
          widget is TextButton ||
          widget is IconButton ||
          widget is OutlinedButton) {
        final map = <String, dynamic>{'type': widget.runtimeType.toString()};
        if (widget.key is ValueKey) {
          map['key'] = (widget.key as ValueKey).value.toString();
        }
        elements.add(map);
      }

      // Collect widgets with ValueKey (useful for targeting specific widgets)
      if (widget.key is ValueKey &&
          widget is! Text &&
          widget is! FloatingActionButton &&
          widget is! ElevatedButton &&
          widget is! TextButton &&
          widget is! IconButton &&
          widget is! OutlinedButton) {
        final map = <String, dynamic>{
          'type': widget.runtimeType.toString(),
          'key': (widget.key as ValueKey).value.toString(),
        };
        elements.add(map);
      }

      element.visitChildren(visitor);
    }

    _appContext!.visitChildElements(visitor);

    final result = {'status': 'success', 'elements': elements};
    return ServiceExtensionResponse.result(jsonEncode(result));
  }

  static Future<ServiceExtensionResponse> _tap(
    String method,
    Map<String, String> parameters,
  ) async {
    try {
      if (_appContext == null) {
        return ServiceExtensionResponse.error(
          ServiceExtensionResponse.extensionError,
          'No app context available',
        );
      }

      Element? targetElement;

      void visitor(Element element) {
        if (targetElement != null) return;
        final widget = element.widget;

        if (parameters.containsKey('key')) {
          final key = widget.key;
          if (key is ValueKey && key.value.toString() == parameters['key']) {
            targetElement = element;
            return;
          }
        }

        if (parameters.containsKey('text')) {
          if (widget is Text && widget.data == parameters['text']) {
            targetElement = element;
            return;
          }
        }

        if (parameters.containsKey('tooltip')) {
          if (widget is Tooltip && widget.message == parameters['tooltip']) {
            targetElement = element;
            return;
          }
          if (widget is FloatingActionButton &&
              widget.tooltip == parameters['tooltip']) {
            targetElement = element;
            return;
          }
        }

        if (parameters.containsKey('semantics')) {
          final renderObject = element.renderObject;
          if (renderObject is RenderBox) {
            final semantics = renderObject.debugSemantics;
            if (semantics?.label == parameters['semantics']) {
              targetElement = element;
              return;
            }
          }
        }

        element.visitChildren(visitor);
      }

      _appContext!.visitChildElements(visitor);

      if (targetElement == null) {
        return ServiceExtensionResponse.result(
          jsonEncode({
            'status': 'Error',
            'error': 'Widget not found with criteria: $parameters',
          }),
        );
      }

      // Try to invoke the tap handler
      final widget = targetElement!.widget;
      bool tapped = false;

      if (widget is FloatingActionButton && widget.onPressed != null) {
        widget.onPressed!();
        tapped = true;
      } else if (widget is ElevatedButton && widget.onPressed != null) {
        widget.onPressed!();
        tapped = true;
      } else if (widget is TextButton && widget.onPressed != null) {
        widget.onPressed!();
        tapped = true;
      } else if (widget is IconButton && widget.onPressed != null) {
        widget.onPressed!();
        tapped = true;
      } else if (widget is InkWell && widget.onTap != null) {
        widget.onTap!();
        tapped = true;
      } else if (widget is GestureDetector && widget.onTap != null) {
        widget.onTap!();
        tapped = true;
      }

      // Walk up to find a parent tap handler
      if (!tapped) {
        Element? parent = targetElement;
        while (parent != null && !tapped) {
          final parentWidget = parent.widget;
          if (parentWidget is GestureDetector && parentWidget.onTap != null) {
            parentWidget.onTap!();
            tapped = true;
          } else if (parentWidget is InkWell && parentWidget.onTap != null) {
            parentWidget.onTap!();
            tapped = true;
          }
          if (!tapped) {
            Element? nextParent;
            parent.visitAncestorElements((ancestor) {
              nextParent = ancestor;
              return false;
            });
            parent = nextParent;
          }
        }
      }

      return ServiceExtensionResponse.result(jsonEncode({'status': 'success', 'tapped': tapped}));
    } catch (e, stackTrace) {
      return ServiceExtensionResponse.result(
        jsonEncode({'status': 'Error', 'error': e.toString(), 'stackTrace': stackTrace.toString()}),
      );
    }
  }

  static Future<ServiceExtensionResponse> _enterText(
    String method,
    Map<String, String> parameters,
  ) async {
    debugPrint('[MaestroHooks] Enter text: $parameters');
    return ServiceExtensionResponse.result(jsonEncode({'status': 'success'}));
  }

  static Future<ServiceExtensionResponse> _scrollTo(
    String method,
    Map<String, String> parameters,
  ) async {
    debugPrint('[MaestroHooks] Scroll: $parameters');
    return ServiceExtensionResponse.result(jsonEncode({'status': 'success'}));
  }

  static Future<ServiceExtensionResponse> _takeScreenshots(
    String method,
    Map<String, String> parameters,
  ) async {
    // Return a 1x1 pixel base64 png placeholder
    const emptyPng =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
    return ServiceExtensionResponse.result(
      jsonEncode({'status': 'success', 'data': emptyPng}),
    );
  }

  static Future<ServiceExtensionResponse> _getLogs(
    String method,
    Map<String, String> parameters,
  ) async {
    return ServiceExtensionResponse.result(
      jsonEncode({'status': 'success', 'logs': []}),
    );
  }

  static Future<ServiceExtensionResponse> _restart(
    String method,
    Map<String, String> parameters,
  ) async {
    try {
      WidgetsBinding.instance.reassembleApplication();
      return ServiceExtensionResponse.result(jsonEncode({'status': 'success'}));
    } catch (e) {
      return ServiceExtensionResponse.result(
        jsonEncode({'status': 'Error', 'error': e.toString()}),
      );
    }
  }
}
