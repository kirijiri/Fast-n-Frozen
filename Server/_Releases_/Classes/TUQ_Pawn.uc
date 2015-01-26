//-----------------------------------------------------------------------------
// Der PlayerPawn für die TUQ Mod
// Repräsentiert die Figur, die der Spieler durchs Level steuert
//
// Author: RM
//-----------------------------------------------------------------------------
class TUQ_Pawn extends xPawn;

// für Slide-Modus
var float SlideMass;      // Masse des Pawn
var vector SlideForce;    // RutschKraft, die auf den Pawn wirkt
var vector StrafeForce;   // Kraft vom seitwärts Beschleunigen/Bremsen

// für Waffen/PickUpIcons
//var bool bSandBraking;
var TUQ_JetPackTrail JetPackTrailLeft;
var TUQ_JetPackTrail JetPackTrailRight;

// Überschrieben, um zu verhindern, dass man Schaden nehmen kann
function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
{
    //log("---------> Schaden von "$self$" verhindert!");
    if (Health < 1000)
        Health += Damage;  // Schaden heilt Spieler ^-^
}

// Falls man dennoch tot umfällt... z.B. durch Suicide oder Disconnect
function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	// non-ragdoll death fallback
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    SetInvisibility(0.0);
    //PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

// Synchronisieren der Meshs beim Spawnen
simulated function AssignInitialPose()
{
    TUQ_Controller(Controller).ServerSetInitialMesh();
}

//RequiredEquipment(0)="" damit keine Waffenangerzeigt werden
defaultproperties
{
     RequiredEquipment(0)="TUQ.TUQ_JetPack"
     RequiredEquipment(1)="TUQ.TUQ_SandBag"
     RequiredEquipment(2)="TUQ.TUQ_DynamiteThrow"

     SlideMass=1.0
     //Species=Class'TUQ_SPECIES_Robbe'
     bNoRepMesh=true

     //bSandBraking=false;
}
