untyped
global function RegisterScrollableList
global function FindScrollableListSafe
global function FindScrollableList

global struct ScrollableList {
    var component
    var anchor
    ScrollbarExt& slider
    array<var> contents
}

struct {
    array<ScrollableList> lists
} file

void function RegisterScrollableList( var list, array<var> contents, bool horizontal = false )
{
    if( FindScrollableListSafe( list ) )
    {
        printt( format( "scrollable list %s is already registered. omitting registration", list.tostring() ) )
        return
    }

    UseCustomScrollbars( GetParentMenu( list ) )

    ScrollableList ext
    ext.component = list
    ext.anchor = Hud_GetChild( list, "Anchor" )
    ext.slider = FindScrollbar( Hud_GetChild( list, "Slider" ) )
    ext.contents = contents
    file.lists.append( ext )

    // if( !horizontal )
    // {
    //     SetScrollbarHorizontal( ext.component, true )

    // }

    // horizontal not supported yet
    Hud_SetSize( ext.anchor, Hud_GetWidth( list ), Hud_GetHeight( list ) )
    Hud_SetHeight( ext.slider.component, Hud_GetHeight( list ) )
    RegisterScrollbarMoveCallbackAttached( ext.slider.component, ScrollableListScrollbarMoveCallback )
    
    int lastContentPixel
    int totalContentPixels
    foreach( var content in contents )
    {
        int cContentPixel = Hud_GetAbsY( content ) + Hud_GetHeight( content )
        if( cContentPixel > lastContentPixel )
            lastContentPixel = cContentPixel
        totalContentPixels += Hud_GetHeight( content )
    }

    if( lastContentPixel <= Hud_GetAbsY( list ) + Hud_GetHeight( list ) )
        SetScrollbarHeight( ext.slider.component, Hud_GetHeight( list ) )
    else
    {
        SetScrollbarHeight( ext.slider.component, Hud_GetHeight( list ) * Hud_GetHeight( list ) / totalContentPixels )
        printt( totalContentPixels, Hud_GetHeight( list ), Hud_GetHeight( list ) / totalContentPixels )
    }
    // printt( lastContentPixel, Hud_GetAbsY( list ) + Hud_GetHeight( list ) )

    // printt( lastContentPixel )

    // int contentHeight
    // foreach( var content in contents )
    //     contentHeight += Hud_GetHeight( content )
    // if( contentHeight < Hud_GetHeight( list ) )
    //     SetScrollbarHeight( ext.slider.component, Hud_GetHeight( list ) )
    // else 
    //     SetScrollbarHeight( ext.slider.component, Hud_GetHeight( list ) * (Hud_GetHeight( list ) / contentHeight) )
    // Hud_SetWidth( ext.slider.component, 30 )
    // SetScrollbarWidth( ext.slider.component, 30 )
}

ScrollableList ornull function FindScrollableListSafe( var list )
{
    foreach( ScrollableList regList in file.lists )
        if( regList.component == list )
            return regList
    return null
}

ScrollableList function FindScrollableList( var list )
{
    ScrollableList ornull scr = FindScrollableListSafe( list )
    if( scr )
        return expect ScrollableList( scr )
    throw "scrollable list not registered"
    unreachable
}

// Internal
void function ScrollableListScrollbarMoveCallback( ScrollbarExt scrollbar, int x, int y )
{
    printt(Hud_GetHeight(scrollbar.component), scrollbar.vY)
    // printt(x,y)
    // printt( scrollbar.component, file.lists[0].slider.component )
    // Hud_Hide( file.lists[0].component)
    // if( file.lists[0].component == GetFocusedScrollbar().component )
    //     printt( GetFocusedScrollbar().component )

    foreach( var content in FindListByBar( scrollbar ).contents )
        Hud_SetY( content, Hud_GetY( content ) - x )
}

ScrollableList function FindListByBar( ScrollbarExt scrollbar )
{
    foreach( ScrollableList list in file.lists )
        if( list.slider.component == scrollbar.component )
            return list
    throw "couldn't find scrollable list by scrollbar"
    unreachable
}