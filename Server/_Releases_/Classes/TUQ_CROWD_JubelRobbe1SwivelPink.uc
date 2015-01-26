//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_CROWD_JubelRobbe1SwivelPink extends TUQ_AnimActor;

simulated function PostBeginPlay()
{
    StartFrame=Rand(1000)*0.001;
    Super.PostBeginPlay();
}

DefaultProperties
{
    Mesh=SkeletalMesh'TUQCrowdRobbe1JubelA.TUQJubelRobbe1A'

    Skins[0] = Material'TUQRobbe1_Pink.shader.shader'
    Skins[1] = Material'TUQJubelRobbe1Schild.shader.shader'

    AnimName="JubelA"

    AmbientSound=sound'TUQSounds.Sounds.Robbe2'
}
