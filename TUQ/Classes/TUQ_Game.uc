//-----------------------------------------------------------------------------
// Der Gametype f�r die TUQ Mod
// Beinhaltet alle �nderungen, die Spielregeln und Spielablauf betreffen,
// sowie grundlegende Einstellungen, wie z.B. Festlegung von HUD und
// Controller f�r das Spiel
//
// Author: RM
//-----------------------------------------------------------------------------
class TUQ_Game extends xDeathMatch;

//var int Players;
var int delay;
var sound StartSound;
var bool bWaiting, bReady, bRaceStarted;
var int TickClock;
var float FinishCountdown;
var bool allFinished;
var int Place;
var float myStartTime;

// Parse options for this game...
event InitGame( string Options, out string Error )
{
    Super.InitGame(Options, Error);

    //Players = Clamp(GetIntOption( Options, "Players", Players ),0,4);
    //if (Players == none)
    //    Players = 0;
    //log("-----------> Spielerzahl: "$Players);
    //MinPlayers=int(GetUrlOption("NumberOfPlayers"));
    //log("------------> MinPlayers="$MinPlayers);

    MinPlayers = 0;
    MinNetPlayers = Clamp(GetIntOption( Options, "NumberOfPlayers", MinPlayers ),1,4);
    MaxPlayers = MinNetPlayers;
    InitialBots = 0;
    bAutoNumBots = false;
    GoalScore = 0;
    TimeLimit = 0;
    bPlayersMustBeReady = true;
    bWaitForNetPlayers = true;

    Place = 1;
}

event PostLogin( PlayerController NewPlayer )
{
    local Controller P;
	local TUQ_Controller Player;

	Super.PostLogin(NewPlayer);

	/*
    if (TUQ_Controller(NewPlayer) != None)
	{
	    log("--------------------------> PostLogin! f�r "$NewPlayer.Pawn);
        TUQ_Controller(NewPlayer).ClientSetMesh(TUQ_Pawn(TUQ_Controller(NewPlayer).Pawn));
	}
	*/
    log("--------------------------> PostLogin!");

    /*
    if (NumPlayers < Players)
        bWaiting = true;
    else
        bWaiting = false;
    */

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		Player = TUQ_Controller(P);
		if (Player != None)
		{
		    //Player.ClientSetMesh(TUQ_Pawn(Player.Pawn));
		    /*
            if (bWaiting && !Player.IsInState('PlayerStartWaiting'))
		    {
		        Player.ClientGotoState('PlayerStartWaiting','Begin');
		    }

		    if (!bWaiting && !Player.IsInState('PlayerGetReady'))
		    {
		        //log("-----> Server: Starte FinalCountdown f�r "$ Player.PlayerOwnerName);
                //Player.ClientFinalCountdown();
                Player.ClientGotoState('PlayerGetReady','Begin');
            }
            */
		}
    }
}

event Tick(float DeltaTime)
{
    local Controller P;
    //local Controller P2, P3;
	local TUQ_Controller ClientPlayer;
	//local TUQ_Controller Player2, Player3;

    super.Tick(DeltaTime);

    //log("--------------------------> ServerSetMeshUpdate!");

	TickClock++;
	if (TickClock >= 100)
	{
        for(P = Level.ControllerList; P != None; P = P.nextController)
    	{
	    	ClientPlayer = TUQ_Controller(P);

		    if (ClientPlayer != None)
		    {
		        //ClientPlayer.ClientSetMesh(TUQ_Pawn(ClientPlayer.Pawn));
		    }
        }
        TickClock = 0;
    }

    if (allFinished)
    {
        if (FinishCountdown <= 0)
        {
            GotoState('MatchOver');
        }
        FinishCountdown -= DeltaTime;
    }

    /*
    // alle vollz�hlig und Rennen noch nicht gestartet
    if (!bWaiting && !bRaceStarted)
    {
        bReady = true;
        // Check, ob alle bereit zum Start
	    for(P2 = Level.ControllerList; P2 != None; P2 = P2.nextController)
	    {
		    Player2 = TUQ_Controller(P2);
		    if (Player2 != None && !Player2.IsReadyToStart)
		        bReady = false;
	    }

	    // alle bereit zum Start
        if (bReady)
	    {
	        // Final Countdown einleiten
            for(P3 = Level.ControllerList; P3 != None; P3 = P3.nextController)
	        {
		        Player3 = TUQ_Controller(P3);
		        if (Player3 != None)
		            Player3.ClientFinalCountdown();
	        }
	        bRaceStarted = true;
	    }
    }
    */
}

