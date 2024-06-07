# 🎨 Random Color Palette Generator in Flutter

A small project proposed by [DevProjects](https://www.codementor.io/projects) for beginners in Flutter. The project details and requirements are available in the provided link.

As suggested, I utilized the [ColorMind API](http://colormind.io/api-access/), a free REST API, to fetch color palettes.

To enhance the project, I added a few extra challenges. One of these was enabling users to save a generated palette. To achieve this, I used [Shared Preferences](https://pub.dev/packages/shared_preferences) to store the palette data, which can then be accessed on another page titled 'Your Palettes'.

Additionaly, I integrated [Flutter Toast](https://pub.dev/packages/fluttertoast) to display useful notifications throughout the app.

## References

- [Flutter Docs](https://docs.flutter.dev/)
  - [Shared Preferences](https://docs.flutter.dev/cookbook/persistence/key-value)
  - [JSON Serialization](https://docs.flutter.dev/data-and-backend/serialization/json)
  - [Fetching Data](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [MaterialUI](https://docs.flutter.dev/ui/widgets/material)
- [Flutter Toast](https://pub.dev/packages/fluttertoast)

## Screenshots

![Generator](https://imgur.com/a/i472Qf9)
![Your Palettes](https://imgur.com/a/sqDEILQ)
