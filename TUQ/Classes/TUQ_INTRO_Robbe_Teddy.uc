//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_INTRO_Robbe_Teddy extends TUQ_AnimActor;

simulated function PostBeginPlay()
{
    StartFrame=Rand(1000)*0.001;
    Super.PostBeginPlay();
}

DefaultProperties
{
    Mesh=SkeletalMesh'TUQIntroRobbe3.TUQRobbe'

    //Skins[0] = Material'TUQRobbe1_Blau.shader.shader'
    //Skins[1] = Material'TUQJubelRobbe1Schild.shader.shader'

    AnimName="Idle"

    //AmbientSound=sound'TUQSounds.Sounds.Robbe2'
}
