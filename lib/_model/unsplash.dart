class Unsplash {
  String smallUrl;
  String thumb;

  Unsplash(
    {
      this.smallUrl,
      this.thumb
    }
  );

  factory Unsplash.fromJson(Map<String, dynamic> json) => Unsplash(
    smallUrl: json["urls"]["small"],
    thumb: json["urls"]["thumb"],
  );
}
