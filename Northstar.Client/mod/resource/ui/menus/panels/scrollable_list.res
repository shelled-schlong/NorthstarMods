resource/ui/menus/panels/scrollable_list.res
{
    Anchor
	{
		ControlName			ImagePanel
		wide				50
		tall				50
		image				vgui/HUD/white
		scaleImage			1

        drawColor		"255 0 0 255"
        fillColor       "0 0 0 0"
	}

	Slider
	{
		ControlName				CNestedPanel
		classname				NS_Scrollbar

		controlSettingsFile		"resource/ui/menus/panels/scrollbar.res"
		wide	40
		tall	50
        zpos    1

        pin_to_sibling          Anchor
		pin_corner_to_sibling 	TOP_RIGHT
		pin_to_sibling_corner 	TOP_RIGHT
	}
}