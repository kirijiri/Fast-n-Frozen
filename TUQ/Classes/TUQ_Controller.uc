//=============================================================================
// Der PlayerController für die TUQ Mod
// Ist z.B. zuständig für die Kamerasteuerung
//
// Author: RM
//=============================================================================
class TUQ_Controller extends xPlayer;

#exec OBJ LOAD FILE=TUQPickupsGfx.utx

var bool bHasFinished;        // wird TRUE gesetzt, falls das Ziel erreicht ist
var float StartCountdown;
var bool bCountdownEnabled;
var bool IsReadyToStart;
var int oldVisiblePlayers;
//var bool bIsOnStaticMesh;
var float StateChangeTimer;

var TUQ_CheckpointTeleporter TeleDest;
var int myPlace;

// für etwas gut
//var string TUQ_URL;

// fürs Ranking
var string FirstName;
var string SecondName;
var string ThirdName;
var string FourthName;
var float FirstTime;
var float SecondTime;
var float ThirdTime;
var float FourthTime;

// ausm Menue (hoffentlich)
var int figur,farbe,rasse;

// für Eingabetest
var bool bNumber1, bNumber2, bNumber3, bNumber4, bNumber5;

// *** für Slide-Modus *** //
var bool bSlide;
var vector HoverFloor;        // gemessene Bodenneigung für PHYS_Hovering
var int TickCount;            // Zähler für Ticks
var int TickCount2;           // Zähler für Ticks
var float oldForward;         // Vorwärts-Eingabe vom letzten Frame
var float oldStrafe;          // Seitwärts-Eingabe vom letzten Frame
var bool bLeavingState;       // fürs Abbremsen beim Übergang zu Walking

// *** für Motion-Blur *** //
var CameraEffect CamFX;
var bool bHasCameraEffect;
var int AlphaBlur;            // [1..255] Stärke des Motion-Blur (1 = am stärksten)

// *** für Kamera *** //
var float CamHeight, CamDist; // Werte für die Kameratranslation
var float DesiredCamHeight, DesiredCamDist; // Werte für die Kameratranslation
var int PitchAdjust;
var float PositionAdjustX;
var float PositionAdjustZ;

// HitDetection
var int oldVel;

// *** für Mesh Replication *** //
var bool PendingMeshUpdate;   // falls wahr, müssen die PlayerMeshs aktualisiert werden

// *** für Debug *** //
var vector BaseNormal;
var bool bForceDir;

/// JetPack
var bool bJetPack;
var bool bMakeNewTrail;
var sound MuteFireSound;
var int JetPackAmmo;

/// SandBag
var bool bSandBag;

replication
{
    // Funktionen, die der Client aufrufen kann
    reliable if (Role < ROLE_Authority)
        ServerSetPhysics, ServerSetMeshUpdate, ServerDoJetPackFX,
        ServerKillJetPackFX, ServerSetReady, ServerSetMesh,
        ServerSetInitialMesh, ServerHitFX, ServerTeleport, ServerSetAmmo;

    // Funktionen, die der Server aufrufen kann
    reliable if (Role == ROLE_Authority)
        ClientSetMesh, ClientDoJetPackFX, ClientKillJetPackFX,
        ClientShowWaiting, ClientSetFinished,
        ClientFinalCountdown, ClientSetInitialMesh, ClientStartTimer,
        ClientStopTimer, ClientPlayWallFX, ClientHitFX, ClientSetTeleporter,
        ClientSetPlace, ClientSetRanking;
}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

event PlayerTick( float DeltaTime )
{
    local Controller P;
	local TUQ_Controller aPlayer;
	local float Dist, Radius;
	local int VisiblePlayers;
    local string sName;
    local int rnd;
    local int s;

    super.PlayerTick(DeltaTime);

    if(Level.TimeSeconds<1)
    {
        //GetPseudoTeamNum();
        //RobbeRunningMesh(Pawn);
    }

    // MeshUpdate, wenn man wieder im Blickfeld eines anderen Spielers auftaucht
	VisiblePlayers = 0;
    Radius = 5000;
    for (P = Level.ControllerList; P != None; P = P.nextController)
	{
		aPlayer = TUQ_Controller(P);
		if (aPlayer != None && aPlayer.Pawn != None && Pawn != None)
		{
		    // Distanz zum eigenen Spieler berechnen
		    Dist = VSize(Pawn.Location - aPlayer.Pawn.Location);
		    if (Dist <= Radius)
		        VisiblePlayers++;
		}
	}
    if (VisiblePlayers > oldVisiblePlayers)
    {
        if (bSlide)
            Sliding();
        else
            Walking();
    }
    oldVisiblePlayers = VisiblePlayers;

    // zufällig Sounds abspielen
    rnd=Rand(20000);
    if(rnd==666)
    {
        s=Rand(2)+1;

        if(rasse==0)
            sName="TUQRobbe"$figur+1$"Sounds.R"$figur+1$"Comment"$s;
        if(rasse==1)
            sName="TUQPingu"$figur+1$"Sounds.P"$figur+1$"Comment"$s;

        Pawn.PlaySound(sound(DynamicLoadObject(sName,class'sound')),,1,false);
    }
}

function GetPseudoTeamNum()
{
    local int teamCode;
    teamCode=int(GetUrlOption("Team"));

    if (teamCode > 144)
        teamCode = 0;

    rasse=teamcode/100;
    teamcode=teamcode-rasse*100;
    figur=teamcode/10;
    teamcode=teamcode-figur*10;
    farbe=teamcode;
}

// Camera-Zoom per Knopfdruck
exec function CamZoomIn()
{
    //debug
    /*
    local Controller P;
	local TUQ_Controller aPlayer;
    */

    if(DesiredCamHeight>30)
    {
        DesiredCamHeight-=10.0;
        DesiredCamDist-=25.0;
    }

    // debug
    /*
    if (Role == ROLE_Authority)
    {
        for (P = Level.ControllerList; P != None; P = P.nextController)
        {
		    aPlayer = TUQ_Controller(P);
		    if (aPlayer != none)
		    {
		        aPlayer.GivePawn(aPlayer.Pawn);
		    }
        }
    }
    */
}

exec function CamZoomOut()
{
    if(DesiredCamHeight<150)
    {
        DesiredCamHeight+=10.0;
        DesiredCamDist+=25.0;
    }
}

// Umschalten des Slide-Modus per Knopfdruck
exec function ToggleSlideMode()
{
    bSlide = !bSlide;

    if (bSlide)
    {
        Sliding();
        bLeavingState = false;
        StateChangeTimer = 0.3;
        //GotoState('PlayerSliding');
    }
    else
    {
        //Walking();
        //GotoState('PlayerWalking');
        bLeavingState = true;
    }
}

/*
simulated function ClientSetMesh(TUQ_Pawn MyPawn)
{
    local TUQ_Pawn OtherPawn;

    if (Role < ROLE_Authority)  // betrifft nur Client
    {
        //log("------------------------------> ClientSetMesh!");
        if (MyPawn == None)
        {
            // der Server soll es nochmal versuchen
            ServerSetMeshUpdate();
            return;
        }
        log("------------------------------> ClientSetMesh! für "$MyPawn.PlayerReplicationInfo.PlayerName);
        //RobbeRunningMesh(MyPawn);  // zum Test...
        foreach AllActors(class'TUQ_Pawn', OtherPawn)
        {
            RobbeRunningMesh(OtherPawn);  // zum Test...
        }
    }
}
*/

//Meshwechsel für Slide-Animationen
function Sliding()
{
    //if (rasse==0)RobbeSlidingMesh(Pawn);
    //else PinguinSlidingMesh(Pawn);

    local string WeaponName;

    GetPseudoTeamNum();
  	if (Pawn != none && Pawn.Weapon.ItemName == "JetPack" && Pawn.Weapon.AmmoAmount(0) > 0)
  	    WeaponName = "JetPack";
    else if (Pawn != none && Pawn.Weapon.ItemName == "SandBag" && Pawn.Weapon.AmmoAmount(0) > 0)
        WeaponName = "SandBag";
    else
        WeaponName = "";

    ServerSetMesh(self.GetHumanReadableName(), true, rasse, figur, farbe, WeaponName);
    //ServerSetMesh(TUQ_Pawn(Pawn), true, rasse, figur, farbe, WeaponName);
}

//Meshwechsel für Walk-Animationen
function Walking()
{
    //if (rasse==0)RobbeRunningMesh(Pawn);
    //else PinguinRunningMesh(Pawn);

    local string WeaponName;

    GetPseudoTeamNum();
  	if (Pawn != none && Pawn.Weapon.ItemName == "JetPack" && Pawn.Weapon.AmmoAmount(0) > 0)
  	    WeaponName = "JetPack";
    else if (Pawn != none && Pawn.Weapon.ItemName == "SandBag" && Pawn.Weapon.AmmoAmount(0) > 0)
        WeaponName = "SandBag";
    else
        WeaponName = "";

    ServerSetMesh(self.GetHumanReadableName(), false, rasse, figur, farbe, WeaponName);
    //ServerSetMesh(TUQ_Pawn(Pawn), false, rasse, figur, farbe, WeaponName);
}

