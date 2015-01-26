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

// für Eingabetest
var bool bHasInteraction;

// HelpScreen
var bool showHelp;

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
}

exec function MapZoomIn()
{
    if(miniMapZoomFactor<64)miniMapZoomFactor=miniMapZoomFactor*2;

    // debug
    bWallFX = true;
    WallFXTimer = 0;
}

exec function MapZoomOut()
{
    if(miniMapZoomFactor>1)miniMapZoomFactor=miniMapZoomFactor/2;
}

exec function HelpScreen()
{
    showHelp=!showHelp;
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

    tempColor = c.DrawColor; //storing the values
    tempStyle = c.Style;

    scaleX=c.ClipX/stndrtX;
    scaleY=c.ClipY/stndrtY;

    //super.DrawHUD(c);

    c.DrawColor = WhiteColor;//restore values

    if (PawnOwner.Controller.IsInState('PlayerStartWaiting'))
    {
        DrawWaitingHud(c);
    }
    else if (PawnOwner.Controller.IsInState('PlayerGetReady'))
    {
        DrawGetReadyHud(c);
    }
    else if (showHelp)
        DrawHelpScreen(c,scaleX,scaleY);
    else
    {
        DrawMirrorScreen(c,scaleX,scaleY);
        DrawMap(c,scaleX,scaleY);
        DrawPickupIcons(c,scaleX,scaleY);
        DrawHudElements(c,scaleX,scaleY);
        DrawPickUpFrame(c,scaleX,scaleY);
        //DrawJetPackFuel(c,scaleX,scaleY);
        DrawVelocity(c,scaleX,scaleY);         //Anzeige der Geschwindigkeit
        DrawSpeedNeedle(c,scaleX,scaleY);
        DrawBlips(c,scaleX,scaleY);
        DrawOwnBlip(c,scaleX,scaleY);
        DrawPlace(c,scaleX,scaleY);
        DrawTime(c,scaleX,scaleY);
        //DrawMapInfo(c);
        //DrawInfo(c);
        //DrawWeaponInfo(c);
        //DrawCrosshair(c);
        //DrawButtons(c);                        //Eingabetest
        //DrawSlideModeNotify(c);                //Anzeige für Slide-Modus
        //DrawMeshInfo(c);
    }

    if (bWallFX)
        DrawWallFX(c);

    c.DrawColor = tempColor;//restore values
    c.Style = tempStyle;
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
    local Material tex;
    tex=Material'TUQMenue.TUQMenue.TUQMenueBack';

    c.SetPos(0,0);
    c.DrawRect(texture(tex),1024*scaleX,768*scaleY);
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

    mapfactor=2048/125000;
    mapX=PawnOwner.Location.X*miniMapZoomFactor*mapfactor+1024;
    mapY=PawnOwner.Location.Y*miniMapZoomFactor*mapfactor+128;

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

    local color tempcolor;
    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;
    tenthshown=tenth%10;

    c.SetPos(180*scaleX,40*scaleY);
    if(seconds<10)
       c.DrawText(minutes$":0"$seconds$":"$tenthshown);
    else
       c.DrawText(minutes$":"$seconds$":"$tenthshown);

    c.DrawColor=tempColor;
}

