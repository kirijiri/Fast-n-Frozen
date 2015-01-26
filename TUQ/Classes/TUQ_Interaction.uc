//-----------------------------------------------------------
// Test für eine Interaction
// Wird verwendet, um Tastatureingaben zu verarbeiten
//-----------------------------------------------------------
class TUQ_Interaction extends Interaction;

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    if ((Action == IST_Press) && (Key == IK_1))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber1 = true;
    if ((Action == IST_Release) && (Key == IK_1))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber1 = false;

    if ((Action == IST_Press) && (Key == IK_2))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber2 = true;
    if ((Action == IST_Release) && (Key == IK_2))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber2 = false;

    if ((Action == IST_Press) && (Key == IK_3))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber3 = true;
    if ((Action == IST_Release) && (Key == IK_3))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber3 = false;

    if ((Action == IST_Press) && (Key == IK_4))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber4 = true;
    if ((Action == IST_Release) && (Key == IK_4))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber4 = false;

    if ((Action == IST_Press) && (Key == IK_5))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber5 = true;
    if ((Action == IST_Release) && (Key == IK_5))
        TUQ_Controller(ViewportOwner.Actor.Pawn.Controller).bNumber5 = false;

    return false;
}
DefaultProperties
{
    bActive=true
    bVisible=true
}
