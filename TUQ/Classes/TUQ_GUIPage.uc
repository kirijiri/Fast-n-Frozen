//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUIPage extends GUIPage;

var string MenuSong;
var automated BackgroundImage MenuBackground;

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
    //MenuBackground=Material'TUQHud.TUQHud.FinishHUD'

    Begin Object Class=BackgroundImage Name=PageBackground
    //Object Properties fit in here
        Image=Texture'TUQHud.TUQHud.FinishHUD'
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Alpha
        X1=0
        Y1=0
        X2=1024
        Y2=768
    End Object
    MenuBackground=TUQ.TUQ_GUIPage.PageBackground

	WinWidth=1.000000
    WinHeight=1.000000
}
