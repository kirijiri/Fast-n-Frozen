//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUI_MidMenu extends BlackoutWindow;

var automated GUIButton MainButton;
var automated GUIButton QuitButton;
var automated GUIButton SettingsButton;
var automated GUIButton PlayButton;
var automated GUILabel 	PauseDesc;

function bool InternalOnClick(GUIComponent Sender)
{
    switch (Sender)
	{
         case QuitButton:
              Controller.OpenMenu(Controller.GetQuitPage());
	     break;
	     case PlayButton:
	          Controller.MainNotWanted = true;
              Controller.CloseMenu(false);
	     break;
	     case MainButton:
	          PlayerOwner().ConsoleCommand("DISCONNECT");
	          Controller.CloseMenu();
	     break;
	     case SettingsButton:
	          Controller.OpenMenu(Controller.GetSettingsPage());
	     break;
	}
	return true;
}

function InternalOnClose(optional Bool bCanceled)
{
	local PlayerController pc;

	pc = PlayerOwner();

	// Turn pause off if currently paused
	if(pc != None && pc.Level.Pauser != None)
		pc.SetPause(false);

	Super.OnClose(bCanceled);
}

function bool InternalOnKeyEvent( out byte Key, out byte State, float Delta )
{

		if ( Key == 0x1B ) // Cancel
		{
            InternalOnClick(PlayButton);
        }

		else if ( Key == 0x0D )
			InternalOnClick(PlayButton);

	return false;
}


defaultproperties
{
     Begin Object Class=GUIButton Name=cPlayButton
         Caption="Weiter"
         StyleName="TUQ_Button1"
         WinTop=0.425
         WinLeft=0.0
         WinWidth=0.250000
         WinHeight=0.15
         TabOrder=0
         bFocusOnWatch=true
         OnClick=TUQ_GUI_MidMenu.InternalOnClick
         OnKeyEvent=cPlayButton.InternalOnKeyEvent
     End Object
     PlayButton=GUIButton'TUQ.TUQ_GUI_MidMenu.cPlayButton'

     Begin Object Class=GUIButton Name=cSettingsButton
         Caption="Einstellungen"
         StyleName="TUQ_Button2"
         WinTop=0.425
         WinLeft=0.25
         WinWidth=0.250000
         WinHeight=0.15
         TabOrder=1
         bFocusOnWatch=true
         OnClick=TUQ_GUI_MidMenu.InternalOnClick
         OnKeyEvent=cSettingsButton.InternalOnKeyEvent
     End Object
     SettingsButton=GUIButton'TUQ.TUQ_GUI_MidMenu.cSettingsButton'

     Begin Object Class=GUIButton Name=cMainButton
         Caption="Aufgeben"
         StyleName="TUQ_Button3"
         WinTop=0.425
         WinLeft=0.5
         WinWidth=0.250000
         WinHeight=0.15
         TabOrder=1
         bFocusOnWatch=true
         OnClick=TUQ_GUI_MidMenu.InternalOnClick
         OnKeyEvent=cMainButton.InternalOnKeyEvent
     End Object
     MainButton=GUIButton'TUQ.TUQ_GUI_MidMenu.cMainButton'

     Begin Object Class=GUIButton Name=cQuitButton
         Caption="Beenden"
         StyleName="TUQ_Button1"
         WinTop=0.425
         WinLeft=0.75
         WinWidth=0.250000
         WinHeight=0.15
         TabOrder=1
         bFocusOnWatch=true
         OnClick=TUQ_GUI_MidMenu.InternalOnClick
         OnKeyEvent=cQuitButton.InternalOnKeyEvent
     End Object
     QuitButton=GUIButton'TUQ.TUQ_GUI_MidMenu.cQuitButton'

     i_FrameBG=none;

     OnClose=TUQ_GUI_MidMenu.InternalOnClose
     OnKeyEvent=TUQ_GUI_MidMenu.InternalOnKeyEvent
}
