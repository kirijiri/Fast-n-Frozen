//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_Mauer extends Actor placeable;

var bool TogglePlay;

var(Animation) name AnimName;
var(Animation) float AnimRate;

simulated function PostBeginPlay()
{
    StopAnimating();
    Super.PostBeginPlay();
}

simulated function Trigger(actor Other,pawn EventInstigator )
{
    local Controller P;
	local TUQ_Controller Player;

    //log("--------> Mauer getriggert von "$EventInstigator.GetHumanReadableName());
    PlayAnim(AnimName,AnimRate);

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		Player = TUQ_Controller(P);
		if (Player != None)
		{
		    Player.ClientPlayWallFX(self.Location);
		}
	}

}

DefaultProperties
{
    bStatic=False
    bNoDelete=True
    bStasis=False

    DrawType=DT_Mesh
    Mesh=SkeletalMesh'TUQMauer.Mauer'
    Skins[0] = Material'TUQCellshader_eis.Combiner.combiner_eisshader_m_farbe'

    Physics=PHYS_Flying

    AnimName="MauerPow"
    AnimRate=1
    TogglePlay=false

    bReplicateAnimations=true
}
