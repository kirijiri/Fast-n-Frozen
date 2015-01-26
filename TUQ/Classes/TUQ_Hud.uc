//=============================================================================
// Das Head-Up-Display für die TUQ Mod
//
// Author: RM
//=============================================================================
class TUQ_HUD extends HudBDeathMatch;

#exec OBJ LOAD FILE=TUQHud.utx
#exec OBJ LOAD FILE=TUQMinimap.utx
#exec OBJ LOAD FILE=TUQPickupsGfx.utx
#exec OBJ LOAD FILE=TUQBoom.utx
#exec OBJ LOAD FILE=TUQFonts.utx PACKAGE=TUQFonts

var TUQ_CamActor CamActor;      // eine Kamera für ein extra Sichtfenster
var ScriptedTexture MirrorTex;  // was auf dem Spiegel zu sehen ist
var Actor MirrorMesh;           // StaticMesh des Spiegels
var TUQ_MirrorClient MClient;   // steuert die ScriptedTexture
var float MirrorRefresh;        // Bildwiederholungsrate des Spiegels
var float MirrorFOV;            // Sichtkegel des Spiegels in Grad
var float MirrorDist;           // Abstand des Spiegels von der Kamera
var float MirrorDistZ;          // vertikale Verschiebung des Spiegels

var float DistanceScale;

// für Spezialeffekt der Mauer
var bool bWallFX;
var vector WallPosition;
var int WallFXTimer;

// für Spezialeffekt des Aufprallens
var bool bHitFX;
var int HitFXTimer;
var vector HitPos;

var int place;
var int players;
var bool bFreezePlayed;

// für Teleport Effekt
var bool bTeleportFX;

// für Finish-Bildschirm
var float FinishCount;

// für Hud On Off
var bool bHUD;

// für Eingabetest
var bool bHasInteraction;

// HelpScreen
var bool showHelp;

// Rückspiegel zeigen
var bool bShowMirror;

// ÜberholSound
var int oldPlace;

var float scaleX, scaleY;
var float miniMapZoomFactor;

// Timer
var int minutes,seconds,tenth;

// Standardauflösung der HUD-Grafiken
const stndrtX=1024;
const stndrtY=768;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    InitCameraScreen();
    //StartTimer();

    bWallFX = false;
    WallFXTimer = 0;

    bTeleportFX = false;

    FinishCount = 1.0;
}

exec function SwitchMirror()
{
    bShowMirror=!bShowMirror;
}

exec function SwitchHUD()
{
    bHUD=!bHUD;
}

exec function MapZoomIn()
{
    if(miniMapZoomFactor>1)miniMapZoomFactor=miniMapZoomFactor-1;

    // debug
    //bWallFX = true;
    //WallFXTimer = 0;
}

exec function MapZoomOut()
{
    if(miniMapZoomFactor<4)miniMapZoomFactor=miniMapZoomFactor+1;
}

exec function HelpScreen()
{
    showHelp=!showHelp;
}

function bool IsPawnNear(vector Pos)
{
    local TUQ_Pawn testPawn;

    foreach RadiusActors(class'TUQ_Pawn',testPawn,5000,Pos)
        return true;

    return false;
}

function InitCameraScreen()
{
    if (CamActor == none)
        CamActor = spawn(class'TUQ_CamActor');
    if (CamActor != none)
    {
        UpdateCameraPosition();
    }
    else
        log("##### Erstellen des CamActor fehlgeschlagen!");

    MClient = Spawn(class'TUQ_MirrorClient');
    if (MClient != none)
    {
        MClient.CameraActor = CamActor;
        MClient.RefreshRate = MirrorRefresh;
        MClient.FOV = MirrorFOV;
    }
    else
        log("##### Erstellen des CameraTextureClient fehlgeschlagen!");

    //MirrorTex = ScriptedTexture(Level.ObjectPool.AllocateObject( class'ScriptedTexture' ) );
    MirrorTex = ScriptedTexture'TUQHud.TUQHud.MirrorTexture';
    if (MirrorTex != none && MClient != none)
    {
        MirrorTex.Client = MClient;
        MClient.DestTexture = MirrorTex;
    }
    else
        log("##### Erstellen der ScriptedTexture fehlgeschlagen!");

    //log("-------------> Client: "$MirrorTex.Client);
    //log("-------------> CamActor: "$MClient.CameraActor);
    MirrorMesh = Spawn(class'TUQ_MirrorMesh');
    if (MirrorMesh != none)
        MirrorMesh.Skins[0] = MirrorTex;
}

function StartTimer()
{
    tenth=0;
    seconds=0;
    minutes=0;
    SetTimer(0.1,true);
}

function StopTimer()
{
    Disable('Timer');
}

function Timer()
{
   tenth++;
   if(tenth%10==0)seconds++;
   if(tenth%600==0)
   {
      minutes++;
      seconds=0;
   }
}

