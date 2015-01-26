//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUI_HostGame extends TUQ_GUIPage;

var automated moComboBox gui_PlayerColor, gui_Race, gui_PCount;
var automated GUIButton b_Player3D,gui_OK;
var automated GUIVertImageListBox gui_CharList;

var() SpinnyWeap SpinnyDude; // MUST be set to null when you leave the window
var() vector SpinnyDudeOffset;

function bool ButtonClick(GUIComponent Sender)
{
    if(Sender==gui_OK)
        //Controller.OpenMenu(Controller.GetServerBrowserPage());
            Console(Controller.Master.Console).ConsoleCommand("start"@"TUQ-Level1.ut2?Game=TUQ.TUQ_Game?Team="$GetPseudoTeam()$"?Players=2?Listen");

    return true;
}

function int GetPseudoTeam()
{
    local int pseudoTeam;
    pseudoTeam=0;

    pseudoTeam+=gui_Race.GetIndex()*100;
    pseudoTeam+=gui_CharList.List.Index*10;
    pseudoTeam+=gui_PlayerColor.GetIndex();

    return pseudoTeam;
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
  local rotator spinnyrot;

  Super.InitComponent(MyController, MyOwner);

  gui_PCount.AddItem("2 Spieler");
  gui_PCount.AddItem("3 Spieler");
  gui_PCount.AddItem("4 Spieler");

  gui_Race.AddItem("Robbe");
  gui_Race.AddItem("Pinguin");

  gui_PlayerColor.AddItem("Blau");
  gui_PlayerColor.AddItem("Rot");
  gui_PlayerColor.AddItem("Gelb");
  gui_PlayerColor.AddItem("Grün");
  gui_PlayerColor.AddItem("Pink");

  gui_PlayerColor.ReadOnly(True);
  gui_PlayerColor.SetIndex(0);

  gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe1", class'Material')));
  gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe2", class'Material')));
  gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe3", class'Material')));
  gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe4", class'Material')));
  gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe5", class'Material')));

  // Spawn spinning character actor
  if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

  SpinnyDude.bPlayCrouches = false;
  SpinnyDude.bPlayRandomAnims = false;

  SpinnyDude.SetDrawType(DT_Mesh);
  SpinnyDude.SetDrawScale(0.9);
  SpinnyDude.SpinRate = 0;

  spinnyrot=SpinnyDude.Rotation;
  spinnyrot.Yaw+=32768;

  SpinnyDude.SetRotation(spinnyrot);

  UpdateSpinnyDude();
}

