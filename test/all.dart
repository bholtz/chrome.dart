
library all_test;

import 'model_json_test.dart' as model_json_test;
import 'src_gen_test.dart' as src_gen_test;
import 'utils_test.dart' as utils_test;
import 'chrome_idl_test.dart' as test_chrome_idl;
import 'chrome_idl_files_test.dart' as test_chrome_idl_files;
import 'transformer_test.dart' as transformer_test;
import 'simple_http_client_test.dart' as simple_http_client_test;
import 'omaha_test.dart' as omaha_test;
import 'tag_matcher_test.dart' as tag_matcher_test;
import 'googlesource_test.dart' as googlesource_test;

void main() {
  model_json_test.main();
  src_gen_test.main();
  utils_test.main();
  test_chrome_idl.main();
  test_chrome_idl_files.main();
  transformer_test.defineTests();
  simple_http_client_test.defineTests();
  omaha_test.defineTests();
  tag_matcher_test.defineTests();
  googlesource_test.defineTests();
}
