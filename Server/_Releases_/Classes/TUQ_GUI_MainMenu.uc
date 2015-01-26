// ====================================================================
//  Class: TUQ_GUI_MainMenu
//  Das Hauptmenü der TUQ Mod
//
//  Author: RM
// ====================================================================

class TUQ_GUI_MainMenu extends TUQ_GUIPage;

var automated GUIButton b_Multi, b_Host, b_Settings, b_Quit, b_HostGame, b_JoinGame, b_TestButton;

function bool ButtonClick(GUIComponent Sender)
{
    if (Sender == b_Multi)
    	Controller.OpenMenu(Controller.GetServerBrowserPage());

    if (Sender == b_Host)
        Controller.OpenMenu(Controller.GetMultiplayerPage());

    if (Sender == b_Settings)
        Controller.OpenMenu(Controller.GetSettingsPage());

    if (Sender == b_Quit)
        Controller.OpenMenu(Controller.GetQuitPage());

    if (Sender == b_HostGame)
        Controller.ReplaceMenu("TUQ.TUQ_GUI_HostGame");

    if (Sender == b_JoinGame)
        Controller.ReplaceMenu("TUQ.TUQ_GUI_JoinGame");

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
    MyController.RegisterStyle(class'TUQ_STY_Button');
	Super.InitComponent(MyController, MyOwner);
}

defaultproperties
{
    Begin Object Class=GUIButton Name=MultiplayerButton
        FontScale=FNS_Large
        Caption="Mehrspieler"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Center
        Hint="Spiel über Internet oder LAN beitreten"
        WinTop=0.400000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Multi=MultiplayerButton

    Begin Object Class=GUIButton Name=HostButton
        FontScale=FNS_Large
        Caption="Server Starten"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Server für Mehrspieler-Modus starten"
        WinTop=0.500000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Host=HostButton

    Begin Object Class=GUIButton Name=SettingsButton
        FontScale=FNS_Large
        Caption="Einstellungen"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Änderungen an Steuerung und Spieleinstellungen"
        WinTop=0.600000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Settings=SettingsButton

    Begin Object Class=GUIButton Name=QuitButton
        FontScale=FNS_Large
        Caption="Beenden"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Spiel beenden... Ganz sicher?"
        WinTop=0.700000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_Quit=QuitButton

    Begin Object Class=GUIButton Name=HostGameButton
        FontScale=FNS_Large
        Caption="Spiel eröffnen"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Sie starten einen Spielserver"
        WinTop=0.10000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_HostGame=HostGameButton

    Begin Object Class=GUIButton Name=JoinGameButton
        FontScale=FNS_Large
        Caption="Spiel beitreten"
        StyleName="TUQ_Button"
        CaptionEffectStylename="TextButtonEffect"
        //CaptionAlign=TXTA_Left
        Hint="Sie schliessen sich einem Rennen an"
        WinTop=0.20000
        WinLeft=0.300000
        WinWidth=0.400000
        WinHeight=0.10000
        bFocusOnWatch=true
	    //bUseCaptionHeight=true
        OnClick=TUQ_GUI_MainMenu.ButtonClick
        OnKeyEvent=InstantActionButton.InternalOnKeyEvent
    End Object
    b_JoinGame=JoinGameButton

    OnKeyEvent=TUQ_GUI_MainMenu.MyKeyEvent
}