/*
//PinguinMesh für Laufen
function PinguinRunningMesh(Pawn P)
{
	local Mesh PlayerMesh;
	if (P == none)
	    return;
    PlayerMesh = Mesh(DynamicLoadObject("TUQPinguin1.PinguinChar1", class'Mesh'));
    P.LinkMesh(PlayerMesh);
    P.SetCollisionSize(20,20);
}

//PinguinMesh für Sliden
function PinguinSlidingMesh(Pawn P)
{
}

//RobbenMesh für Laufen
function RobbeRunningMesh(Pawn P)
{
	local Mesh PlayerMesh;

	if (P == none)
	    return;

	if(P.Weapon.ItemName=="JetPack"&&P.Weapon.AmmoAmount(0)>0)
	{
	    PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbeJetPack"$figur+1$".TUQRobbe", class'Mesh'));
        P.LinkMesh(PlayerMesh);

        if(farbe==0) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
        if(farbe==1) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Rot.shader.shader", class'Material'));
        if(farbe==2) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gelb.shader.shader", class'Material'));
        if(farbe==3) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gruen.shader.shader", class'Material'));
        if(farbe==4) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Pink.shader.shader", class'Material'));

        P.Skins[1] = Material(DynamicLoadObject("TUQJetPack.shader.shader", class'Material'));
	}
	else
	    if(P.Weapon.ItemName=="SandBag"&&P.Weapon.AmmoAmount(0)>0)
	    {
	        PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbeSandBag"$figur+1$".TUQRobbe", class'Mesh'));
            P.LinkMesh(PlayerMesh);

            if(farbe==0) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
            if(farbe==1) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Rot.shader.shader", class'Material'));
            if(farbe==2) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gelb.shader.shader", class'Material'));
            if(farbe==3) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gruen.shader.shader", class'Material'));
            if(farbe==4) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Pink.shader.shader", class'Material'));

            P.Skins[1] = Material(DynamicLoadObject("TUQSandBag.shader.shader", class'Material'));
	    }
	    else
     	{
            PlayerMesh = Mesh(DynamicLoadObject("TUQRunningRobbe"$figur+1$".TUQRobbe", class'Mesh'));
            P.LinkMesh(PlayerMesh);

            if(farbe==0) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
            if(farbe==1) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Rot.shader.shader", class'Material'));
            if(farbe==2) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gelb.shader.shader", class'Material'));
            if(farbe==3) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Gruen.shader.shader", class'Material'));
            if(farbe==4) P.Skins[0]= Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Pink.shader.shader", class'Material'));
        }
    P.SetCollisionSize(35,3);
}

//RobbenMesh für Sliden
function RobbeSlidingMesh(Pawn P)
{
	local Mesh PlayerMesh;

    if(P.Weapon.ItemName=="JetPack"&&P.Weapon.AmmoAmount(0)>0)
	{
	    PlayerMesh = Mesh(DynamicLoadObject("TUQSlidingRobbeJetPack"$figur+1$".TUQRobbe", class'Mesh'));
        P.LinkMesh(PlayerMesh);
        //P.Skins[0] = Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
        P.Skins[1] = Material(DynamicLoadObject("TUQJetPack.shader.shader", class'Material'));
	}
	else
	    if(P.Weapon.ItemName=="SandBag"&&P.Weapon.AmmoAmount(0)>0)
	    {
	        PlayerMesh = Mesh(DynamicLoadObject("TUQSlidingRobbeSandBag"$figur+1$".TUQRobbe", class'Mesh'));
            P.LinkMesh(PlayerMesh);
            //P.Skins[0] = Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
            P.Skins[1] = Material(DynamicLoadObject("TUQSandBag.shader.shader", class'Material'));
	    }
	    else
     	{
            PlayerMesh = Mesh(DynamicLoadObject("TUQSlidingRobbe"$figur+1$".TUQRobbe", class'Mesh'));
            P.LinkMesh(PlayerMesh);
            //P.Skins[0] = Material(DynamicLoadObject("TUQRobbe"$figur+1$"_Blau.shader.shader", class'Material'));
        }
    P.SetCollisionSize(35,5);
}
*/

function Possess( Pawn aPawn )
{
    super.Possess(aPawn);

    //RobbeRunningMesh(aPawn);
    //GetPseudoTeamNum();
    Walking();
}

// Waffenwechsel führt zu Meshwechsel
/*
function ChangedWeapon()
{
    super.ChangedWeapon();

    if (Pawn != none && Pawn.Weapon != none)
    {
        if(Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)>0&&!bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=true;
        }

        if(((Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="JetPack")&&bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=false;
        }

        if(Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)>0&&!bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=true;
        }

        if(((Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="SandBag")&&bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=false;
        }
    }
}
*/

function EnterStartState()
{
    local name NewState;

    if (bSlide)
        NewState = 'PlayerSliding';
    else
        NewState = 'PlayerWalking';

    log("---------->EnterStartState: "$NewState);
    if (!IsInState(NewState))
        GotoState(NewState);
}

state PlayerPendingTeleport
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

    exec function Jump( optional float F )
    {
    }

    exec function Suicide()
    {
    }

    exec function Fire(optional float F)
    {
    }

    exec function AltFire(optional float F)
    {
        Fire(F);
    }

    exec function ToggleSlideMode()
    {
    }

    function PlayerMove(float DeltaTime)
    {
        UpdateRotation(DeltaTime, 2);
    }

    function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        local vector X,Y,Z;

        bBehindView=true;
        ViewActor = ViewTarget;
        GetAxes(ViewActor.Rotation, X, Y, Z);

        // Translation der Kamera zur gewünschten Position
        CamHeight = CamHeight*0.995 + 150*0.01;
        CamDist = CamDist*0.995 + 250*0.01;

        CameraLocation = ViewActor.Location + CamHeight*Z;
        CalcBehindView(CameraLocation, CameraRotation, CamDist);
    }

    function PlayerTick(float DeltaTime)
    {
        Global.PlayerTick(DeltaTime);

        if (bCountdownEnabled)
        {
            //log("-----> CountDown läuft: "$StartCountdown);
            if (StartCountDown <= 0)
            {
                if (TUQ_Hud(myHUD) != None)
                {
	                TUQ_Hud(myHUD).bTeleportFX = false;
                }
                if (Pawn != none)
                    Pawn.SetPhysics(PHYS_Walking);
                bSlide = false;
                //PlayTeleportEffect(false, true);
                //TeleDest.Accept(Pawn, none);
                ServerTeleport(TUQ_Pawn(Pawn), TeleDest);
                GotoState('PlayerWalking');
            }

            StartCountDown -= DeltaTime;
            //ggf. hier SoundFX
        }
    }

    function EndState()
    {
        if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
        bCollideWorld = false;
    }

    function BeginState()
    {
        //CameraDist = 90.0;
        if ( PlayerReplicationInfo != None )
            PlayerReplicationInfo.SetWaitingPlayer(true);
        bCollideWorld = true;

        StartCountdown = 1.0;
        bCountdownEnabled = true;
        log("-----> PlayerPendingTeleport Begin");

        if (Pawn != none)
        {
            Pawn.SetPhysics(PHYS_None);
            Pawn.Acceleration = vect(0,0,0);
        }

        if (TUQ_Hud(myHUD) != None)
        {
            TUQ_Hud(myHUD).bTeleportFX = true;
        }
    }

Begin:
}

state PlayerFinishWaiting
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

    exec function Jump( optional float F )
    {
    }

    exec function Suicide()
    {
    }

    exec function Fire(optional float F)
    {
    }

    exec function AltFire(optional float F)
    {
        Fire(F);
    }

    function PlayerMove(float DeltaTime)
    {
        //UpdateRotation(DeltaTime, 2);
    }

    function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        local vector X,Y,Z;

        bBehindView=true;
        ViewActor = ViewTarget;
        GetAxes(ViewActor.Rotation, X, Y, Z);

        CameraLocation = ViewActor.Location - 200*X + 100*Z;
    }

    function PlayerTick(float DeltaTime)
    {
        Global.PlayerTick(DeltaTime);

        //Pawn.Acceleration *= 0.9;
    }

    function EndState()
    {
        if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
        bCollideWorld = false;
    }

    function BeginState()
    {
        //CameraDist = 90.0;
        if ( PlayerReplicationInfo != None )
            PlayerReplicationInfo.SetWaitingPlayer(true);
        bCollideWorld = true;

        log("-----> PlayerFinishWaiting Begin");

        if (Pawn != none)
        {
            Pawn.SetPhysics(PHYS_Hovering);
            Pawn.Acceleration = vect(0,0,0);
            Pawn.StopAnimating();
        }
    }

Begin:
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

    function PlayerTick(float DeltaTime)
    {
        //local vector X,Y,Z, HitLoc, HitNorm;
        //local float ScanDist;
        //local actor HitActor;

        Global.PlayerTick(DeltaTime);

        // Mesh auf StaticMeshs tiefer setzen
        /*
        ScanDist = 50.00;
        GetAxes(Pawn.Rotation,X,Y,Z);
        HitActor = Trace(HitLoc, HitNorm, Pawn.Location - ScanDist*Z, Pawn.Location, false);
        if (HitActor != none && HitActor.IsA('StaticMeshActor'))
            Pawn.SetCollisionSize(35, 1);
        */

        if(Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)>0&&!bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=true;
        }

        if(Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)>0&&!bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=true;
        }

        // Meshwechsel wenn Munition leer...
        if(((Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="JetPack")&&bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=false;
        }
        if(((Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="SandBag")&&bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=false;
        }

        //kein Benutzen des JetPacks beim Walking
        if (Pawn.Weapon.IsFiring() && Pawn.Weapon.AmmoAmount(0)>0 && Pawn.Weapon.ItemName=="JetPack")
        {
            //TUQ_JetPack(Pawn.Weapon).StopFire(0);
            //TUQ_JetPack(Pawn.Weapon).StopFire(1);
            TUQ_JetPack(Pawn.Weapon).ImmediateStopFire();
            TUQ_JetPack(Pawn.Weapon).SetAmmo(JetPackAmmo);
            ServerSetAmmo(TUQ_Pawn(Pawn), JetPackAmmo);
        }
        else if (Pawn.Weapon.ItemName=="JetPack")
            JetPackAmmo = Pawn.Weapon.AmmoAmount(0);
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
        NewAccel = aForward*X + aStrafe*Y;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);
        //DoubleClickMove = PlayerInput.CheckForDoubleClickMove(1.1*DeltaTime/Level.TimeDilation);
        DoubleClickMove = DCLICK_None;

        GroundPitch = 0;
        ViewRotation = Rotation;
        if ( Pawn.Physics == PHYS_Walking )
        {
            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
             if ( (bLook == 0)
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
            {
                if ( bLookUpStairs || bSnapToLevel )
                {
                    GroundPitch = FindStairRotation(deltaTime);
                    ViewRotation.Pitch = GroundPitch;
                }
                else if ( bCenterView )
                {
                    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                    if (ViewRotation.Pitch > 32768)
                        ViewRotation.Pitch -= 65536;
                    ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                    if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                        ViewRotation.Pitch = -249;
                }
            }
        }
        else
        {
            if ( !bKeyboardLook && (bLook == 0) && bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                    ViewRotation.Pitch = -249;
            }
        }
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

        // Tweak!!
        if (bSlide)
        {
            bPressedJump = true;
            if (StateChangeTimer <= 0)
                GotoState('PlayerSliding');
            StateChangeTimer -= DeltaTime;
        }

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }
}

