import 'package:flutter_test/flutter_test.dart';
import 'package:image_gallery/main.dart';

void main() {
  testWidgets('Image Gallery App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ImageGalleryApp());

    // Verify that the app title is displayed.
    expect(find.text('Image Gallery'), findsOneWidget);
  });
}