function DrawHUD(Canvas c)
{
    local color tempColor;
    local byte tempStyle;

    players=GetPlayerCount();

    tempColor = c.DrawColor; //storing the values
    tempStyle = c.Style;

    scaleX=c.ClipX/stndrtX;
    scaleY=c.ClipY/stndrtY;

    if(bHUD)
    {
        //super.DrawHUD(c);

        c.DrawColor = WhiteColor;//restore values

        if(!TUQ_Controller(PawnOwner.Controller).bHasFinished)
        {
            if (PawnOwner.Controller.IsInState('PlayerStartWaiting'))
            {
                DrawWaitingHud(c);
            }
            else if (PawnOwner.Controller.IsInState('PlayerGetReady'))
            {
                DrawGetReadyHud(c);
            }
            else
            {
                if(bShowMirror)DrawMirrorScreen(c,scaleX,scaleY);
                DrawMap(c,scaleX,scaleY);
                DrawPickupIcons(c,scaleX,scaleY);
                DrawBlips(c,scaleX,scaleY);
                DrawOwnBlip(c,scaleX,scaleY);
                DrawHudElements(c,scaleX,scaleY);
                DrawMode(c,scaleX,scaleY);
                DrawPickUpFrame(c,scaleX,scaleY);
                //DrawJetPackFuel(c,scaleX,scaleY);
                //DrawVelocity(c,scaleX,scaleY);         //Anzeige der Geschwindigkeit
                DrawSpeedNeedle(c,scaleX,scaleY);
                DrawPlace(c,scaleX,scaleY);
                DrawTime(c,scaleX,scaleY);
                DrawCheckPointText(c,scaleX,scaleY);
                //DrawMapInfo(c);
                //DrawInfo(c);
                //DrawWeaponInfo(c);
                if(PawnOwner.Weapon.AmmoAmount(0)>0&&PawnOwner.Weapon.ItemName=="DynamiteThrow")
                    DrawCrosshair(c);
                //DrawButtons(c);                        //Eingabetest
                //DrawSlideModeNotify(c);                //Anzeige für Slide-Modus
                //DrawMeshInfo(c);
                if(showHelp)DrawHelpScreen(c,scaleX,scaleY);
            }
        }
        else
        {
            DrawFinishHud(c,scaleX,scaleY);
        }
    }
    else
    {
        if(TUQ_Controller(PawnOwner.Controller).bHasFinished)DrawFinishHud(c,scaleX,scaleY);
        else DrawCheckPointText(c,scaleX,scaleY);
    }

    if (bWallFX)
        DrawWallFX(c);

    if (bHitFX)
        DrawHitFX(c);

    if (bTeleportFX)
        DrawTeleportFX(c, scaleX, scaleY);

    /*
    if (TUQ_Controller(PawnOwner.Controller).bHasFinished)
    {
        //log("-----------------> DrawFinishScreen !!!");
        DrawFinishScreen(c, scaleX, scaleY);
    }
    */

    c.DrawColor = tempColor;//restore values
    c.Style = tempStyle;
}

function DrawCheckPointText(Canvas c,float scaleX,float scaleY)
{
    local color tempcolor;
    local bool draw;
    local TUQ_AnimMesh_CheckPoint testPoint;

    draw=false;

    foreach RadiusActors(class'TUQ_AnimMesh_CheckPoint',testPoint,1500,PawnOwner.Location)
    {
        draw=true;
    }

    if(draw)
    {
        c.Font=font'TUQFonts.Boom50';
        tempcolor=c.DrawColor;

        c.DrawColor.R=0;
        c.DrawColor.G=0;
        c.DrawColor.B=0;

        c.SetPos(380*scaleX,200*scaleX);
        c.DrawText("Checkpoint");
        c.SetPos(380*scaleX,210*scaleX);
        c.DrawText("Checkpoint");
        c.SetPos(390*scaleX,200*scaleX);
        c.DrawText("Checkpoint");
        c.SetPos(390*scaleX,210*scaleX);
        c.DrawText("Checkpoint");

        c.DrawColor.R=255;
        c.DrawColor.G=255;
        c.DrawColor.B=0;

        c.SetPos(385*scaleX,205*scaleX);
        c.DrawText("Checkpoint");

        c.DrawColor=tempcolor;
     }
}

function DrawFinishHud(Canvas c,float scaleX,float scaleY)
{
    local int tenthshown;
    local string Message;
    local int minshown;
    local float secshown, Time;

    tenthshown=tenth%10;

    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;

    if (FinishCount > 0)
        FinishCount -= 0.05;
    c.DrawColor.A = 255 * (1 - FinishCount);
    c.SetPos(0, 0);
    c.DrawRect(texture'TUQHud.TUQHud.FinishHUD',1024*scaleX,1024*scaleY);

    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=200;
    //c.DrawColor.A=255;

    if(c.ClipX>640)c.Font=font'TUQFonts.Boom40';
    else c.Font=font'TUQFonts.Boom20';


    switch(TUQ_Controller(PawnOwner.Controller).myPlace)
    {
        case 1:
            c.SetPos(50*scaleX,50*scaleY);
            c.DrawText("Super "$PawnOwner.GetHumanReadableName()$", Du hast gewonnen...");
        break;
        case 2:
            c.SetPos(50*scaleX,50*scaleY);
            c.DrawText("Na "$PawnOwner.GetHumanReadableName()$", immerhin 2. Sieger...");
        break;
        case 3:
            c.SetPos(50*scaleX,50*scaleY);
            c.DrawText("Dritter... VON VIEREN... Oje "$PawnOwner.GetHumanReadableName()$"...");
        break;
        case 4:
            c.SetPos(50*scaleX,50*scaleY);
            c.DrawText("Das war furchtbar "$PawnOwner.GetHumanReadableName()$"... Mit Recht Letzter...");
        break;
    }

    c.SetPos(50*scaleX,c.ClipY-50-50*scaleY);
    if(minutes>=5)c.DrawText("Vielleicht lieber Steckhalma???");
    if(minutes==4)c.DrawText("Das geht aber viel besser...");
    if(minutes==3)c.DrawText("Durchschnittlich...");
    if(minutes==2)c.DrawText("Gar nicht schlecht...");
    if(minutes<2)c.DrawText("Der helle Wahnsinn...");

    c.SetPos(150*scaleX,150*scaleY);
    c.DrawText("Ranking:");

    Time = TUQ_Controller(PawnOwner.Controller).FirstTime;
    minshown = Time/60;
    secshown = Time - minshown*60;
    if(secshown<10)
        Message = "1. "$TUQ_Controller(PawnOwner.Controller).FirstName$":  "$minshown$":0"$secshown;
    else
        Message = "1. "$TUQ_Controller(PawnOwner.Controller).FirstName$":  "$minshown$":"$secshown;
    //c.StrLen(Message, XL, YL);
    c.SetPos(150*scaleX, 150*scaleY+60);
    c.DrawText(Message);

    Time = TUQ_Controller(PawnOwner.Controller).SecondTime;
    minshown = Time/60;
    secshown = Time - minshown*60;
    if (Time != 0)
    {
        if(secshown<10)
            Message = "2. "$TUQ_Controller(PawnOwner.Controller).SecondName$":  "$minshown$":0"$secshown;
        else
            Message = "2. "$TUQ_Controller(PawnOwner.Controller).SecondName$":  "$minshown$":"$secshown;
        c.SetPos(150*scaleX, 150*scaleY+120);
        c.DrawText(Message);
    }

    Time = TUQ_Controller(PawnOwner.Controller).ThirdTime;
    minshown = Time/60;
    secshown = Time - minshown*60;
    if (Time != 0)
    {
        if(secshown<10)
            Message = "3. "$TUQ_Controller(PawnOwner.Controller).ThirdName$":  "$minshown$":0"$secshown;
        else
            Message = "3. "$TUQ_Controller(PawnOwner.Controller).ThirdName$":  "$minshown$":"$secshown;
        c.SetPos(150*scaleX, 150*scaleY+180);
        c.DrawText(Message);
    }

    Time = TUQ_Controller(PawnOwner.Controller).FourthTime;
    minshown = Time/60;
    secshown = Time - minshown*60;
    if (Time != 0)
    {
        if(secshown<10)
            Message = "4. "$TUQ_Controller(PawnOwner.Controller).FourthName$":  "$minshown$":0"$secshown;
        else
            Message = "4. "$TUQ_Controller(PawnOwner.Controller).FourthName$":  "$minshown$":"$secshown;
        c.SetPos(150*scaleX, 150*scaleY+240);
        c.DrawText(Message);
    }

    if(!bFreezePlayed)
    {
        PawnOwner.PlaySound(sound'TUQSounds.Sounds.Freeze',,10,false);
        bFreezePlayed=true;
    }
}

