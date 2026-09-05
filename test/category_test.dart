import 'package:delmess/features/classification/domain/message_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category and Visual Language Tests', () {
    test(
      'All 5 core categories have distinct names, descriptions, and icons',
      () {
        const categories = CategoryType.values;
        expect(categories.length, equals(5));

        final names = categories.map((c) => c.displayName).toSet();
        expect(names.length, equals(5));

        final icons = categories.map((c) => c.icon).toSet();
        expect(icons.length, equals(5));

        expect(categories.contains(CategoryType.transactional), isTrue);
        expect(categories.contains(CategoryType.service), isTrue);
        expect(categories.contains(CategoryType.promotional), isTrue);
        expect(categories.contains(CategoryType.government), isTrue);
        expect(categories.contains(CategoryType.other), isTrue);
      },
    );

    test(
      'Category string parsing handles exact and case-insensitive matches',
      () {
        expect(
          CategoryTypeExtension.fromString('transactional'),
          equals(CategoryType.transactional),
        );
        expect(
          CategoryTypeExtension.fromString('SERVICE'),
          equals(CategoryType.service),
        );
        expect(
          CategoryTypeExtension.fromString('Promotional'),
          equals(CategoryType.promotional),
        );
        expect(
          CategoryTypeExtension.fromString('government'),
          equals(CategoryType.government),
        );
        expect(
          CategoryTypeExtension.fromString('other'),
          equals(CategoryType.other),
        );
        expect(
          CategoryTypeExtension.fromString('unknown_value'),
          equals(CategoryType.other),
        );
        expect(
          CategoryTypeExtension.fromString(null),
          equals(CategoryType.other),
        );
      },
    );
  });
}
