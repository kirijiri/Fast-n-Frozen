//-----------------------------------------------------------
// der Zielbereich
//-----------------------------------------------------------
class TUQ_FinishVolume extends Volume;

function PostBeginPlay()
{
	AssociatedActor = TUQ_Game(Level.Game);
    Super.PostBeginPlay();
}

state AssociatedTouch
{
	event touch( Actor Other )
	{
		if(Other.IsA('TUQ_Pawn'))
		{
            TUQ_Game(Level.Game).Finish(TUQ_Pawn(Other).GetHumanReadableName());
        }
        //AssociatedActor.touch(Other);
	}

	event untouch( Actor Other )
	{
		AssociatedActor.untouch(Other);
	}

	function BeginState()
	{
		local Actor A;

		ForEach TouchingActors(class'Actor', A)
			Touch(A);
	}
}

defaultproperties
{
    LocationName="im Ziel"
}
