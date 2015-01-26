// ====================================================================
//  Written by Ron Prestenback (based on XInterface.ServerBrowser)
//  (c) 2002, 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class TUQ_GUI_LANPage extends UT2K4ServerBrowser
    config;

var Material LANBackground;

function CreateTabs()
{
	local UT2K4Browser_Page LANTab;

	LANTab = AddTab(PanelCaption[3], PanelClass[3], PanelHint[3]);
    LANTab.Background = LANBackground;

	//DisableMSTabs();

	// Must perform the first refresh manually, since the RefreshFooter delegate won't be assigned
	// when the first tab panel receives the first call to ShowPanel()
	RefreshFooter( UT2K4Browser_Page(c_Tabs.ActiveTab.MyPanel),"false" );
}

defaultproperties
{
     LANBackground=Material'TUQMenue.TUQMenue.TUQMenueBack'
}
