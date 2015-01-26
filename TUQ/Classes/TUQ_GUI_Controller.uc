//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUI_Controller extends UT2K4GUIController;

defaultproperties
{
     STYLE_NUM=75
     MainMenuOptions(0)="TUQ.TUQ_GUIPage"
     MainMenuOptions(1)="TUQ.TUQ_GUI_LANPage"
     MainMenuOptions(2)="TUQ.TUQ_GUI_HostGame"
     MainMenuOptions(3)=None
     MainMenuOptions(4)="TUQ.TUQ_GUI_PlayerSettings"
     MainMenuOptions(5)="TUQ.TUQ_GUI_SettingsPage"
     MainMenuOptions(6)="GUI2K4.UT2K4QuitPage"

     Begin Object Class=TUQ.TUQ_Font Name=TUQFont
     End Object

     FontStack(11)=TUQFont

     /*Begin Object Class=TUQ.TUQ_FontSmall Name=TUQFontSmall
     End Object

     FontStack(12)=TUQFontSmall*/
}
