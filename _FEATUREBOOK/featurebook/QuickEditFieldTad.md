# Featurebook > QuickEditFieldTad.md
Go to [Featurebook > Index](FEATUREBOOK.md)

## TOC

* [`@Scenario` `_quickInstructions()`](#_quickInstructions)
* [`@Scenario` `feature_settings()`](#feature_settings)
* [`@Scenario` `feature_permissions()`](#feature_permissions)

## Scenarios

<a id="_quickInstructions"></a>
<table>
<tr><td> 

`@Scenario` `_quickInstructions()`<br />
</td></tr>
<tr><td>

Redmine offers quick field edit only for fields of type many-to-one (e.g. `Status`, `Tracker`, etc.). This
feature extends the quick edit flow to "normal" fields.

The context menu (right click) of an issue has this:

![context-menu.png](../featurebook-img/QuickEditFieldTad/_quickInstructions/context-menu.png)

And then:

![popup.png](../featurebook-img/QuickEditFieldTad/_quickInstructions/popup.png)
</td></tr>
</table>

<a id="feature_settings"></a>
<table>
<tr><td> 

`@Scenario` `feature_settings()`<br />
</td></tr>
<tr><td>

In the plugin configuration screen:

![image.png](../featurebook-img/QuickEditFieldTad/feature_settings/image.png)
</td></tr>
</table>

<a id="feature_permissions"></a>
<table>
<tr><td> 

`@Scenario` `feature_permissions()`<br />
</td></tr>
<tr><td>

In order to access the feature, the "edit issue" permission needs to be present.
And the field needs to be "read/write". E.g. if read only:

![image.png](../featurebook-img/QuickEditFieldTad/feature_permissions/image.png)
</td></tr>
</table>
