import 'package:pink_acg/app/util/pink_constants.dart';
import 'package:pink_net/request/pink_base_request.dart';

import 'base_request.dart';

class CategoryRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.GET;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return "${PinkConstants.versionPath}/categoryList";
  }
}
