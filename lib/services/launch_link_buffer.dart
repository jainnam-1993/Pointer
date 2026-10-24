/**
 * Holds the one deep link (widget tap, notification tap) that should open a
 * pointing, until startup content is ready to show it.
 *
 * Every producer goes through [offer], which also tries to deliver. Before
 * this, the iOS cold-start widget URI was stored without a delivery attempt;
 * when it resolved after the startup drain had already run, nothing drained it
 * again and Home kept the stored pointing instead of the one the widget showed.
 */
class LaunchLinkBuffer {
  LaunchLinkBuffer({required bool Function() isReady, required void Function(Uri uri) deliver}) : _isReady = isReady, _deliver = deliver;

  final bool Function() _isReady;
  final void Function(Uri uri) _deliver;
  String? _pending;

  /** The buffered link, if any (for tests and logging). */
  String? get pending => _pending;

  /** Buffer [link] (newest wins) and deliver it now if startup is ready. */
  void offer(String link) {
    _pending = link;
    drain();
  }

  /** Deliver the buffered link once startup is ready; a no-op otherwise. */
  void drain() {
    final link = _pending;
    if (link == null || !_isReady()) return;
    _pending = null;
    final uri = Uri.tryParse(link);
    if (uri != null) _deliver(uri);
  }
}
