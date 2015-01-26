//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_CROWD_JubelRobbe1SignPink extends TUQ_AnimActor;

simulated function PostBeginPlay()
{
    StartFrame=Rand(1000)*0.001;
    Super.PostBeginPlay();
}

DefaultProperties
{
    Mesh=SkeletalMesh'TUQCrowdRobbe1JubelC.TUQJubelRobbe1C'

    Skins[0] = Material'TUQRobbe1_Pink.shader.shader'
    Skins[1] = Material'TUQJubelRobbe1Schild.shader.shader'

    AnimName="JubelC"

    AmbientSound=sound'TUQSounds.Sounds.Robbe2'
}
