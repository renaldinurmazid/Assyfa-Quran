import 'package:get/get.dart';
import 'package:quran_app/screen/blog/blog_comment_controller.dart';

class BlogCommentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogCommentController>(() => BlogCommentController());
  }
}
