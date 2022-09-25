untyped
global function UseCustomScrollbars
global function RegisterScrollbar
global function RegisterScrollbarMoveCallback
global function RegisterScrollbarMoveCallbackAttached
global function SetScrollbarHeight
global function SetScrollbarWidth
global function SetScrollbarHorizontal
global function FindScrollbarSafe
global function FindScrollbar
global function SetScrollbarPosition
global function GetFocusedScrollbar

global struct ScrollbarExt {
	array<void functionref( int x, int y )> callbacks
	array<void functionref( ScrollbarExt component, int x, int y )> attachedCallbacks
	var component
	var cover
	var movementCapture
	var button
	var panel
	bool horizontal
}

struct {
	array<ScrollbarExt> scrollbars
	array<var> covers
	var invisCover
} file

// * ###################
// * global functions ##
// * ###################

void function UseCustomScrollbars( var menu )
{
	foreach( var scrollbar in GetElementsByClassname( menu, "NS_Scrollbar" ) )
		RegisterScrollbar( scrollbar )
	foreach( var scrollbar in GetElementsByClassname( menu, "NS_Scrollbar_h" ) )
		RegisterScrollbar( scrollbar, true )

	AddMouseMovementCaptureHandler( menu, MouseMovementHandler )
}

void function RegisterScrollbarMoveCallback( var scrollbar, void functionref( int x, int y ) f )
{
	FindScrollbar( scrollbar ).callbacks.append( f )
}

void function RegisterScrollbarMoveCallbackAttached( var scrollbar, void functionref( ScrollbarExt component, int x, int y ) f )
{
	FindScrollbar( scrollbar ).attachedCallbacks.append( f )
}

void function SetScrollbarHeight( var scrollbar, int height )
{
	ScrollbarExt ctn = FindScrollbar( scrollbar )
	Hud_SetHeight( ctn.cover, height )
	Hud_SetHeight( ctn.movementCapture, height )
	Hud_SetHeight( ctn.button, height )
	Hud_SetHeight( ctn.panel, height )
}

void function SetScrollbarWidth( var scrollbar, int width )
{
	ScrollbarExt ctn = FindScrollbar( scrollbar )
	Hud_SetWidth( ctn.cover, width )
	Hud_SetWidth( ctn.movementCapture, width )
	Hud_SetWidth( ctn.button, width )
	Hud_SetWidth( ctn.panel, width )
}

void function SetScrollbarHorizontal( var scrollbar, bool horizontal )
{
	FindScrollbar( scrollbar ).horizontal = horizontal
}

void function RegisterScrollbar( var scrollbar, bool horizontal = false )
{
	if( FindScrollbarSafe( scrollbar ) )
	{
		printt( format( "%s is already registered. omitting registration.", scrollbar.tostring() ) )
		return
	}

	var cover = Hud_GetChild( scrollbar, "SliderCover" )
	AddButtonEventHandler( cover, UIE_GET_FOCUS, CoverGetFocus )
	file.covers.append( cover )
	ScrollbarExt bar
	bar.component = scrollbar
	bar.cover = cover
	bar.movementCapture = Hud_GetChild( scrollbar, "MouseMovementCapture" )
	bar.button = Hud_GetChild( scrollbar, "SliderButton" )
	bar.panel = Hud_GetChild( scrollbar, "BtnModListSliderPanel" )
	bar.horizontal = horizontal
	file.scrollbars.append( bar )
}

ScrollbarExt ornull function FindScrollbarSafe( var scrollbar )
{
	foreach( ScrollbarExt container in file.scrollbars )
		if( container.component == scrollbar )
			return container
	return null
}

ScrollbarExt function FindScrollbar( var scrollbar )
{
	ScrollbarExt ornull scr = FindScrollbarSafe( scrollbar )
	if( scr != null )
		return expect ScrollbarExt( scr )
	throw "scrollbar not registered"
	unreachable
}

void function SetScrollbarPosition( ScrollbarExt scrollbar, int x, int y )
{
	Hud_SetPos( scrollbar.cover, x, y )
	Hud_SetPos( scrollbar.movementCapture, x, y )
	Hud_SetPos( scrollbar.button, x, y )
	Hud_SetPos( scrollbar.panel, x, y )
}

ScrollbarExt function GetFocusedScrollbar()
{
	return file.scrollbars[ GetFocusedScrollbarIndex() ]
}

// * #####################
// * internal functions ##
// * #####################

void function CoverGetFocus( var cover )
{
	Hud_SetVisible( cover, false )
	if( file.invisCover )
		Hud_SetVisible( file.invisCover, true )
	file.invisCover = cover

	ScrollbarExt s = file.scrollbars[ GetFocusedScrollbarIndex() ]
	Hud_SetFocused( s.button )
}

void function MouseMovementHandler( int x, int y )
{
	int idx = GetFocusedScrollbarIndex()
	Hud_SetFocused( file.scrollbars[ idx ].button )
	if( idx < 0 )
		return
	foreach( void functionref( int x, int y ) callback in file.scrollbars[ idx ].callbacks )
	{
		callback( x, y )
	}
	foreach( void functionref( ScrollbarExt component, int x, int y ) callback in file.scrollbars[ idx ].attachedCallbacks )
		callback( file.scrollbars[ idx ], x, y )
	if( file.scrollbars[ idx ].horizontal )
		RepositionScrollbar_Horizontal( file.scrollbars[ idx ], x, y )
	else
		RepositionScrollbar_Vertical( file.scrollbars[ idx ], x, y )
}

void function RepositionScrollbar_Horizontal( ScrollbarExt scrollbar, int x, int y )
{
	x = x * -1
	y = y * -1

	int minXPos = Hud_GetBaseX( scrollbar.button )
	int maxXPos = minXPos + Hud_GetWidth( scrollbar.component ) - Hud_GetWidth( scrollbar.button )

	int pos = expect int( Hud_GetPos( scrollbar.button )[0] )
	int newPos = pos - x

	if ( newPos > maxXPos ) newPos = maxXPos
	if ( newPos < minXPos ) newPos = minXPos

	int yPos = expect int( Hud_GetPos( scrollbar.button )[1] )

	SetScrollbarPosition( scrollbar, newPos, yPos )
}

void function RepositionScrollbar_Vertical( ScrollbarExt scrollbar, int x, int y )
{
	x = x * -1
	y = y * -1

	int[2] screenSize = GetScreenSize()
	var sliderPanel = scrollbar.panel

	int minYPos = Hud_GetBaseY( scrollbar.button )
	int maxYPos = minYPos + Hud_GetHeight( scrollbar.component ) - Hud_GetHeight( scrollbar.button )

	int pos = expect int( Hud_GetPos( scrollbar.button )[1] )
	int newPos = pos - y

	if ( newPos > maxYPos ) newPos = maxYPos
	if ( newPos < minYPos ) newPos = minYPos

	int xPos = expect int( Hud_GetPos( scrollbar.button )[0] )

	SetScrollbarPosition( scrollbar, xPos, newPos )
}

int function GetFocusedScrollbarIndex()
{
	return file.covers.find( file.invisCover )
}