import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/launch_link_buffer.dart';

void main() {
  late bool ready;
  late List<Uri> delivered;
  late LaunchLinkBuffer buffer;

  setUp(() {
    ready = false;
    delivered = [];
    buffer = LaunchLinkBuffer(isReady: () => ready, deliver: delivered.add);
  });

  test('a link offered before startup is ready is delivered at the startup drain', () {
    buffer.offer('dailypointer://pointing/ori-308');
    expect(delivered, isEmpty);
    ready = true;
    buffer.drain();
    expect(delivered.single.pathSegments.single, 'ori-308');
  });

  test('a cold-start link that resolves after the startup drain is still delivered', () {
    // iOS: HomeWidget.initiallyLaunchedFromHomeWidget() can complete after
    // criticalContentReady has already drained an empty buffer.
    ready = true;
    buffer.drain();
    buffer.offer('dailypointer://pointing/ori-308');
    expect(delivered.single.toString(), 'dailypointer://pointing/ori-308');
    expect(buffer.pending, isNull);
  });

  test('the newest link wins and is delivered once', () {
    buffer.offer('dailypointer://pointing/a');
    buffer.offer('dailypointer://pointing/b');
    ready = true;
    buffer.drain();
    buffer.drain();
    expect(delivered.map((u) => u.pathSegments.single), ['b']);
  });
}
