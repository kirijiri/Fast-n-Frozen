//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SPECIES extends Speciestype
      abstract;

static function string GetRagSkelName(String MeshName)
{
	return "TUQ_Getier";
}

defaultproperties
{
    PawnClassName="TUQ.TUQ_Pawn"
    //MaleVoice="XGame.JuggMaleVoice"
    //FemaleVoice="XGame.JuggFemaleVoice"
    //GibGroup="xGame.xJuggGibGroup"
    FemaleSkeleton="TUQRunningRobbe1.TUQRobbe"
    MaleSkeleton="TUQRunningRobbe1.TUQRobbe"
    MaleSoundGroup="TUQ.TUQ_SoundGroup"
    FemaleSoundGroup="TUQ.TUQ_SoundGroup"
    SpeciesName="TUQ_Getier"
    RaceNum=99
    AirControl=0.70
    GroundSpeed=1.10
    ReceivedDamageScaling=0.70
    AccelRate=0.70
    WalkingPct=0.80
    CrouchedPct=0.80
    DodgeSpeedFactor=0.90
    DodgeSpeedZ=0.90
}
