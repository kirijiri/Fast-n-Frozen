//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_AnimActor extends Actor placeable;

var(Animation) name AnimName;
var(Animation) float AnimRate;
var(Animation) float StartFrame;

simulated function PostBeginPlay()
{
    LoopAnim(AnimName,AnimRate);
    SetAnimFrame(StartFrame,,0);
    Super.PostBeginPlay();
    log("STARTFRAME="$StartFrame);
}

defaultproperties
{
    bStatic=False
    bNoDelete=True
    bStasis=False

    DrawType=DT_Mesh
    Mesh=SkeletalMesh'TUQRunningRobbe1.TUQRobbe'

    AnimName="Idle_Rifle"
    AnimRate=1

    //AmbientSound=sound'GameSounds.UT2K3Fanfare11'

    CollisionRadius=35
    CollisionHeight=3

    Physics=PHYS_Falling

    bCollideActors=true;
    //bBlockActors=true;
    //bBlockNonZeroExtentTraces=true;
    //bBlockZeroExtentTraces=true;
    bCollideWorld=true;
    StartFrame=0

    SoundVolume=20
    SoundRadius=256
}
