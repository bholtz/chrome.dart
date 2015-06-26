import '../tool/tag_matcher.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('TagMatcher', () {
    TagMatcher matcher;
    var testString = 'Some untagged <span>This is some text in a span </span>'
        '<a href="path/to/foo">foo link</a> <span>and back to span </span>';

    test('matches tag contents correctly', () {
      matcher = TagMatcher.spanMatcher;
      var allContents = matcher.allContents(testString);

      expect(allContents.length, 2);
      expect(allContents.first, 'This is some text in a span ');
      expect(allContents.last, 'and back to span ');
    });

    test('matches tag contents with attributes', () {
      matcher = TagMatcher.aMatcher;
      var allContents = matcher.allContents(testString);

      expect(allContents.length, 1);
      expect(allContents.first, 'foo link');
    });

    test('matches attributes correctly', () {
      matcher = TagMatcher.anyTag;
      var allAttributes = matcher.allAttributes(testString);

      expect(allAttributes.length, 3);
      expect(allAttributes.first.isEmpty, true);
      expect(allAttributes.last.isEmpty, true);

      var attributes = allAttributes.elementAt(1);

      expect(attributes.length, 1);
      expect(attributes['href'], 'path/to/foo');
    });

    group('matching attributes', () {
      test('complicated test', () {
        var lotsOfAttributes = '<li color="blue"></li><li color="black"></li>'
            '<li size="big"    type="dog" color="red"></li>';
        matcher = TagMatcher.liMatcher;

        var allAttributes = matcher.allAttributes(lotsOfAttributes).toList();

        expect(allAttributes[0].length, 1);
        expect(allAttributes[0]['color'], 'blue');

        expect(allAttributes[1].length, 1);
        expect(allAttributes[1]['color'], 'black');

        var cliffordAttributes = allAttributes[2];
        expect(cliffordAttributes.length, 3);
        expect(cliffordAttributes['size'], 'big');
        expect(cliffordAttributes['type'], 'dog');
        expect(cliffordAttributes['color'], 'red');
      });
    });
  });
}