function DrawFinishScreen(Canvas c, float scalaX, float scaleY)
{
    local color tempColor;
    local font tempFont;
    local string Message;
    local float XL, YL;

    tempColor = c.DrawColor;
    tempFont = c.Font;

    c.DrawColor.R = 255;
    c.DrawColor.G = 255;
    c.DrawColor.B = 255;

    // Bildschirm abblenden
    //log("---------------> FinishCount = "$FinishCount);
    if (FinishCount > 0)
        FinishCount -= 0.05;
    c.DrawColor.A = 255 * (1 - FinishCount);
    c.SetPos(0, 0);
    c.DrawTileStretched(texture'TUQHud.TUQHud.BlackScreen', c.ClipX, c.ClipY);

    // Platzierung anzeigen
    if(c.ClipX>640)
        c.Font = font'TUQFonts.Boom40';
    else
        c.Font = font'TUQFonts.Boom20';
    c.DrawColor.R = 55;
    c.DrawColor.G = 255;
    c.DrawColor.B = 55;
    c.DrawColor.A = 255;

    Message = TUQ_Controller(PawnOwner.Controller).myPlace$". Platz !";
    c.StrLen(Message, XL, YL);
    c.SetPos(c.ClipX/2 - XL/2, c.ClipY/2 - YL/2);
    c.DrawText(Message);

    Message = "1. "$TUQ_Controller(PawnOwner.Controller).FirstName$"  -  "$TUQ_Controller(PawnOwner.Controller).FirstTime;
    //c.StrLen(Message, XL, YL);
    c.SetPos(c.ClipX/2 + 50, c.ClipY/2 - 100);
    c.DrawText(Message);

    c.DrawColor = tempColor;
    c.Font = tempFont;
}

function DrawTeleportFX(Canvas c, float scalaX, float scaleY)
{
    local color tempColor;

    tempColor = c.DrawColor;

    c.DrawColor.R = 255;
    c.DrawColor.G = 255;
    c.DrawColor.B = 255;
    c.DrawColor.A = 255 * (1 - TUQ_Controller(PawnOwner.Controller).StartCountdown);

    c.SetPos(0, 0);
    c.DrawTileStretched(texture'TUQHud.TUQHud.BlackScreen', c.ClipX, c.ClipY);

    c.DrawColor.A = 255;
    c.SetPos(c.ClipX/2 - 128*scaleX, c.ClipY/2 - 128*scaleY);
    c.DrawTileScaled(texture'TUQHud.TUQHud.TeleporterMessage', scaleX, scaleY);

    c.DrawColor = tempColor;
}

function DrawMode(Canvas c,float scalaX,float scaleY)
{
    local color tempcolor;
    tempcolor=c.DrawColor;

    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;

    if(TUQ_Controller(PawnOwner.Controller).bSlide)
    {
        c.SetPos(765*scaleX,700*scaleY);
        c.DrawRect(texture'TUQHud.TUQHud.Sliding',64*scaleX,64*scaleY);
    }
    else
    {
        c.SetPos(765*scaleX,715*scaleY);
        c.DrawRect(texture'TUQHud.TUQHud.Walking',64*scaleX,64*scaleY);
    }

    c.DrawColor=tempcolor;
}