// Sliding... die ganz neue Art der Fortbewegung
state PlayerSliding
{
ignores SeePlayer, HearNoise, Bump;

    event bool NotifyHitWall(vector HitNormal, actor HitActor)
    {
        //Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetPhysics(PHYS_Hovering);
        Pawn.SetBase(HitActor, HitNormal);
        return true;
    }

    function bool NotifyLanded(vector HitNormal)
    {
        //Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetPhysics(PHYS_Hovering);
        return bUpdating;
    }

    function PlayerMove(float DeltaTime)
    {
        local rotator OldRotation, tempRotation;
        local vector X,Y,Z, tempX, tempY, tempZ;
        local vector OldSlideForce, OldStrafeForce, FloorNormal;
        local vector NewAccel, SetAccel, SlideAccel, StrafeAccel, MoveAccel;
        local rotator FwdDir;

        local TUQ_SandPickUp SandPickup;

        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        NewAccel = vect(0,0,0);
        GetAxes(Pawn.Rotation,X,Y,Z);
        //FloorNormal = Pawn.Floor;
        FloorNormal = HoverFloor;
        OldSlideForce = TUQ_Pawn(Pawn).SlideForce;
        OldStrafeForce = TUQ_Pawn(Pawn).StrafeForce;

        tempRotation = Pawn.Rotation;
        tempRotation.Roll = 0;
        GetAxes(tempRotation, tempX, tempY, tempZ);

        FwdDir = rotator(X);
        FwdDir.Pitch = 0;

        // Berechnung der Kräfte
        //**********************************************************************
        TUQ_Pawn(Pawn).SlideForce = OldSlideForce*0.950 + (vector(FwdDir) dot FloorNormal)*X*30;
        TUQ_Pawn(Pawn).StrafeForce = OldStrafeForce*0.900 + aStrafe*Y*0.008 + (tempY dot FloorNormal)*Y*50;

        // Berechnung der Beschleunigung
        //**********************************************************************
        SlideAccel = TUQ_Pawn(Pawn).SlideForce / TUQ_Pawn(Pawn).SlideMass;
        StrafeAccel = TUQ_Pawn(Pawn).StrafeForce / TUQ_Pawn(Pawn).SlideMass;
        // Einfluss der Pawnausrichtung auf die Beschleunigung
        SlideAccel = (SlideAccel * 0.6) + (X * VSize(SlideAccel) * 0.4);

        // Beschleunigen und Bremsen mittels Vorwärts/Rückwärts-Tasten
        MoveAccel = aForward * X * 0.02;
        // der Bremseffekt
        if (VSize(MoveAccel) > 0 && (MoveAccel dot X) < 0)
            MoveAccel = -1*(SlideAccel + StrafeAccel);

        // Setzen der Beschleunigung
        //**********************************************************************
        NewAccel += SlideAccel;
        NewAccel += StrafeAccel;
        NewAccel += MoveAccel;

        // Abbremsen beim Verlassen von PlayerSliding
        if (bLeavingState)
            NewAccel = -1000 * Pawn.Velocity;

        SetAccel = NewAccel;

        // Sandsack
        /*
        if(TUQ_Pawn(Pawn).bSandBraking)
        {
            SetAccel=-1000*X;
            if (VSize(Pawn.Velocity)<250)
                TUQ_Pawn(Pawn).bSandBraking=false;
        }
        */
        foreach Pawn.RadiusActors(class'TUQ_SandPickUp', SandPickup, 20, Pawn.Location)
        {
            //log("--------------> Sand generell");
            if (VSize(Pawn.Velocity)>250)
            {
                //log("--------------> Sand mit if");
                SetAccel = -1000 * X;
            }
        }

        // JetPack
        if (Pawn.Weapon.IsFiring() && Pawn.Weapon.AmmoAmount(0)>0 && Pawn.Weapon.ItemName=="JetPack")
        {
            if (bMakeNewTrail)
            {
                ServerDoJetPackFX(TUQ_Pawn(Pawn));
                ClientDoJetPackFX(TUQ_Pawn(Pawn));
                bMakeNewTrail = false;
            }
            //PlaySound(FireSound);
            SetAccel+=1500*X;
            //TUQ_Pawn(Pawn).bSandBraking=false;
        }
        else //if (!bMakeNewTrail)
        {
            ServerKillJetPackFX(TUQ_Pawn(Pawn));
            ClientKillJetPackFX(TUQ_Pawn(Pawn));
            bMakeNewTrail = true;
        }

        // Update rotation.
        OldRotation = Rotation;
        UpdateSlideRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, SetAccel, DCLICK_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, SetAccel, DCLICK_None, OldRotation - Rotation);
        bPressedJump = false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn == None )
			return;

		if (Pawn.Acceleration != NewAccel)
            Pawn.Acceleration = NewAccel;
    }

    function PlayerTick(float DeltaTime)
    {
        local vector X,Y,Z;
        local int vel;

        GetAxes(Pawn.Rotation,X,Y,Z);

        Global.PlayerTick(DeltaTime);

        PlaySlideAnim();
        SetMotionBlurAmount();
        GetHoverFloor();

        if(Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)>0&&!bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=true;
        }

        if(Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)>0&&!bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=true;
        }

        // Meshwechsel wenn Munition leer...
        if(((Pawn.Weapon.ItemName=="JetPack"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="JetPack")&&bJetPack)
        {
            if(bSlide)Sliding();else Walking();
            bJetPack=false;
        }
        if(((Pawn.Weapon.ItemName=="SandBag"&&Pawn.Weapon.AmmoAmount(0)==0)||Pawn.Weapon.ItemName!="SandBag")&&bSandBag)
        {
            if(bSlide)Sliding();else Walking();
            bSandBag=false;
        }

        // State verlassen, sobald man langsam genug ist
        if (bLeavingState && VSize(Pawn.Velocity) <= 500)
            GotoState('PlayerWalking');

        // Spezielle Pinguin-Animation beim Wechsel zu Walking
        if (bLeavingState && VSize(Pawn.Velocity) <= 800 && rasse == 1)
            Pawn.PlayAnim('Jump_Takeoff');

        // Boing! Effekt
        vel=VSize(Pawn.Velocity);
        if(oldVel-750>vel && !FastTrace(Pawn.Location + 128*X, Pawn.Location))
        {
            ServerHitFX(Pawn.Location);

            if(rasse==0)
                Pawn.PlaySound(sound(DynamicLoadObject("TUQRobbe"$figur+1$"Sounds.R"$figur+1$"Bump",class'sound')),SLOT_Pain,1,false);
            if(rasse==1)
                Pawn.PlaySound(sound(DynamicLoadObject("TUQPingu"$figur+1$"Sounds.P"$figur+1$"Bump",class'sound')),SLOT_Pain,1,false);

            Pawn.PlaySound(sound'TUQSounds.Sounds.Uhu',SLOT_Talk,1,false);
            Pawn.PlaySound(sound'TUQSounds.Sounds.Birds',SLOT_Misc,1,false);
        }
        oldVel=vel;
    }

    function PlaySlideAnim()
    {
        // Neue Eingabe -> alte Animation abbrechen
        if (aForward != oldForward || aStrafe != oldStrafe)
            Pawn.StopAnimating();

        // Idle - wenn keine Tasten gedrückt werden
        if (aForward == 0 && aStrafe == 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('RunF');  //sollte 'Idle' heißen!

        // TurnLeft - nach links lehnen
        if (aForward == 0 && aStrafe < 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('TurnL');

        // TurnRight - nach rechts lehnen
        if (aForward == 0 && aStrafe > 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('TurnR');

        // AccelForward - vorwärts paddeln zum Beschleunigen
        if (aForward > 0 && aStrafe == 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('RunF');

        // AccelLeft - paddeln und dabei nach links lehnen
        if (aForward > 0 && aStrafe < 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('RunL');

        // AccelRight - paddeln und dabei nach rechts lehnen
        if (aForward > 0 && aStrafe > 0 && !Pawn.IsAnimating())
            Pawn.PlayAnim('RunR');

        // Break - bremsen allgemein
        if (aForward < 0 && !Pawn.IsAnimating())
        {
            if (rasse == 0)
                Pawn.PlayAnim('Jump_Land');
            else if (rasse == 1)
                Pawn.PlayAnim('RunB');
        }

        // Eingabe speichern
        oldForward = aForward;
        oldStrafe = aStrafe;
    }


    // Legt die Stärke des Motion-Blur anhand der Geschwindigkeit fest
    function SetMotionBlurAmount()
    {
        local int Speed;
        local float tempSpeed;

        if (CamFX == none)
            return;

        tempSpeed = (VSize(Pawn.Velocity) / 52.5) * 3.6;
        Speed = tempSpeed;

        if (Speed > 254)
            Speed = 254;
        MotionBlur(CamFX).BlurAlpha = 255 - Speed;
    }

    // Scan der Bodenneigung mit Trace
    function GetHoverFloor()
    {
        local vector X,Y,Z, HitLoc, HitNorm;
        local float ScanDist;
        local actor HitActor;

        ScanDist = 50.00;
        GetAxes(Pawn.Rotation,X,Y,Z);
        HitActor = Trace(HitLoc, HitNorm, Pawn.Location - ScanDist*Z, Pawn.Location, false);

        if (HitActor != none && HitActor.IsA('StaticMeshActor'))
        {
            if (HoverFloor != vect(0,0,1) && Pawn.Floor == vect(0,0,1))
            {
                TickCount++;
                if (TickCount >= 20 && HitNorm == vect(0,0,1))
                {
                    HoverFloor = Pawn.Floor;
                    TickCount = 0;
                }
            }
            else
            {
                HoverFloor = Pawn.Floor;
                TickCount = 0;
            }
            //Pawn.SetCollisionSize(35,2);
            //TickCount2 = 0;
            //log("du bist aufm StaticMesh!");
        }
        //else if (HitActor != none && !HitActor.IsA('StaticMeshActor'))
        //    Pawn.SetCollisionSize(35,5);
        else
        {
            if (HitNorm != vect(0,0,0))
                HoverFloor = HitNorm;
            else
                HoverFloor = vect(0,0,1);
            /*
            if (TickCount2 == 20)
            {
                Pawn.SetCollisionSize(35,5);
                TickCount2++;
            }
            else if (TickCount2 < 20)
                TickCount2++;
            */
        }
        // Setzen der neuen Base notwendig bei PHYS_Hovering
        if (HitActor != none && Pawn.Physics == PHYS_Hovering)
            Pawn.SetBase(HitActor, HitNorm);
    }

    function BeginState()
    {
        //Pawn.SetPhysics(PHYS_Walking);
        //Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetPhysics(PHYS_Hovering);

        if ( Role < ROLE_Authority )
             ServerSetPhysics(Pawn.Physics);

        // Geschwindigkeitsbegrenzungen überschreiben
        Pawn.GroundSpeed = 3000.000000;
        Pawn.AirSpeed = 3000.000000;

        // Motion-Blur anschalten
        if (!bHasCameraEffect)
        {
	        CamFX = FindCameraEffect(class'MotionBlur');
	        bHasCameraEffect = true;
        }

        Pawn.bCrawler = true;
        OldFloor = vect(0,0,1);
        GetAxes(Pawn.Rotation,ViewX,ViewY,ViewZ);
        HoverFloor = vect(0,0,1);
        bLeavingState = false;

        Sliding();

        //log("---> "$Level.TimeSeconds$" ---> Slide begin !!!!");
    }

    function EndState()
    {
        Pawn.SetPhysics(PHYS_Walking);
        if ( Role < ROLE_Authority )
             ServerSetPhysics(Pawn.Physics);

        // Geschwindigkeitsbegrenzungen zurücksetzen
        Pawn.GroundSpeed = 440.000000;
        Pawn.AirSpeed = 440.000000;

        // SlideForce löschen
        TUQ_Pawn(Pawn).SlideForce = vect(0,0,0);
        // StrafeForce löschen
        TUQ_Pawn(Pawn).StrafeForce = vect(0,0,0);

        // Motion-Blur abschalten
	    MotionBlur(CamFX).BlurAlpha = 255;

        Pawn.bCrawler = Pawn.Default.bCrawler;

        Walking();

        // JetPack Partikel entfernen
        ServerKillJetPackFX(TUQ_Pawn(Pawn));
        ClientKillJetPackFX(TUQ_Pawn(Pawn));
        bMakeNewTrail = true;

        // JetPack Munition speichern...
        if (Pawn.Weapon.ItemName=="JetPack")
            JetPackAmmo = Pawn.Weapon.AmmoAmount(0);

        //log("---> "$Level.TimeSeconds$" ---> Slide end !!!!");
    }
}

//******************************************************************************
// Replication des aktuellen Physics Modus vom Client an den Server
//******************************************************************************
function ServerSetPhysics(EPhysics newPhysics)
{
    if (Pawn != None)
        Pawn.SetPhysics(newPhysics);
    else
        SetPhysics(newPhysics);
}

//******************************************************************************
// MeshUpdate für alle Clients
//******************************************************************************
function ServerSetMeshUpdate()
{
    local Controller P;
	local TUQ_Controller ClientPlayer;

	log("--------------------------> ServerSetMeshUpdate!");

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		ClientPlayer = TUQ_Controller(P);

		if (ClientPlayer != None)
		{
		    //ClientPlayer.ClientSetMesh(TUQ_Pawn(ClientPlayer.Pawn));
		}
    }
}

//******************************************************************************
// Generiert den JetPack Partikeleffekt für alle Clients
//******************************************************************************
function ServerDoJetPackFX(TUQ_Pawn P)
{
    local Controller C;
	local TUQ_Controller ClientPlayer;

	log("--------------------------> ServerDoJetPackFX!");

	for(C = Level.ControllerList; C != None; C = C.nextController)
	{
		ClientPlayer = TUQ_Controller(C);

		if (ClientPlayer != None && TUQ_Pawn(ClientPlayer.Pawn) != P)
		{
		    ClientPlayer.ClientDoJetPackFX(P);
		}
    }
}

//******************************************************************************
// Enfernt den JetPack Partikeleffekt für alle Clients
//******************************************************************************
function ServerKillJetPackFX(TUQ_Pawn P)
{
    local Controller C;
	local TUQ_Controller ClientPlayer;

	//log("--------------------------> ServerKillJetPackFX!");

	for(C = Level.ControllerList; C != None; C = C.nextController)
	{
		ClientPlayer = TUQ_Controller(C);

		if (ClientPlayer != None && TUQ_Pawn(ClientPlayer.Pawn) != P)
		{
		    ClientPlayer.ClientKillJetPackFX(P);
		}
    }
}

//******************************************************************************
// Replication des Ready-Signals vom Client an den Server
//******************************************************************************
function ServerSetReady(bool isReady)
{
    IsReadyToStart = isReady;
}

//******************************************************************************
// Mitteilung an den Server, welches Mesh für den Spieler gesetzt werden soll
//******************************************************************************
function ServerSetMesh(string PName, bool isSliding, int Species, int Dress, int TexColor, string Weapon)
{
    local Controller P;
	local TUQ_Controller ClientPlayer;

	log("--------------------------> ServerSetMesh! für "$PName);

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		ClientPlayer = TUQ_Controller(P);

		if (ClientPlayer != None)
		{
		    ClientPlayer.ClientSetMesh(PName, isSliding, Species, Dress, TexColor, Weapon);
		}
    }
}

function ServerHitFX(vector Pos)
{
    local Controller P;

    for (P=Level.ControllerList; P!=None; P=P.NextController )
        if (TUQ_Controller(P) != None)
            TUQ_Controller(P).ClientHitFX(Pos);
}

function ServerSetInitialMesh()
{
    local Controller P;

    for (P=Level.ControllerList; P!=None; P=P.NextController)
        if (TUQ_Controller(P) != None)
            TUQ_Controller(P).ClientSetInitialMesh();
}

function ServerTeleport(TUQ_Pawn P, TUQ_CheckpointTeleporter Dest)
{
    PlayTeleportEffect(false, true);
    Dest.Accept(Pawn, none);
    //TUQ_Controller(P.Controller).ClientGotoState('PlayerWalking', 'Begin');
}

function ServerSetAmmo(TUQ_Pawn P, int Ammo)
{
    TUQ_JetPack(P.Weapon).SetAmmo(Ammo);
}

function ClientSetInitialMesh()
{
    Walking();
}

function ClientSetMesh(string PName, bool isSliding, int Species, int Dress, int TexColor, string Weapon)
{
    local TUQ_Pawn OtherPawn;
	local string MeshName, TextureName, Modus, SpeciesName, ColorName;
	local Mesh PlayerMesh;

    log("-----> ClientSetMesh! für "$PName$" Slide="$isSliding$" Rasse="$Species$" Figur="$Dress$" Farbe="$TexColor$" Waffe:"$Weapon);

    foreach AllActors(class'TUQ_Pawn', OtherPawn)
    {
		log("-----> aktueller Pawn: "$OtherPawn.GetHumanReadableName()$"   gesuchter Pawn: "$PName);

		if (OtherPawn.GetHumanReadableName() == PName)
		{
		    // passendes Mesh und passende Textur wählen...

            if (isSliding)
		        Modus = "Sliding";
            else
                Modus = "Running";

            Switch (Species)
            {
                Case 0:
                    SpeciesName = "Robbe";
                    break;
                Case 1:
                    SpeciesName = "Pingu";
                    break;
                Default:
                    SpeciesName = "Robbe";
                    break;
            }

            Switch (TexColor)
            {
                Case 0:
                    ColorName = "_Blau";
                    break;
                Case 1:
                    ColorName = "_Rot";
                    break;
                Case 2:
                    ColorName = "_Gelb";
                    break;
                Case 3:
                    ColorName = "_Gruen";
                    break;
                Case 4:
                    ColorName = "_Pink";
                    break;
                Default:
                    ColorName = "_Blau";
                    break;
            }
	        //"TUQRunningRobbeJetPack"$figur+1$".TUQRobbe"
	        MeshName = "TUQ"$Modus$SpeciesName$Weapon$Dress+1$".TUQ"$SpeciesName;
            log("MeshString:"$MeshName);
            PlayerMesh = Mesh(DynamicLoadObject(MeshName, class'Mesh'));
            OtherPawn.LinkMesh(PlayerMesh);

            //"TUQRobbe"$figur+1$"_Blau.shader.shader"
            TextureName = "TUQ"$SpeciesName$Dress+1$ColorName$".shader.shader";
            log("TextureString1:"$TextureName);
            OtherPawn.Skins[0] = Material(DynamicLoadObject(TextureName, class'Material'));

            if (Weapon != "")
            {
                //"TUQSandBag.shader.shader"
                TextureName = "TUQ"$Weapon$".shader.shader";
                log("TextureString2:"$TextureName);
                OtherPawn.Skins[1] = Material(DynamicLoadObject(TextureName, class'Material'));
		    }

            // Kollisionsparameter anpassen
            if (isSliding)
                OtherPawn.SetCollisionSize(35,5);
            else
                OtherPawn.SetCollisionSize(35,3);

            // Slide-Animation abspielen
            if (Role == ROLE_Authority && isSliding)
                OtherPawn.PlaySlide();

            if (Role < ROLE_Authority && isSliding)
            {
                //log("-----------------> ClientSetMesh: Slide-Animation wird abgespielt");
                //OtherPawn.SetPhysics(PHYS_Walking);
                //OtherPawn.PlaySlide();
                OtherPawn.AirAnims[0]='RunF';
                OtherPawn.AirAnims[1]='RunF';
                OtherPawn.AirAnims[2]='RunF';
                OtherPawn.AirAnims[3]='RunF';
                OtherPawn.TakeoffAnims[0]='RunF';
                OtherPawn.TakeoffAnims[1]='RunF';
                OtherPawn.TakeoffAnims[2]='RunF';
                OtherPawn.TakeoffAnims[3]='RunF';
                OtherPawn.LandAnims[0]='RunF';
                OtherPawn.LandAnims[1]='RunF';
                OtherPawn.LandAnims[2]='RunF';
                OtherPawn.LandAnims[3]='RunF';
                OtherPawn.AirStillAnim='RunF';
                OtherPawn.TakeoffStillAnim='RunF';
            }
            else if (Role < ROLE_Authority)
            {
                OtherPawn.AirAnims[0]='JumpF_Mid';
                OtherPawn.AirAnims[1]='JumpB_Mid';
                OtherPawn.AirAnims[2]='JumpL_Mid';
                OtherPawn.AirAnims[3]='JumpR_Mid';
                OtherPawn.TakeoffAnims[0]='JumpF_Takeoff';
                OtherPawn.TakeoffAnims[1]='JumpB_Takeoff';
                OtherPawn.TakeoffAnims[2]='JumpL_Takeoff';
                OtherPawn.TakeoffAnims[3]='JumpR_Takeoff';
                OtherPawn.LandAnims[0]='JumpF_Land';
                OtherPawn.LandAnims[1]='JumpB_Land';
                OtherPawn.LandAnims[2]='JumpL_Land';
                OtherPawn.LandAnims[3]='JumpR_Land';
                OtherPawn.AirStillAnim='Jump_Mid';
                OtherPawn.TakeoffStillAnim='Jump_Takeoff';
            }

            break;
        }
    }
}

//******************************************************************************
// Generiert den JetPack Partikeleffekt auf diesem Client
//******************************************************************************
function ClientDoJetPackFX(TUQ_Pawn P)
{
    local vector X,Y,Z;

	log("--------------------------> ClientDoJetPackFX!");
    GetAxes(P.Rotation,X,Y,Z);
    P.JetPackTrailLeft = Spawn(class'TUQ_JetPackTrail',,,P.Location + 15*X - 15*Y);
    P.JetPackTrailRight = Spawn(class'TUQ_JetPackTrail',,,P.Location + 15*X + 15*Y);
    P.JetPackTrailLeft.Setbase(P);
    P.JetPackTrailRight.Setbase(P);
}

//******************************************************************************
// Enfernt den JetPack Partikeleffekt auf diesem Client
//******************************************************************************
function ClientKillJetPackFX(TUQ_Pawn P)
{
	//log("--------------------------> ClientKillJetPackFX!");
    if (P.JetPackTrailLeft != none)
        P.JetPackTrailLeft.Kill();
    if (P.JetPackTrailRight != none)
        P.JetPackTrailRight.Kill();
}


//******************************************************************************
// Zeigt einen Wartebildschirm auf diesem Client
//******************************************************************************
function ClientShowWaiting(byte NeededPlayers)
{
    ReceiveLocalizedMessage( class'TUQ_WaitingMessage', NeededPlayers );
}

//******************************************************************************
// Setzt Finished-Variable auf diesem Client
//******************************************************************************
function ClientSetFinished(bool Finished)
{
    //log("----------> ClientSetFinished "$Finished$" für "$GetHumanReadableName());
    bHasFinished = Finished;
    //log("----------> bHasFinished "$Finished$" für "$GetHumanReadableName());
}

//******************************************************************************
// Startet den Final Countdown auf diesem Client
//******************************************************************************
function ClientFinalCountdown()
{
    StartCountDown = 5.0;
    bCountDownEnabled = true;
}

function ClientStartTimer()
{
    if (TUQ_Hud(myHud) != none)
        TUQ_Hud(myHud).StartTimer();
}

function ClientStopTimer()
{
    if (TUQ_Hud(myHud) != none)
        TUQ_Hud(myHud).StopTimer();
}

function ClientPlayWallFX(vector WallPos)
{
    if (TUQ_Hud(myHud) != none)
    {
        TUQ_Hud(myHud).bWallFX = true;
        TUQ_Hud(myHud).WallPosition = WallPos + 200*vect(0,0,1);
    }
}

function ClientHitFX(vector HitPos)
{
    if (TUQ_Hud(myHud) != none)
        TUQ_Hud(myHud).bHitFX = true;
        TUQ_Hud(myHud).HitPos = HitPos;
}

function ClientSetTeleporter(TUQ_CheckpointTeleporter Dest)
{
    TeleDest = Dest;
}

function ClientSetPlace(int P)
{
    myPlace = P;
}

function ClientSetRanking(int Pos, string PlayerName, float Time)
{
    Switch (Pos)
    {
        Case 1:
            FirstName = PlayerName;
            FirstTime = Time;
            break;
        Case 2:
            SecondName = PlayerName;
            SecondTime = Time;
            break;
        Case 3:
            ThirdName = PlayerName;
            ThirdTime = Time;
            break;
        Case 4:
            FourthName = PlayerName;
            FourthTime = Time;
            break;
    }
}
//******************************************************************************
// Replication von bSandBreaking an den Server
//******************************************************************************
/*
function ServerSetSandBreaking(bool Breaking)
{
    log("---------------> Breaking! "$Breaking);
    if (TUQ_Pawn(Pawn) != None)
    {
        TUQ_Pawn(Pawn).bSandBraking = Breaking;
        log("---------------> Breaking2! "$Breaking);
    }
}
*/

//******************************************************************************
// Replicate this client's desired movement to the server.
// Und das Ganze für den Slide-Modus, d.h. wir übertragen zusätzlich die
// Geschwindigkeit aus PlayerMove()
// Copy&Paste-Vorlage: ReplicateMove() aus PlayerController.uc
//******************************************************************************
function ReplicateMove
(
    float DeltaTime,
    vector NewAccel,
    eDoubleClickDir DoubleClickMove,
    rotator DeltaRot
)
{
    local SavedMove NewMove, OldMove, AlmostLastMove, LastMove;
    local byte ClientRoll;
    local float OldTimeDelta, NetMoveDelta;
    local int OldAccel;
    local vector BuildAccel, AccelNorm, MoveLoc;
	local bool bPendingJumpStatus;

    //log(" ======== ReplicateMove aufgerufen ======== ");

	// find the most recent move, and the most recent interesting move
    if ( SavedMoves != None )
    {
        log(" ======== "$SavedMoves.TimeStamp$" ReplicateMove: SavedMoves existieren! ======== ");

        LastMove = SavedMoves;
        AlmostLastMove = LastMove;
        AccelNorm = Normal(NewAccel);
        while ( LastMove.NextMove != None )
        {
            // find most recent interesting move to send redundantly
            if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
                || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
                OldMove = LastMove;
            AlmostLastMove = LastMove;
            LastMove = LastMove.NextMove;
        }
        if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
            || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
            OldMove = LastMove;
    }

    // Get a SavedMove actor to store the movement in.
	NewMove = GetFreeMove();
	if ( NewMove == None )
	{
	    log(" ======== ReplicateMove abgebrochen: GetFreeMove fehlgeschlagen! ======== ");
		return;
	}
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

    // Simulate the movement locally.
    bDoubleJump = false;
    ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);

	// see if the two moves could be combined
	if ( (PendingMove != None) && (Pawn != None) && (Pawn.Physics == PHYS_Walking)
		&& (NewAccel != vect(0,0,0))
		&& (PendingMove.SavedPhysics == PHYS_Walking)
		&& !PendingMove.bPressedJump && !NewMove.bPressedJump
		&& (PendingMove.bRun == NewMove.bRun)
		&& (PendingMove.bDuck == NewMove.bDuck)
		&& (PendingMove.bDoubleJump == NewMove.bDoubleJump)
		&& (PendingMove.DoubleClickMove == DCLICK_None)
		&& (NewMove.DoubleClickMove == DCLICK_None)
		&& ((Normal(PendingMove.Acceleration) Dot Normal(NewAccel)) > 0.99) )
	{
	    log(" ======== ReplicateMove: PendingMove & NewMove werden kombiniert! ======== ");

		Pawn.SetLocation(PendingMove.GetStartLocation());
		Pawn.Velocity = PendingMove.StartVelocity;
		if ( PendingMove.StartBase != Pawn.Base);
			Pawn.SetBase(PendingMove.StartBase);
		Pawn.Floor = PendingMove.StartFloor;
		NewMove.Delta += PendingMove.Delta;

		// remove pending move from move list
		if ( LastMove == PendingMove )
		{
			if ( SavedMoves == PendingMove )
			{
				SavedMoves.NextMove = FreeMoves;
				FreeMoves = SavedMoves;
				SavedMoves = None;
			}
			else
			{
				PendingMove.NextMove = FreeMoves;
				FreeMoves = PendingMove;
				if ( AlmostLastMove != None )
				{
					AlmostLastMove.NextMove = None;
					LastMove = AlmostLastMove;
				}
			}
			FreeMoves.Clear();
		}
		PendingMove = None;
	}

    if ( Pawn != None )
    {
        Pawn.AutonomousPhysics(NewMove.Delta);
        //log(" ======== ReplicateMove: Pawn-Physics... ======== ");
    }
    else
    {
        AutonomousPhysics(DeltaTime);
        //log(" ======== ReplicateMove: Controller-Physics... ======== ");
    }
    NewMove.PostUpdate(self);
    log(" ======== ReplicateMove: "$NewMove.TimeStamp$" NewMove: SLocation: "$NewMove.SavedLocation$" ; StartVelocity: "$NewMove.StartVelocity$" ; SavedVelocity: "$NewMove.SavedVelocity$" ; Accel: "$NewMove.Acceleration$" ======== ");

	if ( SavedMoves == None )
		SavedMoves = NewMove;
	else
		LastMove.NextMove = NewMove;

	if ( PendingMove == None )
	{
		// Decide whether to hold off on move
		if ( (Player.CurrentNetSpeed > 10000) && (GameReplicationInfo != None) && (GameReplicationInfo.PRIArray.Length <= 10) )
			NetMoveDelta = 0;	// full rate
		else
			NetMoveDelta = FMax(0.0222,2 * Level.MoveRepSize/Player.CurrentNetSpeed);

		if ( Level.TimeSeconds - ClientUpdateTime < NetMoveDelta )
		{
			PendingMove = NewMove;
            //log(" ======== ReplicateMove: Neuer Move als PendingMove gesetzt ======== ");
			return;
		}
	}

    ClientUpdateTime = Level.TimeSeconds;

    // check if need to redundantly send previous move
    if ( OldMove != None )
    {
        // old move important to replicate redundantly
        OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
        BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
        OldAccel = (CompressAccel(BuildAccel.X) << 23)
                    + (CompressAccel(BuildAccel.Y) << 15)
                    + (CompressAccel(BuildAccel.Z) << 7);
        if ( OldMove.bRun )
            OldAccel += 64;
        if ( OldMove.bDoubleJump )
            OldAccel += 32;
        if ( OldMove.bPressedJump )
            OldAccel += 16;
        OldAccel += OldMove.DoubleClickMove;
    }

    // Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
    if ( PendingMove != None )
    {
		if ( PendingMove.bPressedJump )
			bJumpStatus = !bJumpStatus;
		bPendingJumpStatus = bJumpStatus;
	}
    if ( NewMove.bPressedJump )
         bJumpStatus = !bJumpStatus;

    if ( Pawn == None )
    {
        MoveLoc = Location;
        log(" ======== ReplicateMove: Controller-Location... ======== ");
    }
    else
    {
        MoveLoc = Pawn.Location;
        //log(" ======== ReplicateMove: Pawn-Location... ======== ");
    }

    CallServerMove
    (
        NewMove.TimeStamp,
        NewMove.Acceleration * 10,
        MoveLoc,
        NewMove.bRun,
        NewMove.bDuck,
        bPendingJumpStatus,
        bJumpStatus,
        NewMove.bDoubleJump,
        NewMove.DoubleClickMove,
        ClientRoll,
        (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
        OldTimeDelta,
        OldAccel
    );
	PendingMove = None;
}


//******************************************************************************
// CallServerSlideMove
// Für den Slide-Modus, d.h. wir übertragen zusätzlich die Geschwindigkeit
// aus PlayerMove()
// Copy&Paste-Vorlage: CallServerMove() aus PlayerController.uc
//******************************************************************************
function CallServerMove
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbPendingJumpStatus,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
	local byte PendingCompress;
	local bool bCombine;

    //log(" ======== "$TimeStamp$" CallServerMove aufgerufen! ======== ");

	if ( PendingMove != None )
	{

        log(" ======== "$TimeStamp$" CallServerMove: PendingMove wird gesendet ======== ");

		if ( PendingMove.bRun )
			PendingCompress = 1;
		if ( PendingMove.bDuck )
			PendingCompress += 2;
		if ( NewbPendingJumpStatus )
			PendingCompress += 4;
		if ( PendingMove.bDoubleJump )
			PendingCompress += 8;
		if ( NewbRun )
			PendingCompress += 16;
		if ( NewbDuck )
			PendingCompress += 32;
		if ( NewbJumpStatus )
			PendingCompress += 64;
		if ( NewbDoubleJump )
			PendingCompress += 128;

		// send two moves simultaneously
		if ( (InAccel == vect(0,0,0))
			&& (PendingMove.StartVelocity == vect(0,0,0))
			&& (DoubleClickMove == DCLICK_None)
			&& (PendingMove.Acceleration == vect(0,0,0)) && (PendingMove.DoubleClickMove == DCLICK_None) && !PendingMove.bDoubleJump )
		{
			if ( Pawn == None )
				bCombine = (Velocity == vect(0,0,0));
			else
				bCombine = (Pawn.Velocity == vect(0,0,0));

			if ( bCombine )
			{
                log(" ======== "$TimeStamp$" CallServerMove: ShortServerMove kombiniert ======== ");
				ShortServerMove
				(
					TimeStamp,
					ClientLoc,
					NewbRun,
					NewbDuck,
					NewbJumpStatus,
					ClientRoll,
					View
				);
				return;
			}
		}

		if ( OldTimeDelta == 0 )
		{
            log(" ======== "$TimeStamp$" CallServerMove: DualServerMove (OTD == 0) ======== ");
			DualServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.Acceleration * 10,
				PendingCompress,
				PendingMove.DoubleClickMove,
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				InAccel,
				ClientLoc,
				DoubleClickMove,
				ClientRoll,
				View
			);
		}
		else
		{
            log(" ======== "$TimeStamp$" CallServerMove: DualServerMove ======== ");
			DualServerMove
			(
				PendingMove.TimeStamp,
				PendingMove.Acceleration * 10,
				PendingCompress,
				PendingMove.DoubleClickMove,
				(32767 & (PendingMove.Rotation.Pitch/2)) * 32768 + (32767 & (PendingMove.Rotation.Yaw/2)),
				TimeStamp,
				InAccel,
				ClientLoc,
				DoubleClickMove,
				ClientRoll,
				View,
				OldTimeDelta,
				OldAccel
			);
		}
	}
    else if ( (InAccel == vect(0,0,0)) && (DoubleClickMove == DCLICK_None) && !NewbDoubleJump )
    {
        log(" ======== "$TimeStamp$" CallServerMove: ShortServerMove ======== ");
        ShortServerMove
        (
            TimeStamp,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            ClientRoll,
            View
        );
    }
    else if ( OldTimeDelta == 0 )
    {
        log(" ======== "$TimeStamp$" CallServerMove: ServerMove (OTD == 0) ======== ");
        ServerMove
        (
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View
        );
    }
    else
    {
        log(" ======== "$TimeStamp$" CallServerMove: ServerMove ======== ");
        ServerMove
        (
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View,
            OldTimeDelta,
            OldAccel
        );
    }
}