function Finish(string PlayerName)
{
    local Controller C;
    local TUQ_Controller aPlayer;

    allFinished = true;
    for ( C = Level.ControllerList; C != None; C = C.NextController )
    {
	    if (C.IsA('TUQ_Controller'))
        {
            if (C.Pawn.GetHumanReadableName() == PlayerName)
            {
                if (!TUQ_Controller(C).bHasFinished)
                {
                    TUQ_Controller(C).ClientSetFinished(true);
                    TUQ_Controller(C).bHasFinished = true;
                    TUQ_Controller(C).ClientStopTimer();
                    TUQ_Controller(C).ClientSetPlace(Place);
                    SetRanking(Place, C.GetHumanReadableName(), Level.TimeSeconds-myStartTime);
                    Place++;
                    TUQ_Controller(C).ClientGotoState('PlayerFinishWaiting', 'Begin');
                    log("-------------------------> "$C.GetHumanReadableName()$": bHasFinished="$TUQ_Controller(C).bHasFinished);
                    log("--------> Game... Species: "$TUQ_Pawn(C.Pawn).Species);
                }
                //TriggerEvent('FinishMovie', Self, None);  // Ziel-Matinee abspielen
                // �bergang in Wartezustand, bis alle Spieler im Ziel sind
            }

            aPlayer = TUQ_Controller(C);
            //log("--------Iteration----------> "$aPlayer.GetHumanReadableName()$": bHasFinished="$aPlayer.bHasFinished);
            if (aPlayer != none && !aPlayer.bHasFinished)
                allFinished = false;
         }
     }

     log("----------------> allFinished="$allFinished);
     if (allFinished)
     {
     }
}

function SetRanking(int Pos, string PlayerName, float Time)
{
    local Controller P;
	local TUQ_Controller ClientPlayer;

    for(P = Level.ControllerList; P != None; P = P.nextController)
  	{
    	ClientPlayer = TUQ_Controller(P);

	    if (ClientPlayer != None)
	    {
	        ClientPlayer.ClientSetRanking(Pos, PlayerName, Time);
	    }
    }
}

function StartMatch()
{
    local Controller P;

    Super.StartMatch();
    for (P=Level.ControllerList; P!=None; P=P.NextController )
        if (TUQ_Controller(P) != None)
            TUQ_Controller(P).ClientStartTimer();

    myStartTime = Level.TimeSeconds;
}

/*
auto State PendingMatch
{
	function RestartPlayer( Controller aPlayer )
	{
		if ( CountDown <= 0 )
			Super.RestartPlayer(aPlayer);
	}

    function Timer()
    {
        local Controller P;
        local bool bReady;
        local byte NeededPlayers;

        Global.Timer();

        // Warten, falls Spieler nicht vollz�hlig
        //log("-----------> NumPlayers "$Numplayers$" < Players "$Players$" ???");
        if ( NumPlayers < Players )
			bWaitForNetPlayers = true;

        if ( bWaitForNetPlayers && delay < 10 )
        {
            //log("-----------> Warten !!!");
            if ( NumPlayers >= Players )
            {
                bWaitForNetPlayers = false;
                CountDown = Default.CountDown;
            }

            //PlayStartupMessage();
            NeededPlayers = Players - NumPlayers;
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if (TUQ_Controller(P) != None)
                    TUQ_Controller(P).ClientShowWaiting(NeededPlayers);

            delay++;
            return;
        }

		// check if players are ready
        bReady = true;
        StartupStage = 1;
        if ( !bStartedCountDown && (bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone)) )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.bIsPlayer && P.PlayerReplicationInfo.bWaitingPlayer
                    && !P.PlayerReplicationInfo.bReadyToPlay )
                    bReady = false;
        }
        if ( bReady && !bReviewingJumpspots )
        {
			bStartedCountDown = true;
            CountDown--;
            if ( CountDown <= 0 )
                StartMatch();
            else
                StartupStage = 5 - CountDown;
        }
		PlayStartupMessage();
    }

    function beginstate()
    {
		bWaitingToStartMatch = true;
        StartupStage = 0;
    }

Begin:
	if ( bQuickStart )
		StartMatch();
}
*/

defaultproperties
{
     //bDelayedStart=False
     Acronym="TUQ"
     MapPrefix="TUQ"
     BeaconName="TUQ"
     Description="UT2004 Mod der Gruppe TUQ|St�rzen Sie sich in den Schnee und rasen Sie in einem rasanten Wettrennen den Berg hinab. Wer als Erster die Ziellinie �berquert, hat gewonnen. Ein tierischer Spa� f�r jung und alt."
     PlayerControllerClassName="TUQ.TUQ_Controller"
     HUDType="TUQ.TUQ_HUD"
     GameName="Fast 'n Frozen"
     DefaultPlayerClassName="TUQ.TUQ_Pawn"

     bSkipPlaySound=true
     delay=0
     StartSound=sound'TUQSounds.Sounds.PickUp1'
     bRaceStarted=false
     TickClock=0
     FinishCountdown=10.0
}
