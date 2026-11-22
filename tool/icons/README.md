# Quran listening icon font

This package's icons come from one font, `assets/fonts/MawaqitIcons.ttf`, used in code as `Icon(MawaqitIcons.name)`.
It holds only the icons this package needs, drawn the same as in the MAWAQIT app (mobile-app `tool/icons`); copy a
drawing from there when you need another one, so both stay identical.
Don't add icons as SVG/PNG image files, and don't edit the font or `lib/src/utils/helpers/mawaqit_icons_icons.dart` by hand: both are
generated from this folder.

- `svg/`: one drawing per icon (`svg/close.svg` is `MawaqitIcons.close`).
- `icons.json`: each icon's code, size, vertical position and right-to-left mirroring. Codes never change and are
  never reused, so existing code keeps working.
- `icon_editor.html`: the editor. It builds the font and the Dart class in the browser; nothing to install.

## Add or change an icon

1. Open `tool/icons/icon_editor.html` in **Edge or Chrome** (double-click it), click **Open project folder** and choose the
   root of the `quran_listening` repository. The browser then asks twice whether the page may view and save files in that
   folder: choose **Allow** both times. Next time, use **Reopen last project** (the browser asks once more after it
   has been closed).
2. **Add:** drop an SVG on the page. The file name becomes the name in code (`Prayer Mat.svg` → `prayer_mat`); you can
   change it before saving.
   **Replace:** drop the new SVG on the icon's tile, or select it and use **Replace drawing**. The name and code stay.
3. Check the previews (16, 24 and 48 px, light and dark). Use **Size** if it looks too big or small next to the
   others, and tick **Mirror** for arrows that should flip in Arabic and Urdu.
4. Click **Save to project**, then commit the files it lists (the SVG, `icons.json`, the font and the Dart class).
5. Fully restart the app (hot reload does not reload fonts).

**Remove** retires the icon's code for good; any code still using it stops compiling until it is changed.

## Drawings

- Solid, single colour, filled shapes. Outline strokes and convert text to shapes before exporting; embedded
  images are ignored.
- Square-ish artwork works best; the editor centres it and scales it to the size you choose.
- New icons follow the MAWAQIT style (bold, rounded, no outlines, no decorative stars) and are approved in the
  MAWAQIT design system first.

Other browsers can open the editor too, but download the changed files instead of saving them in place.