//******************************************************************************
// DualServerSlideMove, enthält Client Movement für zwei Moves
// Für den Slide-Modus, d.h. wir übertragen zusätzlich die Geschwindigkeit
// aus PlayerMove()
// Copy&Paste-Vorlage: DualServerMove() aus PlayerController.uc
//******************************************************************************
function DualServerMove
(
	float TimeStamp0,
	vector InAccel0,
	byte PendingCompress,
	eDoubleClickDir DoubleClickMove0,
	int View0,
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
	local bool NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,
				NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump;

	NewbRun0 = (PendingCompress & 1) != 0;
	NewbDuck0 = (PendingCompress & 2) != 0;
	NewbJumpStatus0 = (PendingCompress & 4) != 0;
	NewbDoubleJump0 = (PendingCompress & 8) != 0;
	NewbRun = (PendingCompress & 16) != 0;
	NewbDuck = (PendingCompress & 32) != 0;
	NewbJumpStatus = (PendingCompress & 64) != 0;
	NewbDoubleJump = (PendingCompress & 128) != 0;

    ServerMove(TimeStamp0,InAccel0,vect(0,0,0),NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,DoubleClickMove0,
			ClientRoll,View0);
	if ( ClientLoc == vect(0,0,0) )
		ClientLoc = vect(0.1,0,0);
    ServerMove(TimeStamp,InAccel,ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump,DoubleClickMove,ClientRoll,View,OldTimeDelta,OldAccel);
}

