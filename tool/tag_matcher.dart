library tag_matcher;

class TagMatcher implements Pattern {
  static const tagString = 'TAG';
  static const tagTemplate = '<$tagString([^>]*)?>(.*?)</$tagString>';
  final _attributeMatcher = new RegExp('([^ ]*?)=\"(.*?)\"');
  final String _tagName;
  final RegExp _regExp;

  static final anyTag = new TagMatcher('.*?');
  static final olMatcher = new TagMatcher('ol');
  static final liMatcher = new TagMatcher('li');
  static final aMatcher = new TagMatcher('a');
  static final spanMatcher = new TagMatcher('span');

  TagMatcher(String tagName)
      : _tagName = tagName,
        _regExp = new RegExp(tagTemplate.replaceAll(tagString, tagName));

  @override
  Match matchAsPrefix(String string, [int start = 0]) =>
      _regExp.matchAsPrefix(string, start);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) =>
      _regExp.allMatches(string, start);

  Iterable<Map<String, String>> allAttributes(String string, [int start = 0]) {
    var attributesList = [];
    _regExp.allMatches(string, start).forEach((match) {
      var allAttributes = match.group(1);
      attributesList.add(_makeAttributesMap(allAttributes));
    });
    return attributesList;
  }

  /// Given a string of html or other markup, find all of the contents of the
  /// matching tags. For example, given the html '<div>foo</div><div>bar</div>',
  /// calling this on a [TagMatcher] matching the div tag should return
  /// ['foo','bar'].
  Iterable<String> allContents(String string, [int start = 0]) =>
      _regExp.allMatches(string, start).map((match) => match.group(2));

  Map<String, String> _makeAttributesMap(String allAttributes) =>
      new Map.fromIterable(_attributeMatcher.allMatches(allAttributes),
          key: (match) => match.group(1), value: (match) => match.group(2));
}
