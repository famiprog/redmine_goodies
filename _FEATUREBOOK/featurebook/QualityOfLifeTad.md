# Featurebook > QualityOfLifeTad.md
Go to [Featurebook > Index](FEATUREBOOK.md)

## TOC

* [`@Scenario` `feature_repositionSubmenuOfContextMenu()`](#feature_repositionSubmenuOfContextMenu)
* [`@Scenario` `feature_overrideMaxHeightOfSubmenu()`](#feature_overrideMaxHeightOfSubmenu)
* [`@Scenario` `feature_defaultValuesForSettings()`](#feature_defaultValuesForSettings)
* [`@Scenario` `feature_warningPrivateNotes()`](#feature_warningPrivateNotes)

## Scenarios

<a id="feature_repositionSubmenuOfContextMenu"></a>
<table>
<tr><td> 

`@Scenario` `feature_repositionSubmenuOfContextMenu()`<br />
</td></tr>
<tr><td>

Sometimes, with the context menu open, when opening a sub-menu: the "child" sub menu is too high and exits the screen. Hence we have some JS code that works around this issue by repositioning the popup.

Before:

![image1.png](../featurebook-img/QualityOfLifeTad/feature_repositionSubmenuOfContextMenu/image1.png)

After:

![image2.png](../featurebook-img/QualityOfLifeTad/feature_repositionSubmenuOfContextMenu/image2.png)

Settings:

![settings.png](../featurebook-img/QualityOfLifeTad/feature_repositionSubmenuOfContextMenu/settings.png)
</td></tr>
</table>

<a id="feature_overrideMaxHeightOfSubmenu"></a>
<table>
<tr><td> 

`@Scenario` `feature_overrideMaxHeightOfSubmenu()`<br />
</td></tr>
<tr><td>

When there are several actions in the sub-menu, at some point the max-height is reached and a scroll bar appears. The Redmine default is about 300px, which means about 15 lines.

![image1.png](../featurebook-img/QualityOfLifeTad/feature_overrideMaxHeightOfSubmenu/image1.png)

Although general, this was meant for `Quick edit field`. This is something that needs to be "quick". And if there are quite a few fields, some on 2 lines => a scroll bar may appear. Which would make the "quick" ... less quick 🙂.

Settings:

![image2.png](../featurebook-img/QualityOfLifeTad/feature_overrideMaxHeightOfSubmenu/image2.png)

</td></tr>
</table>

<a id="feature_defaultValuesForSettings"></a>
<table>
<tr><td> 

`@Scenario` `feature_defaultValuesForSettings()`<br />
</td></tr>
<tr><td>

The defaults work like this: if no settings in DB OR settings exists in DB but no explicit value for a particular setting =>
the default is applied. 

This is for the use case: an user has already our plugin. He/she updates to a new version of plugin => defaults are applied
automatically.
</td></tr>
</table>

<a id="feature_warningPrivateNotes"></a>
<table>
<tr><td> 

`@Scenario` `feature_warningPrivateNotes()`<br />
</td></tr>
<tr><td>

When adding a private note, it's not obvious at all that pasted images ARE NOT private. Hence we are adding a warning message about this.

Let's display this message: `WARNING: any attachments (including copy/pasted images) ARE NOT private!`. Highlighted in yellow. Appears only when `Private` checkbox
is checked.

![image.png](../featurebook-img/QualityOfLifeTad/feature_warningPrivateNotes/image.png)
</td></tr>
</table>