//******************************************************************************
// ServerMove()
// - replicated function sent by client to server - contains client movement.
// Copy&Paste-Vorlage: ServerMove() aus PlayerController.uc
//******************************************************************************
function ServerMove
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
    local float DeltaTime, OldTimeStamp;
    local rotator DeltaRot, Rot, ViewRot;
    local vector Accel;
    local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump, OldbRun, OldbDoubleJump;
    local eDoubleClickDir OldDoubleClickMove;
    local float clientErr;
    local vector LocDiff;

    // If this move is outdated, discard it.
    if ( CurrentTimeStamp >= TimeStamp )
    {
        log(" ======== "$TimeStamp$" ServerMove: Move outdated! ======== ");
        return;
    }

	if ( AcknowledgedPawn != Pawn )
	{
        log(" ======== "$TimeStamp$" ServerMove: falscher Pawn! (ClientRestart) ======== ");
		OldTimeDelta = 0;
		InAccel = vect(0,0,0);
		GivePawn(Pawn);
	}

    // if OldTimeDelta corresponds to a lost packet, process it first
    if (  OldTimeDelta != 0 )
    {
        OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
        if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
        {
            // split out components of lost move (approx)
            Accel.X = OldAccel >>> 23;
            if ( Accel.X > 127 )
                Accel.X = -1 * (Accel.X - 128);
            Accel.Y = (OldAccel >>> 15) & 255;
            if ( Accel.Y > 127 )
                Accel.Y = -1 * (Accel.Y - 128);
            Accel.Z = (OldAccel >>> 7) & 255;
            if ( Accel.Z > 127 )
                Accel.Z = -1 * (Accel.Z - 128);
            Accel *= 20;

            OldbRun = ( (OldAccel & 64) != 0 );
            OldbDoubleJump = ( (OldAccel & 32) != 0 );
            NewbPressedJump = ( (OldAccel & 16) != 0 );
            if ( NewbPressedJump )
                bJumpStatus = NewbJumpStatus;
            switch (OldAccel & 7)
            {
                case 0:
                    OldDoubleClickMove = DCLICK_None;
                    break;
                case 1:
                    OldDoubleClickMove = DCLICK_Left;
                    break;
                case 2:
                    OldDoubleClickMove = DCLICK_Right;
                    break;
                case 3:
                    OldDoubleClickMove = DCLICK_Forward;
                    break;
                case 4:
                    OldDoubleClickMove = DCLICK_Back;
                    break;
            }
            log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
            OldTimeStamp = FMin(OldTimeStamp, CurrentTimeStamp + MaxResponseTime);
            MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, (bDuck == 1), NewbPressedJump, OldbDoubleJump, OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
        }
    }

    // View components
    ViewPitch = View/32768;
    ViewYaw = 2 * (View - 32768 * ViewPitch);
    ViewPitch *= 2;
    // Make acceleration.
    Accel = InAccel * 0.1;

    NewbPressedJump = (bJumpStatus != NewbJumpStatus);
    bJumpStatus = NewbJumpStatus;

    // Save move parameters.
    DeltaTime = FMin(MaxResponseTime,TimeStamp - CurrentTimeStamp);

	if ( Pawn == None )
		TimeMargin = 0;
	else if ( !CheckSpeedHack(DeltaTime) )
	{
        log(" ======== "$TimeStamp$" ServerMove: SpeedHack! ======== ");
		DeltaTime = 0;
		Pawn.Velocity = vect(0,0,0);
	}

    CurrentTimeStamp = TimeStamp;
    ServerTimeStamp = Level.TimeSeconds;
    ViewRot.Pitch = ViewPitch;
    ViewRot.Yaw = ViewYaw;
    ViewRot.Roll = 0;

    if ( NewbPressedJump || (InAccel != vect(0,0,0)) )
		LastActiveTime = Level.TimeSeconds;

	if ( Pawn == None || Pawn.bServerMoveSetPawnRot )
		SetRotation(ViewRot);

	if ( AcknowledgedPawn != Pawn )
		return;

    if ( (Pawn != None) && Pawn.bServerMoveSetPawnRot )
    {
        Rot.Roll = 256 * ClientRoll;
        Rot.Yaw = ViewYaw;
        if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
            maxPitch = 2;
        else
            maxPitch = 0;
        if ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
        {
            If (ViewPitch < 32768)
                Rot.Pitch = maxPitch * RotationRate.Pitch;
            else
                Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
        }
        else
            Rot.Pitch = ViewPitch;
        DeltaRot = (Rotation - Rot);
        log(" ======== "$TimeStamp$" ServerMove: setzt Rotation: "$Rot$" ======== ");
        Pawn.SetRotation(Rot);
    }

    // Übertragene Geschwindigkeit setzen
    /*
    if (Pawn != None)
        Pawn.Velocity = InVelocity;
    else
        Velocity = InVelocity;

    // Übertragene Position setzen
    if (Pawn != None)
        Pawn.SetLocation(ClientLoc);
    else
        SetLocation(ClientLoc);
    */

	if ((Pawn != none && Pawn.Physics != PHYS_Hovering) || (Pawn == none && Physics != PHYS_Hovering))
    {
        //if (Pawn == none)
        //    log("---> Pawn none, ServerMove, Walking");

        // Perform actual movement
        if ( (Level.Pauser == None) && (DeltaTime > 0) )
            MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, DoubleClickMove, Accel, DeltaRot);

        // Accumulate movement error.
        if ( ClientLoc == vect(0,0,0) )
		    return;		// first part of double servermove
        else if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
            ClientErr = 10000;
        else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
        {
            if ( Pawn == None )
                LocDiff = Location - ClientLoc;
            else
                LocDiff = Pawn.Location - ClientLoc;
            ClientErr = LocDiff Dot LocDiff;
        }

        // If client has accumulated a noticeable positional error, correct him.
        if ( ClientErr > 3 )
        {
            if ( Pawn == None )
            {
                PendingAdjustment.newPhysics = Physics;
                PendingAdjustment.NewLoc = Location;
                PendingAdjustment.NewVel = Velocity;
            }
            else
            {
                PendingAdjustment.newPhysics = Pawn.Physics;
                PendingAdjustment.NewVel = Pawn.Velocity;
                PendingAdjustment.NewBase = Pawn.Base;
                if ( (Mover(Pawn.Base) != None) || (Vehicle(Pawn.Base) != None) )
                    PendingAdjustment.NewLoc = Pawn.Location - Pawn.Base.Location;
                else
                    PendingAdjustment.NewLoc = Pawn.Location;
                PendingAdjustment.NewFloor = Pawn.Floor;
            }
	        log(" Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
            LastUpdateTime = Level.TimeSeconds;

		    PendingAdjustment.TimeStamp = TimeStamp;
            PendingAdjustment.newState = GetStateName();
        }
    }
    else
    {
        //if (Pawn == none)
        //    log("---> Pawn none, ServerMove, Hovering");

        // Perform actual movement
        if ( (Level.Pauser == None) && (DeltaTime > 0) )
            MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, DoubleClickMove, Accel, DeltaRot);

        /*
        if ( Pawn == None )
        {
            PendingAdjustment.newPhysics = Physics;
            PendingAdjustment.NewLoc = Location;
            PendingAdjustment.NewVel = Velocity;
        }
        else
        {
            PendingAdjustment.newPhysics = Pawn.Physics;
            PendingAdjustment.NewVel = Pawn.Velocity;
            PendingAdjustment.NewBase = Pawn.Base;
            if ( (Mover(Pawn.Base) != None) || (Vehicle(Pawn.Base) != None) )
                PendingAdjustment.NewLoc = Pawn.Location - Pawn.Base.Location;
            else
                PendingAdjustment.NewLoc = Pawn.Location;
            PendingAdjustment.NewFloor = Pawn.Floor;
        }
        log(" Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
        LastUpdateTime = Level.TimeSeconds;

        PendingAdjustment.TimeStamp = TimeStamp;
        //PendingAdjustment.newState = GetStateName();
        PendingAdjustment.newState = 'PlayerSliding';
        */

        // Accumulate movement error.
        if ( ClientLoc == vect(0,0,0) )
		    return;		// first part of double servermove
        else if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
            ClientErr = 10000;
        else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
        {
            if ( Pawn == None )
                LocDiff = Location - ClientLoc;
            else
                LocDiff = Pawn.Location - ClientLoc;
            ClientErr = LocDiff Dot LocDiff;
        }

        // If client has accumulated a noticeable positional error, correct him.
        if ( ClientErr > 3 )
        {
            if ( Pawn == None )
            {
                Acceleration = Accel;
                SetLocation(ClientLoc);
            }
            else
            {
                Pawn.Acceleration = Accel;
                Pawn.SetLocation(ClientLoc);
            }
	        log(" Client HolzhammerError at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
        }

        /*
        if ( Pawn == None )
        {
            Acceleration = Accel;
            SetLocation(ClientLoc);
        }
        else
        {
            Pawn.Acceleration = Accel;
            Pawn.SetLocation(ClientLoc);
        }
        if ( (Level.Pauser == None) && (DeltaTime > 0) )
            MoveAutonomous(DeltaTime, false, false, false, false, DoubleClickMove, vect(0,0,0), rot(0,0,0));
        */
    }
	log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity$" Physics "$Pawn.Physics);
}