function DrawHitFX(Canvas c)
{
    local color tempColor;
    local byte tempStyle;
    local font tempFont;
    //local string Message;
    local vector ScreenPos, CamLoc, HitDist;
    local rotator CamRot;
    local Material BoingTex;
    local float TexScale;
    local vector X,Y,Z;

    tempColor = c.DrawColor; //Wert speichern
    tempStyle = c.Style;     //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;
    c.Style = ERenderStyle.STY_Normal;

    c.GetCameraLocation(CamLoc, CamRot);
    GetAxes(CamRot,X,Y,Z);
    HitDist = HitPos - CamLoc;
    // der Effekt
    if (FastTrace(HitPos, CamLoc) && (Normal(HitPos - CamLoc) dot X) >= 0)
    {
        //Message = ">> BOING!!! <<";
        ScreenPos = c.WorldToScreen(HitPos);
        c.DrawColor.A = 255 - 2*HitFXTimer;
        TexScale = DistanceScale*(0.3 + 0.0025*(HitFXTimer+1))/VSize(HitDist);
        BoingTex = texture'TUQBoom.Animation.Boing13';
        ScreenPos.X -= TexScale * 200;
        ScreenPos.Y -= TexScale * 200;
        c.SetPos(ScreenPos.X, ScreenPos.Y);
        c.DrawTileScaled(BoingTex, TexScale, TexScale);
        //c.DrawText(Message);
    }

    // Timer
    if (HitFXTimer < 127)
        HitFXTimer++;
    else
    {
        HitFXTimer = 0;
        bHitFX = false;
    }

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Style = tempStyle;     //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

function DrawWallFX(Canvas c)
{
    local color tempColor;
    local byte tempStyle;
    local font tempFont;
    //local string Message;
    local vector ScreenPos, CamLoc, WallDist;
    local rotator CamRot;
    local vector X,Y,Z;
    local Material BoomTex;
    local float TexScale;

    tempColor = c.DrawColor; //Wert speichern
    tempStyle = c.Style;     //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;
    c.Style = ERenderStyle.STY_Normal;

    c.GetCameraLocation(CamLoc, CamRot);
    GetAxes(CamRot,X,Y,Z);
    WallDist = WallPosition - CamLoc;
    // der Effekt
    if (FastTrace(WallPosition, CamLoc) && (Normal(WallDist) dot X) >= 0)
    {
        //log("Mauer stüüüüüüüüüüüüüüüüüüüüüüüüürzt eeeeeeeeeeeeeeeeeeeeeeeeeeein...");
        //Message = ">> BOOM!!! <<";
        //ScreenPos = c.WorldToScreen(WallPosition) - vect(256,256,0);
        ScreenPos = c.WorldToScreen(WallPosition);
        c.DrawColor.A = 255 - 2*WallFXTimer;
        TexScale = DistanceScale*(0.3 + 0.0025*(WallFXTimer+1))/VSize(WallDist);
        BoomTex = texture'TUQBoom.Animation.Boom13';
        ScreenPos.X -= TexScale * 200;
        ScreenPos.Y -= TexScale * 200;
        c.SetPos(ScreenPos.X, ScreenPos.Y);
        c.DrawTileScaled(BoomTex, TexScale, TexScale);
        //c.DrawText(Message);
    }
    // Timer
    if (WallFXTimer < 127)
        WallFXTimer++;
    else
    {
        WallFXTimer = 0;
        bWallFX = false;
    }

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Style = tempStyle;     //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

function DrawGetReadyHud(Canvas c)
{
    local color tempColor;
    local byte tempStyle;
    local font tempFont;
    local string Message;
    local float XL, YL;
    local int Count;

    tempColor = c.DrawColor; //Wert speichern
    tempStyle = c.Style;     //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    c.DrawColor.R=55;
    c.DrawColor.G=255;
    c.DrawColor.B=55;
    c.Style = ERenderStyle.STY_Normal;

    if (TUQ_Controller(PawnOwner.Controller).IsReadyToStart)
    {
        if (!TUQ_Controller(PawnOwner.Controller).bCountdownEnabled)
            Message = ">> Warten bis alle Spieler bereit sind <<";
        else
        {
            Count = TUQ_Controller(PawnOwner.Controller).StartCountdown + 1;
            Message = ">> Start des Rennens in "$Count$" ...";
        }
    }
    else
        Message = ">> Spieler vollzählig! FEUER Drücken, wenn bereit... <<";

    c.StrLen(Message, XL, YL);
    c.SetPos(c.ClipX/2 - XL/2, c.ClipY/2 - YL/2);
    c.DrawText(Message);

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Style = tempStyle;     //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

function DrawWaitingHud(Canvas c)
{
    local color tempColor;
    local byte tempStyle;
    local font tempFont;
    local string Message;
    local float XL, YL;

    tempColor = c.DrawColor; //Wert speichern
    tempStyle = c.Style;     //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    c.DrawColor.R=55;
    c.DrawColor.G=255;
    c.DrawColor.B=55;
    c.Style = ERenderStyle.STY_Normal;

    Message = ">> Warte auf weitere Mitspieler <<";
    c.StrLen(Message, XL, YL);
    c.SetPos(c.ClipX/2 - XL/2, c.ClipY/2 - YL/2);
    c.DrawText(Message);

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Style = tempStyle;     //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

function DrawHelpScreen(Canvas c,float ScaleX,float ScaleY)
{
    local texture tex;
    tex=texture'TUQHud.TUQHud.HelpScreen';

    c.SetPos(0,0);
    c.DrawRect(tex,1024*scaleX,1024*scaleY);
    //c.DrawRect(texture'TUQHud.TUQHud.HelpScreen',1024*scaleX,1024*scaleY);
}

function DrawWeaponInfo(Canvas c)
{
    local color tempcolor;
    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    c.SetPos(200,300);
    c.DrawText("WaffenInfo:");

    c.SetPos(200,320);
    c.DrawText("Waffe           : "$PawnOwner.Weapon.ItemName);
    c.SetPos(200,330);
    c.DrawText("Munition        : "$PawnOwner.Weapon.AmmoAmount(0));

    //c.SetPos(200,350);
    //c.DrawText("SandBraking     : "$TUQ_Pawn(PawnOwner).bSandBraking);

    c.SetPos(200,360);
    c.DrawText("JetPackMesh     : "$TUQ_Controller(TUQ_Pawn(PawnOwner).Controller).bJetPack);

    c.DrawColor=tempColor;
}

function DrawMeshInfo(Canvas c)
{
    local color tempcolor;

    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    c.SetPos(200,300);
    c.DrawText("MeshInfo:");

    c.SetPos(200,320);
    c.DrawText("Meshnummer           : "$TUQ_Controller(PawnOwner.Controller).figur);
    c.SetPos(200,330);
    c.DrawText("Farbnummer           : "$TUQ_Controller(PawnOwner.Controller).farbe);
    c.SetPos(200,340);
    c.DrawText("Rassennummer         : "$TUQ_Controller(PawnOwner.Controller).rasse);

    c.DrawColor=tempColor;
}

function DrawMapInfo(Canvas c)
{
    local color tempcolor;
    local float mapfactor;
    local float mapX,mapY;

    mapfactor=512/26350;
    mapY=4096+PawnOwner.Location.X*mapfactor;
    mapX=-PawnOwner.Location.Y*mapfactor;

    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    c.SetPos(200,300);
    c.DrawText("MapInfo:");

    c.SetPos(200,320);
    c.DrawText("WeltLocationX           : "$PawnOwner.Location.X);
    c.SetPos(200,330);
    c.DrawText("WeltLocationY           : "$PawnOwner.Location.Y);

    c.SetPos(200,350);
    c.DrawText("MapLocationX            : "$mapX);
    c.SetPos(200,360);
    c.DrawText("MapLocationY            : "$mapY);

    c.DrawColor=tempColor;
}

function DrawTime(Canvas c,float scaleX,float scaleY)
{
    local int tenthshown;
    local font tempfont;

    local color tempcolor;
    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;
    tenthshown=tenth%10;

    tempFont=c.Font;
    c.Font=font'TUQFonts.Boom15';

    c.SetPos(95,c.ClipY-146+(4-players)*22);
    if(seconds<10)
       c.DrawText(minutes$":0"$seconds$":"$tenthshown);
    else
       c.DrawText(minutes$":"$seconds$":"$tenthshown);

    c.DrawColor=tempColor;
    c.Font=tempFont;
}

function int GetPlayerCount()
{
    local int p;
    local TUQ_Pawn testpawn;

    p=0;

    foreach AllActors(class'TUQ_Pawn', testpawn)
    {
         p++;
    }
    return p;
}

function int CalcPlace(TUQ_Pawn P)
{
    local float x,y,z,xpos,ypos,zpos,xloc,yloc,zloc,distx,disty,distz,owndistance,distance;
    local TUQ_Pawn testpawn;

    x=-50000;
    y=-8500;
    z=-6000;

    place=1;
    xloc=P.Location.X;
    yloc=P.Location.Y;
    zloc=P.Location.Z;

    distx=xloc-x;
    disty=yloc-y;
    distz=zloc-z;

    owndistance=sqrt(distx*distx+disty*disty+distz*distz);

    foreach AllActors(class'TUQ_Pawn', testpawn)
    {
           xpos=testpawn.Location.X;
           ypos=testpawn.Location.Y;
           zpos=testpawn.Location.Z;

           if(xpos!=P.Location.X||ypos!=P.Location.Y||zpos!=P.Location.Z)
           {
              distx=xpos-x;
              disty=ypos-y;
              distz=zpos-z;

              distance=sqrt(distx*distx+disty*disty+distz*distz);

              if(distance<owndistance)
                 place++;
           }
    }
    return place;
}

function DrawPlace(Canvas c,float scaleX,float scaleY)
{
    local font tempfont;
    local int s;
    local string sName;
    local TUQ_Controller tC;
    local int p;
    local int i;
    local TUQ_Pawn testpawn;
    local string places[4];
    //local int colors[4];
    local color tempcolor;

    tempcolor=c.DrawColor;

    places[0]="1.";
    places[1]="2.";
    places[2]="3.";
    places[3]="4.";

    tempFont=c.Font;
    c.Font=font'TUQFonts.Boom15';

    foreach AllActors(class'TUQ_Pawn', testpawn)
    {
        p=CalcPlace(testpawn);

        places[p-1]=p$". "$testpawn.GetHumanReadableName();

        //colors[p-1] = TUQ_Controller(testpawn.Controller).farbe;
    }

    for(i=0;i<players;i++)
    {
        // dunkler Rand um die Schrift:
        c.DrawColor.R = 55;
        c.DrawColor.G = 55;
        c.DrawColor.B = 55;
        c.setPos(56,(c.ClipY-107+(4-players)*22)+i*22);
        c.DrawText(places[i]);
        c.setPos(54,(c.ClipY-107+(4-players)*22)+i*22);
        c.DrawText(places[i]);
        c.setPos(55,(c.ClipY-107+(4-players)*22)+i*22+1);
        c.DrawText(places[i]);
        c.setPos(55,(c.ClipY-107+(4-players)*22)+i*22-1);
        c.DrawText(places[i]);

        /*switch (colors[i])
        {
            case 0:  //Blau
                c.DrawColor.R = 55;
                c.DrawColor.G = 55;
                c.DrawColor.B = 255;
                break;
            case 1:  //Rot
                c.DrawColor.R = 255;
                c.DrawColor.G = 55;
                c.DrawColor.B = 55;
                break;
            case 2:  //Gelb
                c.DrawColor.R = 255;
                c.DrawColor.G = 255;
                c.DrawColor.B = 55;
                break;
            case 3:  //Grün
                c.DrawColor.R = 55;
                c.DrawColor.G = 255;
                c.DrawColor.B = 55;
                break;
            case 4:  //Pink
                c.DrawColor.R = 255;
                c.DrawColor.G = 141;
                c.DrawColor.B = 213;
                break;
        }*/

        if(i+1==CalcPlace(TUQ_Pawn(PawnOwner)))
        {
            switch (TUQ_Controller(PawnOwner.Controller).farbe)
            {
            case 0:  //Blau
                c.DrawColor.R = 100;
                c.DrawColor.G = 100;
                c.DrawColor.B = 255;
                break;
            case 1:  //Rot
                c.DrawColor.R = 255;
                c.DrawColor.G = 55;
                c.DrawColor.B = 55;
                break;
            case 2:  //Gelb
                c.DrawColor.R = 255;
                c.DrawColor.G = 255;
                c.DrawColor.B = 55;
                break;
            case 3:  //Grün
                c.DrawColor.R = 55;
                c.DrawColor.G = 255;
                c.DrawColor.B = 55;
                break;
            case 4:  //Pink
                c.DrawColor.R = 255;
                c.DrawColor.G = 141;
                c.DrawColor.B = 213;
                break;
            }
        }
        else
        {
            c.DrawColor.R=255;
            c.DrawColor.G=255;
            c.DrawColor.B=255;
        }

        c.setPos(55,(c.ClipY-107+(4-players)*22)+i*22);
        c.DrawText(places[i]);
    }

    c.Font=tempFont;

    c.DrawColor=tempcolor;

    if(IsPawnNear(PawnOwner.Location))
    {
      if(p>oldPlace)
      {
          s=Rand(2)+1;
          tC=TUQ_Controller(PawnOwner.Controller);

          if(Rand(2)==0)
          {
              if(tC.rasse==0)
                  sName="TUQRobbe"$tC.figur+1$"Sounds.R"$tC.figur+1$"Bad"$s;
              if(tC.rasse==1)
                  sName="TUQPingu"$tC.figur+1$"Sounds.P"$tC.figur+1$"Bad"$s;
          }

          PawnOwner.PlaySound(sound(DynamicLoadObject(sName,class'sound')),,1,false);
      }

      if(p<oldPlace)
      {
          s=Rand(3)+1;
          tC=TUQ_Controller(PawnOwner.Controller);

          if(Rand(2)==0)
          {
              if(tC.rasse==0)
                  sName="TUQRobbe"$tC.figur+1$"Sounds.R"$tC.figur+1$"Good"$s;
              if(tC.rasse==1)
                  sName="TUQPingu"$tC.figur+1$"Sounds.P"$tC.figur+1$"Good"$s;
          }

          PawnOwner.PlaySound(sound(DynamicLoadObject(sName,class'sound')),,1,false);
      }
    }

    oldPlace=p;
}

function DrawPickupIcons(Canvas c,float scaleX,float scaleY)
{
    local Inventory Inv;
    local Weapon W;
    local float height1,height2;

    for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        W = Weapon( Inv );

        if( W == None )
            continue;

        if(W.ItemName=="JetPack"&&W.AmmoAmount(0)>0)
        {
            height1=W.AmmoAmount(0)*0.42;
            height2=W.AmmoAmount(0)*0.64;
            c.SetPos(839*scaleX,(21+42-height1)*scaleY);

            c.DrawTile(texture'TUQPickupsGfx.Items.JetPackIcon',42*scaleX,height1*scaleY,0,64-height2,64,height2);
        }
        if(W.ItemName=="SandBag"&&W.AmmoAmount(0)>0)
        {
            height1=W.AmmoAmount(0)*4.2;
            height2=W.AmmoAmount(0)*6.4;
            c.SetPos(896*scaleX,(21+42-height1)*scaleY);

            c.DrawTile(texture'TUQPickupsGfx.Items.SandBagIcon',42*scaleX,height1*scaleY,0,64-height2,64,height2);
        }
        if(W.ItemName=="DynamiteThrow"&&W.AmmoAmount(0)>0)
        {
            c.SetPos(955*scaleX,21*scaleY);
            c.DrawRect(texture'TUQPickupsGfx.Items.DynamitIcon',42*scaleX,42*scaleY);
        }
    }
}

function DrawPickupFrame(Canvas c,float scaleX,float scaleY)
{
    local Color tempcolor;

    tempcolor=c.DrawColor;

    c.DrawColor.R=200;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    if(PawnOwner.Weapon.AmmoAmount(0)>0&&PawnOwner.Weapon.ItemName=="JetPack")
    {
        c.SetPos(834*scaleX,16*scaleY);
        c.DrawBox(c,52*scaleX,52*scaleY);
    }

    if(PawnOwner.Weapon.AmmoAmount(0)>0&&PawnOwner.Weapon.ItemName=="SandBag")
    {
        c.SetPos(891*scaleX,16*scaleY);
        c.DrawBox(c,52*scaleX,52*scaleY);
    }

    if(PawnOwner.Weapon.AmmoAmount(0)>0&&PawnOwner.Weapon.ItemName=="DynamiteThrow")
    {
        c.SetPos(950*scaleX,16*scaleY);
        c.DrawBox(c,52*scaleX,52*scaleY);
    }

    c.DrawColor=tempcolor;
}

function DrawJetPackFuel(Canvas c,float scaleX,float scaleY)
{
    local float height;
    local Color tempcolor;
    local int i;

    if(PawnOwner.Weapon.AmmoAmount(0)>0&&PawnOwner.Weapon.ItemName=="JetPack")
    {
        height=PawnOwner.Weapon.AmmoAmount(0)*1.31;

        tempcolor=c.DrawColor;

        c.DrawColor.R=50;
        c.DrawColor.G=50;
        c.DrawColor.B=150;

        for(i=0;i<(height+1)*scaleY;i++)
        {
            c.SetPos(15*scaleX,(748*scaleY-i));
            c.DrawBox(c,15,1);
        }

        c.DrawColor=tempcolor;
    }
}

function DrawBlips(Canvas c,float scaleX,float scaleY)
{
    local TUQ_Pawn testpawn;
    local float x,y,distx,disty;
    local color tempcolor;
    local float posX,posY;

    local float mapfactor;
    local float maptestX,maptestY;
    local float mapX,mapY;

    //local material blibTex;

    mapfactor=512/26350;

    tempcolor=c.DrawColor;
    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;

    mapX=-PawnOwner.Location.Y*mapfactor;
    mapY=4096+PawnOwner.Location.X*mapfactor;

    foreach RadiusActors(class'TUQ_Pawn', testpawn,25000,PawnOwner.Location)
    {
           //blibTex=TexRotator'TUQHud.TUQHud.OwnBlibRot';
           maptestX=-testpawn.Location.Y*mapfactor-4;
           maptestY=4096+testpawn.Location.X*mapfactor-4;

           maptestX=maptestX;
           maptestY=maptestY;

           x=testpawn.Location.X;
           y=testpawn.Location.Y;

           if(testpawn!=PawnOwner)
           {
              distx=(maptestX-mapX)/miniMapZoomFactor;
              disty=(maptestY-mapY)/miniMapZoomFactor;

              posY=(83+disty);
              posX=(82+distx);

              if(posX>150)posX=150;
              if(posY>152)posY=152;
              if(posX<14)posx=14;
              if(posY<14)posy=14;

              c.SetPos(posX*scaleX,posY*scaleY);
              c.DrawRect(texture'TUQHud.TUQHud.Blib',8*scaleX,8*scaleY);
              //TexRotator(blibTex).Rotation.Yaw=-testpawn.Rotation.Yaw+32768;
              //c.DrawTile(blibTex,16*scaleX,16*scaleY,0,0,64,64);
           }
    }

    //c.SetPos(180*scaleX,10*scaleY);
    //c.DrawText(miniMapZoomFactor);

    c.DrawColor=tempcolor;
}

function DrawOwnBlip(Canvas c,float scaleX,float scaleY)
{
    local material blibTex;
    local Color tempcolor;

    blibTex=TexRotator'TUQHud.TUQHud.OwnBlibRot';

    tempcolor=c.DrawColor;

    switch (TUQ_Controller(PawnOwner.Controller).farbe)
    {
    case 0:  //Blau
        c.DrawColor.R = 100;
        c.DrawColor.G = 100;
        c.DrawColor.B = 255;
    break;
    case 1:  //Rot
        c.DrawColor.R = 255;
        c.DrawColor.G = 55;
        c.DrawColor.B = 55;
    break;
    case 2:  //Gelb
        c.DrawColor.R = 255;
        c.DrawColor.G = 255;
        c.DrawColor.B = 55;
    break;
    case 3:  //Grün
        c.DrawColor.R = 55;
        c.DrawColor.G = 255;
        c.DrawColor.B = 55;
    break;
    case 4:  //Pink
        c.DrawColor.R = 255;
        c.DrawColor.G = 141;
        c.DrawColor.B = 213;
    break;
    }

    c.SetPos(82*scaleX-8*scaleX,83*scaleY-8*scaleY);
    TexRotator(blibTex).Rotation.Yaw=-PawnOwner.Controller.Rotation.Yaw+32768;
    c.DrawTile(blibTex,16*scaleX,16*scaleY,0,0,64,64);//144 146 10 10

    c.DrawColor=tempcolor;
}

function DrawSpeedNeedle(Canvas c,float scaleX,float scaleY)
{
    local material needleTex;
    needleTex=TexRotator'TUQHud.TUQHud.TachoNadelRot';

    c.SetPos(769*scaleX,490*scaleY);
    TexRotator(needleTex).Rotation.Yaw=-Abs((CalculateVelocity()*75));
    c.DrawTile(needleTex,512*scaleX,512*scaleY,0,0,512,512);
}

function DrawMap(Canvas c,float scaleX,float scaleY)
{
    local float mapfactor;
    local float mapX,mapY;

    mapfactor=512/26350;
    mapY=4096+PawnOwner.Location.X*mapfactor;
    mapX=-PawnOwner.Location.Y*mapfactor;

    c.SetPos(10*scaleX,10*scaleY);
    c.DrawTile(PawnOwner.Level.RadarMapImage,144*scaleX,146*scaleY,mapX-72*miniMapZoomFactor,mapY-73*miniMapZoomFactor,144*miniMapZoomFactor,146*miniMapZoomFactor);
}

function DrawHudElements(Canvas c,float scaleX,float scaleY)
{
    c.DrawColor = WhiteColor;
    c.Style=ERenderStyle.STY_Alpha;

    //Minimap
    c.SetPos(0,0);
    c.DrawRect(texture'TUQHud.TUQHud.Minimap_Snow',512*scaleX,256*scaleY);
    //Rückspiegel
    if(bShowMirror)
    {
        c.SetPos((256+5)*scaleX,0);
        c.DrawRect(texture'TUQHud.TUQHud.Backview_Snow',512*scaleX,128*scaleY);
    }
    //Itembar
    c.SetPos(512*scaleX,0);
    c.DrawRect(texture'TUQHud.TUQHud.Items_Snow',512*scaleX,128*scaleY);
    //Skala
    //c.SetPos(0,512*scaleY);
    //c.DrawRect(texture'TUQHud.TUQHud.Scale_Snow',128*scaleX,256*scaleY);
    //Tacho
    c.SetPos(512*scaleX,512*scaleY);
    c.DrawRect(texture'TUQHud.TUQHud.Tacho_Snow',512*scaleX,256*scaleY);
    //Rang
    switch(players)
    {
        case 4:
            c.SetPos(0,c.ClipY-256);
            c.DrawRect(texture'TUQHud.TUQHud.ZeitRang4_Snow',512,256);
        break;
        case 3:
            c.SetPos(0,c.ClipY-256);
            c.DrawRect(texture'TUQHud.TUQHud.ZeitRang3_Snow',512,256);
        break;
        case 2:
            c.SetPos(0,c.ClipY-256);
            c.DrawRect(texture'TUQHud.TUQHud.ZeitRang2_Snow',512,256);
        break;
        case 1:
            c.SetPos(0,c.ClipY-256);
            c.DrawRect(texture'TUQHud.TUQHud.ZeitRang1_Snow',512,256);
        break;
        default:
        break;
    }
}

function DrawVelocity(Canvas c,float scaleX,float scaleY)
{
    local color tempColor;
    local font tempFont;

    tempColor = c.DrawColor; //Wert speichern
    tempFont = c.Font;  //Wert speichern

    c.Font = c.MedFont;

    //Farbe zum Zeichnen festlegen
    c.DrawColor.R = 8;
    c.DrawColor.G = 8;
    c.DrawColor.B = 64;

    c.SetPos(785*scaleX,740*scaleY);
    c.DrawText(CalculateVelocity()$" km/h");

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

function DrawCrosshair(Canvas c)
{
    local int CenterX, CenterY;

    CenterX = 0.5*c.ClipX;
    CenterY = 0.5*c.ClipY;

    c.SetPos(CenterX - 32, CenterY - 28);
    c.DrawIcon(Texture'Crosshairs.HUD.Crosshair_Dot', 1.0);
}

function DrawMirrorScreen(Canvas c, float scaleX, float scaleY)
{
    local rotator tempRot, CamRot;
    local color tempColor;
    local byte tempStyle;
    local vector X,Y,Z, CamPos;

    tempColor = c.DrawColor; //Wert speichern
    tempStyle = c.Style;     //Wert speichern

    c.DrawColor.R=255;
    c.DrawColor.G=255;
    c.DrawColor.B=255;
    c.Style = ERenderStyle.STY_Normal;

    UpdateCameraPosition();
    if (MirrorTex == none)
        log("-------------> MirrorTex weg!");
    else
        MirrorTex.Revision++;
    //log("-------------> MirrorTex Revision: "$MirrorTex.Revision);
    //log("---------------> DestTex Revision: "$MClient.DestTexture.Revision);
    c.GetCameraLocation(CamPos, CamRot);
    GetAxes(CamRot,X,Y,Z);

    tempRot = CamRot;
    /*
    tempRot.Yaw -= 16384;
    tempRot.Pitch = CamRot.Roll;
    tempRot.Roll = -CamRot.Pitch;
    */

    MirrorMesh.SetRotation(tempRot);
    MirrorMesh.SetLocation(CamPos+(MirrorDist)*vector(CamRot)+MirrorDistZ*Z);
    c.DrawActor(MirrorMesh,false,true);

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Style = tempStyle;     //Wert wiederherstellen
}

function DrawInfo(Canvas c)
{
    local string Info;
    local font tempFont;
    local rotator CamRot;
    local vector CamPos;

    c.GetCameraLocation(CamPos,CamRot);

    tempFont = c.Font;  //Wert speichern

    c.Font = c.SmallFont;

    Info = "CamActor Location: "$CamActor.Location;
    c.SetPos(10,100);
    c.DrawText(Info);

    Info = "CamActor Rotation: "$CamActor.Rotation;
    c.SetPos(10,110);
    c.DrawText(Info);

    Info = "FloorNormal: "$PawnOwner.Floor;
    c.SetPos(10,130);
    c.DrawText(Info);

    Info = "PawnAcceleration: "$VSize(PawnOwner.Acceleration);
    c.SetPos(10,150);
    c.DrawText(Info);

    Info = "PawnVelocity: "$VSize(PawnOwner.Velocity);
    c.SetPos(10,160);
    c.DrawText(Info);

    Info = "SlideForce: "$VSize(TUQ_Pawn(PawnOwner).SlideForce);
    c.SetPos(10,170);
    c.DrawText(Info);

    Info = "Camera Rotation: "$CamRot;
    c.SetPos(10,190);
    c.DrawText(Info);

    Info = "Mirror Rotation: "$MirrorMesh.Rotation;
    c.SetPos(10,200);
    c.DrawText(Info);

    Info = "Pawn Rotation: "$PawnOwner.Rotation;
    c.SetPos(10,220);
    c.DrawText(Info);

    Info = "HoverFloor: "$TUQ_Controller(PawnOwner.Controller).HoverFloor;
    c.SetPos(10,230);
    c.DrawText(Info);

    Info = "ViewX: "$PawnOwner.Controller.ViewX;
    c.SetPos(10,240);
    c.DrawText(Info);

    Info = "ViewY: "$PawnOwner.Controller.ViewY;
    c.SetPos(10,250);
    c.DrawText(Info);

    Info = "ViewZ: "$PawnOwner.Controller.ViewZ;
    c.SetPos(10,260);
    c.DrawText(Info);

    c.Font = tempFont;  //Wert wiederherstellen
}

//Zeigt an, ob man sich im Slide-Modus befindet
function DrawSlideModeNotify(Canvas c)
{
    local color tempColor;
    local font tempFont;

    tempColor = c.DrawColor; //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    if (TUQ_Controller(PawnOwner.Controller).bSlide)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 64;
        c.DrawColor.G = 255;
        c.DrawColor.B = 64;

        c.SetPos(c.ClipX*0.5, 10);
        c.DrawText("[SLIDE-MODUS]");
    }

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}
//=============================================================================
// Das Folgende ist für Testzwecke bezüglich der Tastatureingabe
//=============================================================================
//-begin-
function DrawButtons(Canvas c)
{
    local color tempColor;
    local font tempFont;

    tempColor = c.DrawColor; //Wert speichern
    tempFont = c.Font;       //Wert speichern

    c.Font = c.MedFont;

    if (TUQ_Controller(PawnOwner.Controller).bNumber1)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 255;
        c.DrawColor.G = 64;
        c.DrawColor.B = 64;

        c.SetPos(c.ClipX - 100, 50);
        c.DrawText(">>B1<<");
    }

    if (TUQ_Controller(PawnOwner.Controller).bNumber2)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 64;
        c.DrawColor.G = 255;
        c.DrawColor.B = 64;

        c.SetPos(c.ClipX - 100, 70);
        c.DrawText(">>B2<<");
    }

    if (TUQ_Controller(PawnOwner.Controller).bNumber3)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 64;
        c.DrawColor.G = 64;
        c.DrawColor.B = 255;

        c.SetPos(c.ClipX - 100, 90);
        c.DrawText(">>B3<<");
    }

    if (TUQ_Controller(PawnOwner.Controller).bNumber4)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 255;
        c.DrawColor.G = 64;
        c.DrawColor.B = 255;

        c.SetPos(c.ClipX - 100, 110);
        c.DrawText(">>B4<<");
    }

    if (TUQ_Controller(PawnOwner.Controller).bNumber5)
    {
        //Farbe zum Zeichnen festlegen
        c.DrawColor.R = 255;
        c.DrawColor.G = 255;
        c.DrawColor.B = 64;

        c.SetPos(c.ClipX - 100, 130);
        c.DrawText(">>B5<<");
    }

    c.DrawColor = tempColor; //Wert wiederherstellen
    c.Font = tempFont;       //Wert wiederherstellen
}

