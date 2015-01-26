//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUIPage extends GUIPage;

var string MenuSong;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);

  PlayerOwner().GetEntryLevel().Song = MenuSong;
  PlayerOwner().GetEntryLevel().MusicVolumeOverride=0.0;
  PlayerOwner().ClientSetInitialMusic(MenuSong,MTRAN_Segue);
}

function OnClose(optional Bool bCanceled)
{
}

DefaultProperties
{
    bDisconnectOnOpen=True
    bAllowedAsLast=True
    MenuSong="../TUQ/Music/TUQ_Menue"

    Background=Material'TUQMenue.TUQMenue.TUQMenueBack'

	WinWidth=1.000000
    WinHeight=1.000000
}