function DrawPlace(Canvas c,float scaleX,float scaleY)
{
    local float x,y,xpos,ypos,xloc,yloc,distx,disty,owndistance,distance;
    local int place;
    local int players;
    local xPawn testpawn;
    local int s;
    local string sName;
    local TUQ_Controller tC;

    local color tempcolor;
    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    x=0;
    y=0;
    place=1;
    players=1;
    xloc=PawnOwner.Location.X;
    yloc=PawnOwner.Location.Y;

    distx=xloc-x;
    disty=yloc-y;

    owndistance=sqrt(distx*distx+disty*disty);

    foreach AllActors(class'xPawn', testpawn)
    {
           xpos=testpawn.Location.X;
           ypos=testpawn.Location.Y;

           if(xpos!=PawnOwner.Location.X||ypos!=PawnOwner.Location.Y)
           {
              players++;

              distx=xpos-x;
              disty=ypos-y;

              distance=sqrt(distx*distx+disty*disty);

              if(distance<owndistance)
                 place++;
           }
    }
    c.setPos(180*scaleX,25*scaleX);
    c.DrawText(place$"/"$players);

    c.DrawColor=tempcolor;

    if(place>oldPlace)
    {
        s=Rand(2)+1;
        tC=TUQ_Controller(PawnOwner.Controller);
        sName="TUQRobbe"$tC.figur+1$"Sounds.R"$tC.figur+1$"Bad"$s;
        PawnOwner.PlaySound(sound(DynamicLoadObject(sName,class'sound')),,1,true);
    }

    if(place<oldPlace)
    {
        s=Rand(2)+1;
        tC=TUQ_Controller(PawnOwner.Controller);
        sName="TUQRobbe"$tC.figur+1$"Sounds.R"$tC.figur+1$"Good"$s;
        PawnOwner.PlaySound(sound(DynamicLoadObject(sName,class'sound')),,1,true);
    }

    oldPlace=place;
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

    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=200;

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
    local xPawn testpawn;
    local float x,y,distx,disty;
    local color tempcolor;
    local float posX,posY;

    tempcolor=c.DrawColor;
    c.DrawColor.R=0;
    c.DrawColor.G=0;
    c.DrawColor.B=0;

    foreach AllActors(class'xPawn', testpawn)
    {
           x=testpawn.Location.X;
           y=testpawn.Location.Y;
           if(x!=PawnOwner.Location.X||y!=PawnOwner.Location.Y)
           {
              distx=PawnOwner.Location.X-x;
              disty=PawnOwner.Location.Y-y;

              posX=82*scaleX-4-distx/1000*miniMapZoomFactor;
              posY=83*scaleY-4-disty/1000*miniMapZoomFactor;

              if(posX>154*scaleX)posX=154*scaleX;
              if(posY>156*scaleY)posY=156*scaleY;
              if(posX<10*scaleX)posx=10*scaleX;
              if(posY<10*scaleY)posy=10*scaleY;

              c.SetPos(posX,posY);
              c.DrawRect(texture'TUQHud.TUQHud.Blib',8*scaleX,8*scaleY);
           }
    }

    c.SetPos(180*scaleX,10*scaleY);
    c.DrawText(miniMapZoomFactor);

    c.DrawColor=tempcolor;
}

function DrawOwnBlip(Canvas c,float scaleX,float scaleY)
{
    local material blibTex;
    blibTex=TexRotator'TUQHud.TUQHud.OwnBlibRot';

    c.SetPos(82*scaleX-8*scaleX,83*scaleY-8*scaleY);
    TexRotator(blibTex).Rotation.Yaw=-PawnOwner.Controller.Rotation.Yaw+32768;
    c.DrawTile(blibTex,16*scaleX,16*scaleY,0,0,16,16);//144 146 10 10
}

function DrawSpeedNeedle(Canvas c,float scaleX,float scaleY)
{
    local material needleTex;
    needleTex=TexRotator'TUQHud.TUQHud.TachoNadelRot';

    c.SetPos(769*scaleX,505*scaleY);
    TexRotator(needleTex).Rotation.Yaw=-Abs((CalculateVelocity()*75));
    c.DrawTile(needleTex,512*scaleX,512*scaleY,0,0,512,512);
}

function DrawMap(Canvas c,float scaleX,float scaleY)
{
    local float mapfactor;
    local float mapX,mapY;

    mapfactor=2048/125000;
    mapX=PawnOwner.Location.X*miniMapZoomFactor*mapfactor+1024;
    mapY=PawnOwner.Location.Y*miniMapZoomFactor*mapfactor+128;

    c.SetPos(10*scaleX,10*scaleY);
    c.DrawTile(PawnOwner.Level.RadarMapImage,144*scaleX,146*scaleY,mapX,mapY,144/miniMapZoomFactor*scaleX,146/miniMapZoomFactor*scaleY);
}

function DrawHudElements(Canvas c,float scaleX,float scaleY)
{
    c.DrawColor = WhiteColor;
    c.Style=ERenderStyle.STY_Alpha;

    //Minimap
    c.SetPos(0,0);
    c.DrawRect(texture'TUQHud.TUQHud.Minimap_Snow',512*scaleX,256*scaleY);
    //Rückspiegel
    c.SetPos((256+5)*scaleX,0);
    c.DrawRect(texture'TUQHud.TUQHud.Backview_Snow',512*scaleX,128*scaleY);
    //Itembar
    c.SetPos(512*scaleX,0);
    c.DrawRect(texture'TUQHud.TUQHud.Items_Snow',512*scaleX,128*scaleY);
    //Skala
    //c.SetPos(0,512*scaleY);
    //c.DrawRect(texture'TUQHud.TUQHud.Scale_Snow',128*scaleX,256*scaleY);
    //Tacho
    c.SetPos(512*scaleX,512*scaleY);
    c.DrawRect(texture'TUQHud.TUQHud.Tacho_Snow',512*scaleX,256*scaleY);
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
    miniMapZoomFactor=1

    MirrorRefresh=60.00
    MirrorFOV=90.00
    MirrorDist=28.75
    MirrorDistZ=18.20

    bAlwaysRelevant=True

    DistanceScale=800.00
}