/*******************************************************************************
    Aktualisiert die Ausrichtung vom Pawn und der Kamera im Slide-Modus
    Copy&Paste-Vorlage: UpdateRotation, ursprünglich von PlayerController.uc
*******************************************************************************/
function UpdateSlideRotation(float DeltaTime, float maxPitch)
{
    local rotator ViewRotation;
    local vector MyFloor, CrossDir, FwdDir, OldFwdDir, RealFloor;
    local float Intensity;

    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bFreeCamZoom == True)
        {
            CameraDeltaRad += DeltaTime * 0.25 * aLookUp;
        }
        else if (bFreeCamSwivel == True)
        {
            CameraSwivel.Yaw += 16.0 * DeltaTime * aTurn;
            CameraSwivel.Pitch += 16.0 * DeltaTime * aLookUp;
        }
        else
        {
            CameraDeltaRotation.Yaw += 32.0 * DeltaTime * aTurn;
            CameraDeltaRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        }
    }
    else
    {
        TurnTarget = None;
        bRotateToDesired = false;
        bSetTurnRot = false;

        if ( (Pawn.Base == None) || (HoverFloor == vect(0,0,0)) )
            MyFloor = vect(0,0,1);
        else
            MyFloor = HoverFloor;

        if ( MyFloor != OldFloor )
        {
            // smoothly change floor
            RealFloor = MyFloor;
            MyFloor = Normal(5*DeltaTime * MyFloor + (1 - 5*DeltaTime) * OldFloor);
            if ( (RealFloor Dot MyFloor) > 0.999 )
            {
                //log("-----------> keine Glättung! RealFloor: "$RealFloor$"  -  MyFloor: "$MyFloor);
                MyFloor = RealFloor;
            }
			else
			{
                //log("-----------> Glättung! RealFloor: "$RealFloor$"  -  MyFloor: "$MyFloor);
				// translate view direction
                CrossDir = Normal(RealFloor Cross OldFloor);
				FwdDir = CrossDir Cross MyFloor;
				OldFwdDir = CrossDir Cross OldFloor;
				ViewX = MyFloor * (OldFloor Dot ViewX)
							+ CrossDir * (CrossDir Dot ViewX)
							+ FwdDir * (OldFwdDir Dot ViewX);
				ViewX = Normal(ViewX);

				ViewZ = MyFloor * (OldFloor Dot ViewZ)
							+ CrossDir * (CrossDir Dot ViewZ)
							+ FwdDir * (OldFwdDir Dot ViewZ);
				ViewZ = Normal(ViewZ);
				OldFloor = MyFloor;
				ViewY = Normal(MyFloor Cross ViewX);
			}
        }

        // Pawn automatisch in seine Bewegungsrichtung ausrichten
        Intensity = VSize(Pawn.Velocity)/20000;
        ViewX = Normal((1-Intensity)*ViewX + Intensity*Normal(Pawn.Velocity));
        // Neue Y- und Z-Achsen berechnen
        ViewY = Normal(MyFloor Cross ViewX);
        ViewZ = Normal(ViewX Cross ViewY);

        ViewRotation = OrthoRotation(ViewX,ViewY,ViewZ);
        SetRotation(ViewRotation);
        ViewShake(deltaTime);
        ViewFlash(deltaTime);
        Pawn.FaceRotation(ViewRotation, deltaTime );
    }
}

