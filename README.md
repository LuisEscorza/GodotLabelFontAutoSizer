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

## Installation
- If you're using Godot 4.0 or 4.1 read the last paragraph [here](https://github.com/LuisEscorza/GodotLabelFontAutoSizer/releases/tag/v1.0.0_godot_4.2).
- Download the latest [release](https://github.com/LuisEscorza/GodotLabelFontAutoSizer/releases) for your Godot engine version and drop the contents inside the root folder of your project or download and import the addon from the [Asset Library](https://godotengine.org/asset-library/).
- Go to `Project` -> `Project Settings` -> `Plugins` and enable LabelFontAutoSizer.

## How to use
1. **Create an auto sizer `Label` or `RichTextLabel`:** from the `Create New Node` menu directly. Just search for `Label` and you will find the new versions under the normal `Label` and `RichTextLabel` nodes respectively.
   - If you want to use your already created labels, just `Right Click` them -> `Change Type...` and choose the version with the auto sizer. Or just drag the appropiate script from the addons folder if you find that more comfortable.
2. **Set your font and size normally.** The fonts won't grow over the size you set.
   - Like with normal `Label` nodes, there is a priority for which font and size is the active one; `Label Settings Resource` _(not present in `RichTextLabel`)_ -> `Theme Overrides` -> `Theme`. If you don't set any, the default font will be used, with its 16px size.
3. **Set the rest of the size values:** in the inspector dock, on top, you'll find two groups of properties. Open `Size values` and set `Max Steps`(maximum of iterations the font will try to shrink to fit inside the `Label Rect`) and `Size per Step`(How many pixels will the font shrink each step).
4. **You're set!** Now the font will be resized every time it's necessary after changing the `Text`(via `my_label.text = value` or `my_label.set_text(value)`, or after resizing the `Rect` of the label, both in the editor or at runtime.

After this, you can change your font size manually at any moment and it will become the new base size.

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
