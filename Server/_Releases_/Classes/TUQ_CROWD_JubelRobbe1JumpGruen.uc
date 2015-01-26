//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_CROWD_JubelRobbe1JumpGruen extends TUQ_AnimActor;

simulated function PostBeginPlay()
{
    StartFrame=Rand(1000)*0.001;
    Super.PostBeginPlay();
}

DefaultProperties
{
    Mesh=SkeletalMesh'TUQCrowdRobbe1JubelB.TUQJubelRobbe1B'

    Skins[0] = Material'TUQRobbe1_Gruen.shader.shader'
    Skins[1] = Material'TUQJubelRobbe1Schild.shader.shader'

    AnimName="JubelB"

    AmbientSound=sound'TUQSounds.Sounds.Robbe2'
}
