//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUI_HostGame extends TUQ_GUIPage;

//var automated moNumericEdit gui_Players;
var automated GUIButton gui_1P,gui_2P,gui_3P,gui_4P;

function bool ButtonClick(GUIComponent Sender)
{
    if(Sender==gui_1P)
        Console(Controller.Master.Console).ConsoleCommand("start"@"TUQ-Level1.ut2?Game=TUQ.TUQ_Game?NumberOfPlayers=1?Listen");
    if(Sender==gui_2P)
        Console(Controller.Master.Console).ConsoleCommand("start"@"TUQ-Level1.ut2?Game=TUQ.TUQ_Game?NumberOfPlayers=2?Listen");
    if(Sender==gui_3P)
        Console(Controller.Master.Console).ConsoleCommand("start"@"TUQ-Level1.ut2?Game=TUQ.TUQ_Game?NumberOfPlayers=3?Listen");
    if(Sender==gui_4P)
        Console(Controller.Master.Console).ConsoleCommand("start"@"TUQ-Level1.ut2?Game=TUQ.TUQ_Game?NumberOfPlayers=4?Listen");

    return true;
}

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
  if(Key == 0x1B && state == 1) // Escape pressed
  {
    SaveSettings();
    Controller.ReplaceMenu("TUQ.TUQ_GUI_MainMenu");
    return true;
  }
  else
    return false;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  Super.InitComponent(MyController, MyOwner);
}

function SaveSettings()
{
}

DefaultProperties
{
/*    Begin Object Class=moNumericEdit Name=Players
        MinValue=1
        MaxValue=4
        CaptionWidth=0.700000
        ComponentWidth=0.300000
        Caption="Anzahl der Spieler"
        //OnCreateComponent=WebadminPort.InternalOnCreateComponent
        //IniOption="@Internal"
        Hint="Legen Sie die Anzahl der Spieler fest"
        WinTop=0.500000
        WinLeft=0.400000
        WinWidth=0.350000
        WinHeight=0.050000
        //TabOrder=5
    End Object
    gui_Players=moNumericEdit'TUQ.TUQ_GUI_HostGame.Players'*/

    Begin Object Class=GUIButton Name=OneP
         FontScale=FNS_Large
         Caption="1 Spieler"
         //CaptionEffectStylename="TextButtonEffect"
         Hint="Training"
         StyleName="TUQ_Button1"
         WinTop=0.2
         WinLeft=0.2
         WinWidth=0.3
         WinHeight=0.3
         bFocusOnWatch=true
         OnClick=TUQ_GUI_HostGame.ButtonClick
    End Object
    gui_1P=GUIButton'TUQ.TUQ_GUI_HostGame.OneP'

    Begin Object Class=GUIButton Name=TwoP
         FontScale=FNS_Large
         Caption="2 Spieler"
         //CaptionEffectStylename="TextButtonEffect"
         Hint="Duell"
         StyleName="TUQ_Button2"
         WinTop=0.2
         WinLeft=0.5
         WinWidth=0.3
         WinHeight=0.3
         bFocusOnWatch=true
         OnClick=TUQ_GUI_HostGame.ButtonClick
    End Object
    gui_2P=GUIButton'TUQ.TUQ_GUI_HostGame.TwoP'

    Begin Object Class=GUIButton Name=ThreeP
         FontScale=FNS_Large
         Caption="3 Spieler"
         //CaptionEffectStylename="TextButtonEffect"
         Hint="Flotter Dreier"
         StyleName="TUQ_Button3"
         WinTop=0.5
         WinLeft=0.2
         WinWidth=0.3
         WinHeight=0.3
         bFocusOnWatch=true
         OnClick=TUQ_GUI_HostGame.ButtonClick
    End Object
    gui_3P=GUIButton'TUQ.TUQ_GUI_HostGame.ThreeP'

    Begin Object Class=GUIButton Name=FourP
         FontScale=FNS_Large
         Caption="4 Spieler"
         //CaptionEffectStylename="TextButtonEffect"
         Hint="Chaos"
         StyleName="TUQ_Button1"
         WinTop=0.5
         WinLeft=0.5
         WinWidth=0.3
         WinHeight=0.3
         bFocusOnWatch=true
         OnClick=TUQ_GUI_HostGame.ButtonClick
    End Object
    gui_4P=GUIButton'TUQ.TUQ_GUI_HostGame.FourP'

    OnKeyEvent=TUQ_GUI_HostGame.MyKeyEvent

    bPersistent=true;
}
