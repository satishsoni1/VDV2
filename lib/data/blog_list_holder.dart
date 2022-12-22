import 'package:blog_app/models/blog_category.dart';

class BlogListHolder {
  Blog _list = Blog();
  int _index = 0;

  int getIndex() => _index;
  Blog getList() => _list;

  void setIndex(int index) {
    this._index = index;
  }

  void setList(Blog list) {
    this._list = list;
  }

  void clearList() {
    this._list = Blog();
  }
}

BlogListHolder blogListHolder = new BlogListHolder();
