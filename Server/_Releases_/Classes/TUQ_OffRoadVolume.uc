//------------------------------------------------------------------------------
// Dieses Volume markiert einen Bereich abseits der Rennstrecke
// Beim Eintritt wird nach einem zugehörigen Checkpoint gesucht, wohin der
// Spieler teleportiert werden kann.
//
// Author: RM
//------------------------------------------------------------------------------
class TUQ_OffRoadVolume extends PhysicsVolume;

var() string DestCheckpointTag;  // Tag des Checkpoints, zu dem man teleportiert wird

event PawnEnteredVolume(Pawn Other)
{
    local TUQ_CheckpointTeleporter Dest;

    super.PawnEnteredVolume(Other);
    log("---------------------> PawnEnteredVolume! - Offroad");

    foreach AllActors(class 'TUQ_CheckpointTeleporter', Dest)
    {
        if (Dest.CheckpointTag ~= DestCheckpointTag)
        {
            if (Dest.IsInSlideVolume())
                TUQ_Controller(Other.Controller).bLeavingState = false;
			// Pawn zum Checkpoint teleportieren
			Other.PlayTeleportEffect(false, true);
			Dest.Accept(Other, self);
			if (Other != None)
				TriggerEvent(Event, self, Other);
        }
    }
}

event PawnLeavingVolume(Pawn Other)
{
    local TUQ_CheckpointTeleporter Dest;

    super.PawnEnteredVolume(Other);
    log("---------------------> PawnLeavingVolume! - Offroad");

    foreach AllActors(class 'TUQ_CheckpointTeleporter', Dest)
    {
        if (Dest.CheckpointTag ~= DestCheckpointTag)
        {
            if (Dest.IsInSlideVolume())
                TUQ_Controller(Other.Controller).bLeavingState = false;
			// Pawn zum Checkpoint teleportieren
			Other.PlayTeleportEffect(false, true);
			Dest.Accept(Other, self);
			if (Other != None)
				TriggerEvent(Event, self, Other);
        }
    }
}

DefaultProperties
{
     LocationName="neben der Strecke"
     bSkipActorPropertyReplication=true

     TerminalVelocity=3000.000000
     FluidFriction=0.300000
     bAlwaysRelevant=true
     bOnlyDirtyReplication=true
     NetUpdateFrequency=0.100000
     Priority=6  //sollte höher sein als SlideVolume
}