function UpdateSpinnyDude()
{
	local Mesh PlayerMesh;
	local Material Skin;

	if(gui_Race.GetIndex()==0)
	{
    	if(gui_CharList.List.Index==0)
    	{
  	      PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe1.TUQRobbe", class'Mesh'));

    	  if(gui_PlayerColor.GetIndex()==0)Skin = Material(DynamicLoadObject("TUQRobbe1_Blau.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==1)Skin = Material(DynamicLoadObject("TUQRobbe1_Rot.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==2)Skin = Material(DynamicLoadObject("TUQRobbe1_Gelb.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==3)Skin = Material(DynamicLoadObject("TUQRobbe1_Gruen.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==4)Skin = Material(DynamicLoadObject("TUQRobbe1_Pink.shader.shader", class'Material'));
        }

        if(gui_CharList.List.Index==1)
    	{
  	      PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe2.TUQRobbe", class'Mesh'));

    	  if(gui_PlayerColor.GetIndex()==0)Skin = Material(DynamicLoadObject("TUQRobbe2_Blau.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==1)Skin = Material(DynamicLoadObject("TUQRobbe2_Rot.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==2)Skin = Material(DynamicLoadObject("TUQRobbe2_Gelb.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==3)Skin = Material(DynamicLoadObject("TUQRobbe2_Gruen.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==4)Skin = Material(DynamicLoadObject("TUQRobbe2_Pink.shader.shader", class'Material'));
        }

        if(gui_CharList.List.Index==2)
	    {
      	  PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe3.TUQRobbe", class'Mesh'));

    	  if(gui_PlayerColor.GetIndex()==0)Skin = Material(DynamicLoadObject("TUQRobbe3_Blau.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==1)Skin = Material(DynamicLoadObject("TUQRobbe3_Rot.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==2)Skin = Material(DynamicLoadObject("TUQRobbe3_Gelb.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==3)Skin = Material(DynamicLoadObject("TUQRobbe3_Gruen.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==4)Skin = Material(DynamicLoadObject("TUQRobbe3_Pink.shader.shader", class'Material'));
        }

        if(gui_CharList.List.Index==3)
	    {
      	  PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe4.TUQRobbe", class'Mesh'));

    	  if(gui_PlayerColor.GetIndex()==0)Skin = Material(DynamicLoadObject("TUQRobbe4_Blau.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==1)Skin = Material(DynamicLoadObject("TUQRobbe4_Rot.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==2)Skin = Material(DynamicLoadObject("TUQRobbe4_Gelb.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==3)Skin = Material(DynamicLoadObject("TUQRobbe4_Gruen.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==4)Skin = Material(DynamicLoadObject("TUQRobbe4_Pink.shader.shader", class'Material'));
        }

        if(gui_CharList.List.Index==4)
	    {
      	  PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe5.TUQRobbe", class'Mesh'));

    	  if(gui_PlayerColor.GetIndex()==0)Skin = Material(DynamicLoadObject("TUQRobbe5_Blau.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==1)Skin = Material(DynamicLoadObject("TUQRobbe5_Rot.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==2)Skin = Material(DynamicLoadObject("TUQRobbe5_Gelb.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==3)Skin = Material(DynamicLoadObject("TUQRobbe5_Gruen.shader.shader", class'Material'));
          if(gui_PlayerColor.GetIndex()==4)Skin = Material(DynamicLoadObject("TUQRobbe5_Pink.shader.shader", class'Material'));
        }
    }

    if(gui_Race.GetIndex()==1)
	{
	    //if(gui_CharList.List.Index==0)
    	//{
            PlayerMesh = Mesh(DynamicLoadObject("TUQPinguin1.PinguinChar1", class'Mesh'));
    	//}
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = Skin;
	SpinnyDude.LoopAnim('Idle_Rifle', 1.0 );
}

function bool InternalDraw(Canvas canvas)
{
    local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float   oOrgX, oOrgY;
	local float   oClipX, oClipY;

    super.OnDraw(canvas);

    oOrgX = Canvas.OrgX;
    oOrgY = Canvas.OrgY;
    oClipX = Canvas.ClipX;
    oClipY = Canvas.ClipY;

    Canvas.OrgX = b_Player3D.ActualLeft();
    Canvas.OrgY = b_Player3D.ActualTop();
    Canvas.ClipX = b_Player3D.ActualWidth();
    Canvas.ClipY = b_Player3D.ActualHeight();

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);

	SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
	canvas.DrawActorClipped(SpinnyDude, false,  b_Player3D.ActualLeft(), b_Player3D.ActualTop(), b_Player3D.ActualWidth(), b_Player3D.ActualHeight(), true, 65);

    Canvas.OrgX = oOrgX;
	Canvas.OrgY = oOrgY;
    Canvas.ClipX = oClipX;
    Canvas.ClipY = oClipY;

	return true;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
}

function InternalOnChange(GUIComponent Sender)
{
    if(Sender==gui_CharList||Sender==gui_PlayerColor)
        UpdateSpinnyDude();

    if(Sender==gui_Race)
    {
        if(gui_Race.GetIndex()==0)
        {
           gui_CharList.Clear();
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe1", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe2", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe3", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe4", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Robbe5", class'Material')));
        }
        if(gui_Race.GetIndex()==1)
        {
           gui_CharList.Clear();
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Pinguin1", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Pinguin2", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Pinguin3", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Pinguin4", class'Material')));
           gui_CharList.AddImage(Material(DynamicLoadObject("TUQPlayerIcons.Pinguin5", class'Material')));
        }
    }
}

function SaveSettings()
{
}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
	local rotator r;
  	r = SpinnyDude.Rotation;
    r.Yaw -= (256 * DeltaX);
    SpinnyDude.SetRotation(r);
    return true;
}

DefaultProperties
{
    Begin Object Class=moComboBox Name=Spielerzahl
         bReadOnly=True
         CaptionWidth=0.55
         Caption="Spielerzahl"
         IniOption="@INTERNAL"
         Hint="Wieviele Spieler sollen maximal teilnehmen..."
         WinTop=0.02
         WinLeft=0.10
         WinWidth=0.38
         TabOrder=0
         OnChange=TUQ_GUI_HostGame.InternalOnChange
         OnLoadINI=TUQ_GUI_HostGame.InternalOnLoadINI
    End Object
    gui_PCount=moComboBox'TUQ.TUQ_GUI_HostGame.Spielerzahl'

    Begin Object Class=moComboBox Name=Rasse
         bReadOnly=True
         CaptionWidth=0.55
         Caption="Rasse"
         IniOption="@INTERNAL"
         Hint="Such dir eine Rasse aus..."
         WinTop=0.02
         WinLeft=0.50
         WinWidth=0.38
         TabOrder=0
         OnChange=TUQ_GUI_HostGame.InternalOnChange
         OnLoadINI=TUQ_GUI_HostGame.InternalOnLoadINI
    End Object
    gui_Race=moComboBox'TUQ.TUQ_GUI_HostGame.Rasse'

    Begin Object Class=moComboBox Name=Farbe
         bReadOnly=True
         CaptionWidth=0.55
         Caption="Farbe"
         IniOption="@INTERNAL"
         Hint="Such dir deine Farbe aus..."
         WinTop=0.07
         WinLeft=0.50
         WinWidth=0.38
         TabOrder=1
         OnChange=TUQ_GUI_HostGame.InternalOnChange
         OnLoadINI=TUQ_GUI_HostGame.InternalOnLoadINI
    End Object
    gui_PlayerColor=moComboBox'TUQ.TUQ_GUI_HostGame.Farbe'

    Begin Object Class=GUIButton Name=Player3D
         StyleName="NoBackground"
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.950000
         WinHeight=0.950000
         MouseCursorIndex=5
         bTabStop=false
         bNeverFocus=true
         bDropTarget=false
         //OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=TUQ_GUI_HostGame.RaceCapturedMouseMove
         OnDraw=TUQ_GUI_HostGame.InternalDraw
    End Object
    b_Player3D=GUIButton'TUQ.TUQ_GUI_HostGame.Player3D'

    Begin Object Class=GUIVertImageListBox Name=CharList
         CellStyle=CELL_FixedCount
         NoVisibleRows=5
         NoVisibleCols=1
         OnCreateComponent=CharList.InternalOnCreateComponent
         WinTop=0.12
         WinLeft=0.71
         WinWidth=0.15
         WinHeight=0.75
         TabOrder=0
         HorzBorder=0
         VertBorder=0
         bBoundToParent=Wahr
         bScaleToParent=Wahr
         OnChange=TUQ_GUI_HostGame.InternalOnChange
    End Object
    gui_CharList=GUIVertImageListBox'TUQ.TUQ_GUI_HostGame.CharList'

    Begin Object Class=GUIButton Name=OK
         Caption="OK"
         Hint="OK"
         WinTop=0.9
         WinLeft=0.6
         WinWidth=0.3
         WinHeight=0.07
         OnClick=TUQ_GUI_HostGame.ButtonClick
    End Object
    gui_OK=GUIButton'TUQ.TUQ_GUI_HostGame.OK'

    OnKeyEvent=TUQ_GUI_HostGame.MyKeyEvent

    SpinnyDudeOffset=(X=90.000000,Y=-20.000000,Z=-30.000000)

    bPersistent=true;
}
