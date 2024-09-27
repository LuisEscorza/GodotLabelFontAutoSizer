<h1 align="center">
   Godot Label Font Auto Sizer
  <img src="https://github.com/LuisEscorza/GodotLabelFontAutoSizer/blob/main/media/icon.png"/>
</h1>

<h4 align="center">
  A Godot tool that adds new Label/RichTextLabels nodes with autosizing capabilities; meaning, the text will try to fit inside the rect by making itself smaller.
</a></h4>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#localization">Localization</a> •
  <a href="#support">Support</a> •
  <a href="#license">License</a>
  
</p>

<p align="center">
  <img src="https://github.com/LuisEscorza/GodotLabelFontAutoSizer/blob/main/media/preview.gif?raw=true"/>
</p>

#### *Disclaimer: Text with different font sizes when not intended usually look bad, so I'd advise using this addon pretty much as a last resort. Before using this addon you should probably try adding more space for your text, using abbreviated words, or adding a scrol bar.*

## Installation
- If you're using Godot 4.0 or 4.1 read the last paragraph [here](https://github.com/LuisEscorza/GodotLabelFontAutoSizer/releases/tag/v1.0.0_godot_4.2). This addon works with Godot 4.2 onwards.
- Download the latest [release](https://github.com/LuisEscorza/GodotLabelFontAutoSizer/releases) for your Godot engine version and drop the contents inside the root folder of your project or download and import the addon from the [Asset Library](https://godotengine.org/asset-library/).
- Go to `Project` -> `Project Settings` -> `Plugins` and enable LabelFontAutoSizer.

## How to use
1. **Create an `AutoSize` `Label` or `RichTextLabel`:** from the `Create New Node` menu directly. Just search for `AutoSize` and you will find the new versions under the normal `Label` and `RichTextLabel` nodes respectively (pick the one without the script file name in the parenthesis).
2. **Set your font sizes.** You can set a `min_size` and `max_size`. Doesn't matter what Theme (or Theme Overrides) or Label Settings you're using, the font size will be set by the max and min sizes.
3. **You're set!** Now the font will be resized every time it's necessary.

_If you want to trigger a size check on a label at any given time, you can do so with `my_label._check_line_count()`, although there shouldn’t be a reason for it._

_If you're doing some testing/developing, if you are changing the text from withit one of the label classes themselves, do it like `self.set_text(value)` or `self.text = value`, othersise it doesn't trigger a size check. In a real scenario you wouldn't be changing the text from within the class itself though._

### Usage differences in Godot 3
- The tool works pretty much the same. The one difference is that in Godot 3, if you don’t use any font other than the default one, you'll get an error message asking to use a `DynamicFont`, because `BitMapFont` cannot be resized. After you set a `DynamicFont` you can use the label normally and the text will resize correctly.

## Localization
This was the reason I made the tool. Sometimes after translating text, you just can't make the rect any larger and some languages generally take more space than others (e.g. french), so this tool can help in those cases.
To help with those issues, [assuming you already know how the localisation system works in Godot](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html), I added a simple class that you can use after changing the locale of the game.
- After you change your locale, for example to Spanish, by using `TranslationServer.set_locale("es")`, you can call `LabelFontAutoSizeManager.locale_chaged()` and this will trigger a size check on every active label.

This way it doesn’t matter wether you update the texts directly using `my_label.text = tr(message)` or rely on the auto translation of the `Label` node itself (only in Godot 4), you'll be covered.

## Support
You wish to support me? Feel free to follow me on any of the public links on my [profile](https://github.com/LuisEscorza)!

## License
[MIT](https://github.com/LuisEscorza/GodotLabelFontAutoSizer/blob/main/LICENSE)