// berechnet die Vorwärtsgeschwindigkeit des Pawns in Km/h
function int CalculateVelocity()
{
    local int Speed;
    local float tempSpeed;
    local vector X,Y,Z;

    GetAxes(PawnOwner.Rotation,X,Y,Z);

    tempSpeed = (((X dot Normal(PawnOwner.Velocity)) * VSize(PawnOwner.Velocity)) / 52.5) * 3.6;
    Speed = tempSpeed;

    return Speed;
}

function UpdateCameraPosition()
{
    local vector CamLoc;
    local rotator CamRot;

    CamLoc = PawnOwner.Location;
    CamLoc.Z += PawnOwner.EyeHeight + 20;
    CamLoc = CamLoc - 70 * vector(PawnOwner.Rotation);

    CamRot = PawnOwner.Controller.Rotation;
    CamRot.Yaw=PawnOwner.Controller.Rotation.Yaw+32768;
    CamRot.Pitch=-PawnOwner.Controller.Rotation.Pitch;

    //kein Rollen der Kamera
    CamRot.Roll = 0;

    CamActor.SetLocation(CamLoc);
    CamActor.SetRotation(CamRot);
}

simulated function Tick(float deltaTime)
{
    local PlayerController PC;

    //Abbruch, falls Interaction schon erstellt wurde
    if (bHasInteraction)
        return;

    PC = Level.GetLocalPlayerController();

    if (PC != None)
    {
        PC.Player.InteractionMaster.AddInteraction("TUQ.TUQ_Interaction", PC.Player);
        bHasInteraction = true;
    }
}
//-end-

defaultproperties
{
    miniMapZoomFactor=3

    MirrorRefresh=60.00
    MirrorFOV=90.00
    MirrorDist=28.75
    MirrorDistZ=18.20

    bAlwaysRelevant=True

    DistanceScale=800.00
    players=0;
    bFreezePlayed=false
    place=-1;
    bHUD=true
    bShowMirror=true
    showHelp=false
}
