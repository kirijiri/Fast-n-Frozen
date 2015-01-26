// ====================================================================
//  Class: TUQ_GUI_MainMenu
//  Das Hauptmenü der TUQ Mod
//
//  Author: RM
// ====================================================================

class TUQ_GUI_MainMenu extends TUQ_GUIPage;

var automated GUIButton b_Settings, b_Quit, b_HostGame, b_JoinGame, b_TestButton,b_PSettings;
var GUIButton Selected;

function MoveOn()
{
    switch(Selected)
    {
        case b_Settings:
            //Controller.ReplaceMenu("TUQ.TUQ_GUI_SettingsPage");
            Controller.OpenMenu(Controller.GetSettingsPage());
            return;

        case b_Quit:
            Controller.OpenMenu(Controller.GetQuitPage());
            return;

        case b_HostGame:
            //Controller.ReplaceMenu("TUQ.TUQ_GUI_HostGame");
            Controller.ReplaceMenu(Controller.GetMultiplayerPage());
            return;

        case b_JoinGame:
            //Controller.ReplaceMenu("TUQ.TUQ_GUI_LANPage");
            Controller.ReplaceMenu(Controller.GetServerBrowserPage());
            return;

        case b_PSettings:
            //Controller.ReplaceMenu("TUQ.TUQ_GUI_PlayerSettings");
            Controller.ReplaceMenu(Controller.GetModPage());
            //eigentlich die PlayerSettingspage nur im GUIController so genannt
            return;

        default:
			StopWatch(True);
    }
}

function MainReopened()
{
	if ( !PlayerOwner().Level.IsPendingConnection() )
	{
		Opened(none);
		Timer();
	}
}

function bool ButtonClick(GUIComponent Sender)
{
    if (GUIButton(Sender) != None)
		Selected = GUIButton(Sender);

	if (Selected==None)
    	return false;

	if(Selected!=b_Settings&&Selected!=b_Quit)
	    MoveOn();
    else
    {
        InitAnimOut(b_JoinGame,1,0.1,0.4);
        InitAnimOut(b_HostGame,-0.4,0.1,0.4);
	    InitAnimOut(b_PSettings,0.3,1.0,1.0);
	    InitAnimOut(b_Settings,0.3,1.2,0.8);
	    InitAnimOut(b_Quit,0.3,1.4,0.5);
    }

    return true;
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
  if(Key == 0x1B && state == 1) // Escape pressed
  {
    Controller.OpenMenu(Controller.GetQuitPage());
    return true;
  }
  else
  return false;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    MyController.RegisterStyle(class'TUQ_STY_Button1');
    MyController.RegisterStyle(class'TUQ_STY_Button2');
    MyController.RegisterStyle(class'TUQ_STY_Button3');
	Super.InitComponent(MyController, MyOwner);
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);

    // Reset the animations of all components
    b_JoinGame.Animate(1,0.1,0);
    b_HostGame.Animate(-0.4,0.1,0);
    b_PSettings.Animate(0.3,1.4,0);
    b_Settings.Animate(0.3,1.6,0);
    b_Quit.Animate(0.3,1.8,0);

    Selected = none;
}

event Timer()
{
   super.Timer();

   b_HostGame.Animate(0.1,0.1,0.4);
   b_HostGame.OnArrival=PlayPopSound;
   b_JoinGame.Animate(0.5,0.1,0.4);
   b_JoinGame.OnArrival=PlayPopSound;
   b_PSettings.Animate(0.3,0.3,0.7);
   b_Psettings.OnArrival=PlayPopSound;
   b_Settings.Animate(0.3,0.5,1.0);
   b_Settings.OnArrival=PlayPopSound;
   b_Quit.Animate(0.3,0.7,1.2);
   b_Quit.OnArrival=PlayPopSound;
}

function PlayPopSound(GUIComponent Sender, EAnimationType Type)
{
    PlayerOwner().PlaySound(sound'TUQSounds.clap');
}

function InitAnimOut(GUIComponent C, float X, float Y, float Z )
{
	C.Animate(X,Y,Z);
	C.OnEndAnimation = MenuOut_Done;
}

function MenuOut_Done(GUIComponent Sender, EAnimationType Type)
{
	Sender.OnArrival = none;
	if (bAnimating)
		return;

    MoveOn();
}

function InternalOnOpen()
{
    Timer();
}

defaultproperties
{
    Begin Object Class=GUIButton Name=HostGameButton
        Caption="Spiel beginnen"
        StyleName="TUQ_Button1"
        //CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Sie starten einen Spielserver"
        WinTop=0.100000
        WinLeft=0.100000
        WinWidth=0.400000
        WinHeight=0.20000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_HostGame=HostGameButton

    Begin Object Class=GUIButton Name=JoinGameButton
        Caption="Spiel beitreten"
        StyleName="TUQ_Button2"
        //CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Sie schliessen sich einem Rennen an"
        WinTop=0.10000
        WinLeft=0.500000
        WinWidth=0.400000
        WinHeight=0.20000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_JoinGame=JoinGameButton

    Begin Object Class=GUIButton Name=PlayerSettingsButton
        Caption="Spieler Auswahl"
        StyleName="TUQ_Button3"
        //CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Such Dir Deinen Helden aus..."
        WinTop=0.30000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.20000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_PSettings=PlayerSettingsButton

    Begin Object Class=GUIButton Name=SettingsButton
        Caption="Einstellungen"
        StyleName="TUQ_Button3"
        //CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Änderungen an Steuerung und Spieleinstellungen"
        WinTop=0.500000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.20000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Settings=SettingsButton

    Begin Object Class=GUIButton Name=QuitButton
        Caption="Beenden"
        StyleName="TUQ_Button1"
        //CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Spiel beenden... Ganz sicher?"
        WinTop=0.700000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.20000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Quit=QuitButton

    /*Begin Object Class=BackgroundImage Name=PageBackground
    //Object Properties fit in here
        Image=Texture'TUQBackGrounds.MainMenu'
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Alpha
        X1=0
        Y1=0
        X2=1024
        Y2=1024
    End Object
    MenuBackground=TUQ.TUQ_GUI_MainMenu.PageBackground*/

    OnKeyEvent=TUQ_GUI_MainMenu.MyKeyEvent
    OnOpen=TUQ_GUI_MainMenu.InternalOnOpen
    OnReOpen=TUQ_GUI_MainMenu.MainReopened

    //Background=Material'TUQBackGrounds.MainMenu'
}
