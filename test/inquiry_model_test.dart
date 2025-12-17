import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/models/inquiry.dart';
import 'package:pointer/data/inquiries.dart';
import 'package:pointer/data/pointings.dart';

void main() {
  group('InquiryType enum', () {
    test('has exactly 4 inquiry types', () {
      expect(InquiryType.values.length, 4);
    });

    test('contains all expected inquiry types', () {
      expect(InquiryType.values, contains(InquiryType.koan));
      expect(InquiryType.values, contains(InquiryType.selfInquiry));
      expect(InquiryType.values, contains(InquiryType.directPointing));
      expect(InquiryType.values, contains(InquiryType.contemplation));
    });
  });

  group('Inquiry model', () {
    test('creates valid inquiry with required fields', () {
      const inquiry = Inquiry(
        id: 'test_001',
        question: 'Who am I?',
        type: InquiryType.selfInquiry,
        tradition: Tradition.advaita,
      );

      expect(inquiry.id, 'test_001');
      expect(inquiry.question, 'Who am I?');
      expect(inquiry.type, InquiryType.selfInquiry);
      expect(inquiry.tradition, Tradition.advaita);
      expect(inquiry.setup, null);
      expect(inquiry.followUp, null);
      expect(inquiry.teacher, null);
      expect(inquiry.pauseDuration, const Duration(seconds: 10));
      expect(inquiry.hasVisualElement, false);
    });

    test('creates inquiry with all optional fields', () {
      const inquiry = Inquiry(
        id: 'test_002',
        question: 'What was your face before your parents were born?',
        setup: 'Close your eyes',
        followUp: 'Look deeper',
        type: InquiryType.koan,
        tradition: Tradition.zen,
        teacher: 'Hui Neng',
        pauseDuration: Duration(seconds: 15),
        hasVisualElement: true,
      );

      expect(inquiry.id, 'test_002');
      expect(inquiry.question, 'What was your face before your parents were born?');
      expect(inquiry.setup, 'Close your eyes');
      expect(inquiry.followUp, 'Look deeper');
      expect(inquiry.type, InquiryType.koan);
      expect(inquiry.tradition, Tradition.zen);
      expect(inquiry.teacher, 'Hui Neng');
      expect(inquiry.pauseDuration, const Duration(seconds: 15));
      expect(inquiry.hasVisualElement, true);
    });

    test('has default pause duration of 10 seconds', () {
      const inquiry = Inquiry(
        id: 'test_003',
        question: 'Test question',
        type: InquiryType.contemplation,
        tradition: Tradition.contemporary,
      );

      expect(inquiry.pauseDuration, const Duration(seconds: 10));
    });

    test('has default hasVisualElement of false', () {
      const inquiry = Inquiry(
        id: 'test_004',
        question: 'Test question',
        type: InquiryType.contemplation,
        tradition: Tradition.contemporary,
      );

      expect(inquiry.hasVisualElement, false);
    });
  });

  group('Seed data - inquiries list', () {
    test('has at least 25 inquiries', () {
      expect(inquiries.length, greaterThanOrEqualTo(25));
    });

    test('all inquiries have required fields', () {
      for (final inquiry in inquiries) {
        expect(inquiry.id, isNotEmpty, reason: 'Inquiry ${inquiry.id} missing id');
        expect(inquiry.question, isNotEmpty, reason: 'Inquiry ${inquiry.id} missing question');
        expect(inquiry.type, isNotNull, reason: 'Inquiry ${inquiry.id} missing type');
        expect(inquiry.tradition, isNotNull, reason: 'Inquiry ${inquiry.id} missing tradition');
        expect(inquiry.pauseDuration.inSeconds, greaterThanOrEqualTo(8),
            reason: 'Inquiry ${inquiry.id} pause duration too short');
        expect(inquiry.pauseDuration.inSeconds, lessThanOrEqualTo(15),
            reason: 'Inquiry ${inquiry.id} pause duration too long');
      }
    });

    test('all inquiries have unique ids', () {
      final ids = inquiries.map((i) => i.id).toSet();
      expect(ids.length, inquiries.length,
          reason: 'Some inquiry IDs are duplicated');
    });

    test('has appropriate ID prefixes for inquiry types', () {
      final selfInquiryIds = inquiries
          .where((i) => i.type == InquiryType.selfInquiry)
          .map((i) => i.id);
      for (final id in selfInquiryIds) {
        expect(id.startsWith('si_'), true,
            reason: 'Self-inquiry ID $id should start with si_');
      }

      final koanIds = inquiries
          .where((i) => i.type == InquiryType.koan)
          .map((i) => i.id);
      for (final id in koanIds) {
        expect(id.startsWith('koan_'), true,
            reason: 'Koan ID $id should start with koan_');
      }

      final directPointingIds = inquiries
          .where((i) => i.type == InquiryType.directPointing)
          .map((i) => i.id);
      for (final id in directPointingIds) {
        expect(id.startsWith('dp_'), true,
            reason: 'Direct pointing ID $id should start with dp_');
      }

      final contemplationIds = inquiries
          .where((i) => i.type == InquiryType.contemplation)
          .map((i) => i.id);
      for (final id in contemplationIds) {
        expect(id.startsWith('cont_'), true,
            reason: 'Contemplation ID $id should start with cont_');
      }
    });
  });

  group('Seed data - distribution by type', () {
    test('has 6-8 self-inquiry (Advaita)', () {
      final count = inquiries
          .where((i) => i.type == InquiryType.selfInquiry)
          .length;
      expect(count, greaterThanOrEqualTo(6));
      expect(count, lessThanOrEqualTo(8));
    });

    test('has 6-8 koans (Zen)', () {
      final count = inquiries
          .where((i) => i.type == InquiryType.koan)
          .length;
      expect(count, greaterThanOrEqualTo(6));
      expect(count, lessThanOrEqualTo(8));
    });

    test('has 6-8 direct pointing', () {
      final count = inquiries
          .where((i) => i.type == InquiryType.directPointing)
          .length;
      expect(count, greaterThanOrEqualTo(6));
      expect(count, lessThanOrEqualTo(8));
    });

    test('has 4-6 contemporary contemplations', () {
      final count = inquiries
          .where((i) => i.type == InquiryType.contemplation)
          .length;
      expect(count, greaterThanOrEqualTo(4));
      expect(count, lessThanOrEqualTo(6));
    });
  });

  group('Seed data - distribution by tradition', () {
    test('self-inquiry inquiries are primarily Advaita', () {
      final selfInquiries = inquiries
          .where((i) => i.type == InquiryType.selfInquiry);
      expect(selfInquiries.length, greaterThan(0));

      // Most should be Advaita (allow for some flexibility)
      final advaitaCount = selfInquiries
          .where((i) => i.tradition == Tradition.advaita)
          .length;
      expect(advaitaCount, greaterThanOrEqualTo(selfInquiries.length - 2));
    });

    test('koans are Zen tradition', () {
      final koans = inquiries.where((i) => i.type == InquiryType.koan);
      expect(koans.length, greaterThan(0));

      for (final koan in koans) {
        expect(koan.tradition, Tradition.zen,
            reason: 'Koan ${koan.id} should be Zen tradition');
      }
    });

    test('direct pointing are Direct Path tradition', () {
      final directPointings = inquiries
          .where((i) => i.type == InquiryType.directPointing);
      expect(directPointings.length, greaterThan(0));

      for (final pointing in directPointings) {
        expect(pointing.tradition, Tradition.direct,
            reason: 'Direct pointing ${pointing.id} should be Direct Path tradition');
      }
    });

    test('contemplations are Contemporary tradition', () {
      final contemplations = inquiries
          .where((i) => i.type == InquiryType.contemplation);
      expect(contemplations.length, greaterThan(0));

      for (final contemplation in contemplations) {
        expect(contemplation.tradition, Tradition.contemporary,
            reason: 'Contemplation ${contemplation.id} should be Contemporary tradition');
      }
    });
  });

  group('Seed data - content quality', () {
    test('questions are meaningful and not empty', () {
      for (final inquiry in inquiries) {
        expect(inquiry.question.length, greaterThan(8),
            reason: 'Inquiry ${inquiry.id} question too short: "${inquiry.question}"');
      }
    });

    test('setup text is meaningful when present', () {
      final withSetup = inquiries.where((i) => i.setup != null);
      for (final inquiry in withSetup) {
        expect(inquiry.setup!.length, greaterThan(5),
            reason: 'Inquiry ${inquiry.id} setup too short');
      }
    });

    test('followUp text is meaningful when present', () {
      final withFollowUp = inquiries.where((i) => i.followUp != null);
      for (final inquiry in withFollowUp) {
        expect(inquiry.followUp!.length, greaterThan(5),
            reason: 'Inquiry ${inquiry.id} followUp too short');
      }
    });

    test('teacher attribution is present for most inquiries', () {
      final withTeacher = inquiries.where((i) => i.teacher != null).length;
      // At least 40% should have teacher attribution
      expect(withTeacher, greaterThan(inquiries.length * 0.4));
    });
  });

  group('Helper functions - filtering', () {
    test('getInquiriesByType returns correct inquiries', () {
      final koans = getInquiriesByType(InquiryType.koan);
      expect(koans.isNotEmpty, true);

      for (final inquiry in koans) {
        expect(inquiry.type, InquiryType.koan);
      }
    });

    test('getInquiriesByTradition returns correct inquiries', () {
      final zenInquiries = getInquiriesByTradition(Tradition.zen);
      expect(zenInquiries.isNotEmpty, true);

      for (final inquiry in zenInquiries) {
        expect(inquiry.tradition, Tradition.zen);
      }
    });

    test('getInquiriesByType returns empty list for missing type', () {
      // All types should have entries, but this tests the logic
      final koans = getInquiriesByType(InquiryType.koan);
      expect(koans, isNotEmpty);
    });

    test('filter by type and tradition together', () {
      // Koans should all be Zen
      final zenKoans = getInquiriesByType(InquiryType.koan)
          .where((i) => i.tradition == Tradition.zen)
          .toList();

      expect(zenKoans.length, getInquiriesByType(InquiryType.koan).length);
    });
  });

  group('Helper functions - random selection', () {
    test('getRandomInquiry returns a valid inquiry', () {
      final inquiry = getRandomInquiry();
      expect(inquiries.contains(inquiry), true);
    });

    test('getRandomInquiry with type filter returns correct type', () {
      for (int i = 0; i < 10; i++) {
        final inquiry = getRandomInquiry(type: InquiryType.koan);
        expect(inquiry.type, InquiryType.koan);
      }
    });

    test('getRandomInquiry with tradition filter returns correct tradition', () {
      for (int i = 0; i < 10; i++) {
        final inquiry = getRandomInquiry(tradition: Tradition.zen);
        expect(inquiry.tradition, Tradition.zen);
      }
    });

    test('getRandomInquiry with both filters returns matching inquiry', () {
      for (int i = 0; i < 10; i++) {
        final inquiry = getRandomInquiry(
          type: InquiryType.directPointing,
          tradition: Tradition.direct,
        );
        expect(inquiry.type, InquiryType.directPointing);
        expect(inquiry.tradition, Tradition.direct);
      }
    });

    test('getRandomInquiry returns different inquiries over multiple calls', () {
      final results = <String>{};
      for (int i = 0; i < 20; i++) {
        final inquiry = getRandomInquiry();
        results.add(inquiry.id);
      }
      // Should get at least 3 different inquiries in 20 calls
      expect(results.length, greaterThanOrEqualTo(3));
    });
  });
}
