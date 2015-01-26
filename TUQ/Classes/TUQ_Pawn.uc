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

// Eigene Geräuschentwicklung bei der Bewegung aufm Boden
simulated function FootStepping(int Side)
{
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End;
	local vector X,Y,Z;

	GetAxes(Rotation,X,Y,Z);

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
		PlaySound(SoundFootsteps[Rand(6)], SLOT_Interact, FootstepVolume,true,400);
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Z*32;
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if (FloorMat !=None)
            PlaySound(SoundFootsteps[Rand(6)], SLOT_Interact,VSize(Velocity)/5000,true,400);
	}
}

simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (VSize(Velocity) > 0&&TUQ_Controller(Controller).bSlide)
        FootStepping(0);
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	if ( (rec.Species == None) || class'DeathMatch'.default.bForceDefaultCharacter )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());

    //Species = rec.Species;
    Species = default.Species;
    log("-----------> Setup... Species: "$Species);

	RagdollOverride = rec.Ragdoll;
	if ( !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		if ( !Species.static.Setup(self,rec) )
			return;
	}
	ResetPhysicsBasedAnim();
}

event EncroachedBy( actor Other )
{
    //keine Funktion, um Telefrags zu verhindern...
}

simulated function PlaySlide()
{
    LoopAnim('RunF');
}

//RequiredEquipment(0)="" damit keine Waffenangerzeigt werden
defaultproperties
{
     RequiredEquipment(0)="TUQ.TUQ_JetPack"
     RequiredEquipment(1)="TUQ.TUQ_SandBag"
     RequiredEquipment(2)="TUQ.TUQ_DynamiteThrow"

     SlideMass=1
     Species=TUQ.TUQ_SPECIES
     PlacedCharacterName="Robby"
     bNoRepMesh=true

     MaxMultiJump=0

     bCanWallDodge=False

     GruntVolume=0.5

     SoundFootsteps(0)=sound'TUQSounds.Sounds.Slide1'
     SoundFootsteps(1)=sound'TUQSounds.Sounds.Slide2'
     SoundFootsteps(2)=sound'TUQSounds.Sounds.Slide3'
     SoundFootsteps(3)=sound'TUQSounds.Sounds.Slide4'
     SoundFootsteps(4)=sound'TUQSounds.Sounds.Slide5'
     SoundFootsteps(5)=sound'TUQSounds.Sounds.Slide6'
     SoundFootsteps(6)=sound'TUQSounds.Sounds.NOSOUND'
     SoundFootsteps(7)=sound'TUQSounds.Sounds.NOSOUND'
     SoundFootsteps(8)=sound'TUQSounds.Sounds.NOSOUND'
     SoundFootsteps(9)=sound'TUQSounds.Sounds.NOSOUND'
     SoundFootsteps(10)=sound'TUQSounds.Sounds.NOSOUND'

     SoundGroupClass=Class'TUQ.TUQ_SoundGroup'
}