/*******************************************************************************
  Ändert die Kameraposition in eine 3rd-Person Ansicht
*******************************************************************************/
event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector X,Y,Z;

    bBehindView=true;
    ViewActor = ViewTarget;
    GetAxes(ViewActor.Rotation, X, Y, Z);

    if (self.IsInState('PlayerWalking'))
    {
        // Translation der Kamera zur gewünschten Position
        CamHeight = CamHeight*0.995 + DesiredCamHeight*0.005;
        CamDist = CamDist*0.995 + DesiredCamDist*0.005;

        CameraLocation = ViewActor.Location + CamHeight*Z;
        CalcBehindView(CameraLocation, CameraRotation, CamDist);
    }
    else if (self.IsInState('PlayerSliding'))
    {
        // Translation der Kamera zur gewünschten Position
        CamHeight = CamHeight*0.995 + DesiredCamHeight*0.005;
        CamDist = CamDist*0.995 + DesiredCamDist*0.005;

        CameraLocation = ViewActor.Location + CamHeight*Z;
        CalcBehindView(CameraLocation, CameraRotation, CamDist);
    }
}

/*******************************************************************************
  Berechnet die Kameraposition von hinten
*******************************************************************************/
function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist,RealDist;
    local vector globalX,globalY,globalZ;
    local vector localX,localY,localZ;
    local vector X, Y, Z;

    CameraRotation = Rotation;
    CameraRotation.Roll = 0;
    //Anpassung des Kamerawinkels im Slide-Modus
    if (self.IsInState('PlayerSliding'))
    {
        CameraRotation.Pitch += PitchAdjust;
        GetAxes(Rotation, X, Y, Z);
        CameraLocation += PositionAdjustX * X;
        CameraLocation += PositionAdjustZ * Z;
    }

	CameraLocation.Z += 12;

    // add view rotation offset to cameraview (amb)
    CameraRotation += CameraDeltaRotation;

    View = vect(1,0,0) >> CameraRotation;

    // add view radius offset to camera location and move viewpoint up from origin (amb)
    RealDist = Dist;
    Dist += CameraDeltaRad;

    if( Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation,false,vect(50,50,10) ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;

    if ( !bBlockCloseCamera || !bValidBehindCamera || (ViewDist > 10 + FMax(ViewTarget.CollisionRadius, ViewTarget.CollisionHeight)) )
	{
		//Log("Update Cam ");
		bValidBehindCamera = true;
		OldCameraLoc = CameraLocation - ViewDist * View;
		OldCameraRot = CameraRotation;
	}
	else
	{
		//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
		SetRotation(OldCameraRot);
	}

    CameraLocation = OldCameraLoc;
    CameraRotation = OldCameraRot;

    // add view swivel rotation to cameraview (amb)
    GetAxes(CameraSwivel,globalX,globalY,globalZ);
    localX = globalX >> CameraRotation;
    localY = globalY >> CameraRotation;
    localZ = globalZ >> CameraRotation;
    CameraRotation = OrthoRotation(localX,localY,localZ);
}

