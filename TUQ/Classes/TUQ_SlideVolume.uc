//------------------------------------------------------------------------------
// Dieses Volume markiert einen Bereich, in dem gerutscht wird
// Beim Eintritt wird PlayerSliding für den Pawn aktiv
// Beim Austritt wird bLeavingState gesetzt, für sanftes Abbremsen und Übergang
// zu PlayerWalking, siehe TUQ_Controller
//
// Author: RM
//------------------------------------------------------------------------------
class TUQ_SlideVolume extends PhysicsVolume;

event PawnEnteredVolume(Pawn Other)
{
    super.PawnEnteredVolume(Other);
    //log("---------------------> PawnEnteredVolume!");
    TUQ_Controller(Other.Controller).GotoState('PlayerSliding');
}

event PawnLeavingVolume(Pawn Other)
{
    super.PawnLeavingVolume(Other);
    //log("---------------------> PawnLeavingVolume!");
    //TUQ_Controller(Other.Controller).GotoState('PlayerWalking');
    TUQ_Controller(Other.Controller).bLeavingState = true;
}

DefaultProperties
{
     LocationName="am rutschen"
     bSkipActorPropertyReplication=true

     TerminalVelocity=3000.000000
     FluidFriction=0.300000
     KBuoyancy=1.000000
     bAlwaysRelevant=true
     bOnlyDirtyReplication=true
     NetUpdateFrequency=0.100000
     Priority=5
}
