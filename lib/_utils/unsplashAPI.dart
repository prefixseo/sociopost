class UnsplashAPI{
  String _apikey = "client_id=TT_3UyYYOIGEs1b7JT7B_NAQo-U2SPRcRpfKT_V7r7s&orientation=squarish";
  String _listPhotos = "https://api.unsplash.com/photos";
  String _searchListPhotos = "https://api.unsplash.com/search/photos?order_by=latest&per_page=30&query=";

  String SearchPhotos(q) {
    return _searchListPhotos + q + '&' + _apikey;
  }

}