/*******************************************************************************
    Description:  over ridden to unlock pitch rotation of playerpawns fire axis
                  see tag -EZE
*******************************************************************************/
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
    local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
    local actor BestTarget;
    local float bestAim, bestDist, projspeed;
    local actor HitActor;
    local bool bNoZAdjust, bLeading;
    local rotator AimRot;

    FireDir = vector(Rotation);
    if ( FiredAmmunition.bInstantHit )
        HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
    else
        HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
    if ( (HitActor != None) && HitActor.bProjTarget )
    {
        BestTarget = HitActor;
        bNoZAdjust = true;
        OldAim = HitLocation;
        BestDist = VSize(BestTarget.Location - Pawn.Location);
    }
    else
    {
        // adjust aim based on FOV
        bestAim = 0.90;
        if ( (Level.NetMode == NM_Standalone) && bAimingHelp )
        {
            bestAim = 0.93;
            if ( FiredAmmunition.bInstantHit )
                bestAim = 0.97;
            if ( FOVAngle < DefaultFOV - 8 )
                bestAim = 0.99;
        }
        else if ( FiredAmmunition.bInstantHit )
                bestAim = 1.0;
        BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart, FiredAmmunition.MaxRange);
        if ( BestTarget == None )
        {
            //if (bBehindView)
            //    return Pawn.Rotation;
            //else
				return Rotation;    // -EZE
        }
        OldAim = projStart + FireDir * bestDist;
    }
	InstantWarnTarget(BestTarget,FiredAmmunition,FireDir);
	ShotTarget = Pawn(BestTarget);
    if ( !bAimingHelp || (Level.NetMode != NM_Standalone) )
    {
        //if (bBehindView)
        //    return Pawn.Rotation;
        //else
            return Rotation;    // -EZE
    }

    // aim at target - help with leading also
    if ( !FiredAmmunition.bInstantHit )
    {
        projspeed = FiredAmmunition.ProjectileClass.default.speed;
        BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart);
        bLeading = true;
        FireDir = BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
        // if splash damage weapon, try aiming at feet - trace down to find floor
        if ( FiredAmmunition.bTrySplash
            && ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
        {
            HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
            if ( (HitActor != None)
                && FastTrace(HitLocation + vect(0,0,4),projstart) )
                return rotator(HitLocation + vect(0,0,6) - projStart);
        }
    }
    else
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }
    AimOffset = AimSpot - OldAim;

    // adjust Z of shooter if necessary
    if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
        AimSpot.Z = OldAim.Z;
    else if ( AimOffset.Z < 0 )
        AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
    else
        AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

    if ( !bLeading )
    {
        // if not leading, add slight random error ( significant at long distances )
        if ( !bNoZAdjust )
        {
            AimRot = rotator(AimSpot - projStart);
            if ( FOVAngle < DefaultFOV - 8 )
                AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
            else
                AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
            return AimRot;
        }
    }
    else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }

    return rotator(AimSpot - projStart);
}

//******************************************************************************
// FindCameraEffect
// Liefert einen gesuchten CameraEffect aus dem CameraEffects-Array oder
// aus dem ObjectPool des Levels und meldet diesen beim PlayerController an.
// Author: Jarronis, the Vampiric Unicorn
//******************************************************************************
simulated function CameraEffect FindCameraEffect(class<CameraEffect> CameraEffectClass)
{
  local PlayerController PlayerControllerLocal;
  local CameraEffect CameraEffectFound;
  local int i;
  log("Searching ce");
  PlayerControllerLocal = Level.GetLocalPlayerController();
  if ( PlayerControllerLocal != None ) {
    for (i = 0; i < PlayerControllerLocal.CameraEffects.Length; i++)
      if ( PlayerControllerLocal.CameraEffects[i].Class == CameraEffectClass ) {
        CameraEffectFound = PlayerControllerLocal.CameraEffects[i];
        //log("Found"@CameraEffectFound@"in CammeraEffects array");
        break;
      }
    if ( CameraEffectFound == None ) {
      CameraEffectFound = CameraEffect(Level.ObjectPool.AllocateObject(CameraEffectClass));
      //log("Got"@CameraEffectFound@"from ObjectPool");
    }
    if ( CameraEffectFound != None )
      PlayerControllerLocal.AddCameraEffect(CameraEffectFound);
  }
  return CameraEffectFound;
}

function ShowMidGameMenu(bool bPause)
{
	// Pause if not already
	if(bPause && Level.Pauser == None)
		SetPause(true);

	StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu

	ClientOpenMenu(MidGameMenuClass);
}

defaultproperties
{
    bSlide=false
    bJetPack=false
    bSandBag=false
    PawnClass=Class'TUQ.TUQ_Pawn'
    //ganz WICHTIG! sonst rollen Köpfe...
    bGodMode=true

    //CamHeight=75.0
    //CamDist=200.0
    CamHeight=160.0
    CamDist=400.0

    DesiredCamHeight=60.0
    DesiredCamDist=150.0

    PitchAdjust=62000
    PositionAdjustX=-15.000
    PositionAdjustZ=40.000

    PendingMeshUpdate=true

    bMakeNewTrail=true

    bHasFinished=false
    IsReadyToStart=false
    oldVisiblePlayers=0
    oldVel=0
    //TUQ_URL=""

    FirstName=" --- "
    SecondName=" --- "
    ThirdName=" --- "
    FourthName=" --- "

    MuteFireSound=sound'TUQSounds.Sounds.NOSOUND'
    MidGameMenuClass="TUQ.TUQ_GUI_MidMenu"
}
