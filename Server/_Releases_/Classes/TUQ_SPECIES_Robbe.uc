//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SPECIES_Robbe extends Speciestype
      abstract;

static function string GetRagSkelName(String MeshName)
{
	return "Robbe";
}

defaultproperties
{
    PawnClassName="TUQ.TUQ_Pawn"
    MaleVoice="XGame.JuggMaleVoice"
    FemaleVoice="XGame.JuggFemaleVoice"
    GibGroup="xGame.xJuggGibGroup"
    FemaleSkeleton="TUQRunningRobbe1.TUQRobbe1"
    MaleSkeleton="TUQRunningRobbe1.TUQRobbe1"
    //MaleSoundGroup="TUHSpaceball.SB_SoundGroupClass"
    //FemaleSoundGroup="TUHSpaceball.SB_SoundGroupClass"
    SpeciesName="Robbe"
    RaceNum=6
    AirControl=0.70
    GroundSpeed=1.10
    ReceivedDamageScaling=0.70
    AccelRate=0.70
    WalkingPct=0.80
    CrouchedPct=0.80
    DodgeSpeedFactor=0.90
    DodgeSpeedZ=0.90
}
