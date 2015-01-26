//------------------------------------------------------------------------------
// Hierhin wird man teleportiert, wenn man zu einem Checkpoint zurückkehrt
// Zur Sicherheit ist bEnabled=false, da es sich nicht um einen aktiven
// Teleporter handelt, sondern nur um eine Art Respawn-Punkt
//
// Author: RM
//------------------------------------------------------------------------------
class TUQ_CheckpointTeleporter extends Teleporter;

var() string CheckpointTag;    // Tag des Checkpoints

simulated function bool IsInSlideVolume()
{
	local Volume V;

	ForEach TouchingActors(class'Volume',V)
		if (V.IsA('TUQ_SlideVolume'))
			return true;
	return false;
}

// Accept an actor that has teleported in.
simulated function bool Accept( actor Incoming, Actor Source )
{
	local rotator newRot, oldRot;
	local float mag;
	local vector oldDir;
	local Controller P;

	if ( Incoming == None )
		return false;

	// Move the actor here.
	Disable('Touch');
	newRot = Incoming.Rotation;
	if (bChangesYaw)
	{
		oldRot = Incoming.Rotation;
		newRot.Yaw = Rotation.Yaw;
		//log("-------> Setze neue Rotation: "$newRot$" --- alte Rot: "$oldRot);
		//if ( Source != None )
		//	newRot.Yaw += (32768 + Incoming.Rotation.Yaw - Source.Rotation.Yaw);
	}

	if ( Pawn(Incoming) != None )
	{
		//tell enemies about teleport
		if ( Role == ROLE_Authority )
			For ( P=Level.ControllerList; P!=None; P=P.NextController )
				if ( P.Enemy == Incoming )
					P.LineOfSightTo(Incoming);

		if ( !Pawn(Incoming).SetLocation(Location) )
		{
			log(self$" Teleport failed for "$Incoming);
			return false;
		}
		if ( (Role == ROLE_Authority)
			|| (Level.TimeSeconds - LastFired > 0.5) )
		{
			newRot.Roll = 0;
			Pawn(Incoming).SetRotation(newRot);
			Pawn(Incoming).SetViewRotation(newRot);
			Pawn(Incoming).ClientSetRotation(newRot);
			LastFired = Level.TimeSeconds;
		}
		if ( Pawn(Incoming).Controller != None )
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0;
			Pawn(Incoming).Anchor = self;
			Pawn(Incoming).SetMoveTarget(self);
		}
		Incoming.PlayTeleportEffect(false, true);
	}
	else
	{
		if ( !Incoming.SetLocation(Location) )
		{
			Enable('Touch');
			return false;
		}
		if ( bChangesYaw )
			Incoming.SetRotation(newRot);
	}
	Enable('Touch');

	if (bChangesVelocity)
		Incoming.Velocity = TargetVelocity;
	else
	{
		if ( bChangesYaw )
		{
			if ( Incoming.Physics == PHYS_Walking )
				OldRot.Pitch = 0;
			oldDir = vector(OldRot);
			mag = Incoming.Velocity Dot oldDir;
			Incoming.Velocity = Incoming.Velocity - mag * oldDir + mag * vector(Incoming.Rotation);
		}
		if ( bReversesX )
			Incoming.Velocity.X *= -1.0;
		if ( bReversesY )
			Incoming.Velocity.Y *= -1.0;
		if ( bReversesZ )
			Incoming.Velocity.Z *= -1.0;
	}
	return true;
}

DefaultProperties
{
     bEnabled=false
     bChangesYaw=true
     bChangesVelocity=true
}
