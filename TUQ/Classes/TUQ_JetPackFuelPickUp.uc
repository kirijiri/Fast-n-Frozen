//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_JetPackFuelPickUp extends UTAmmoPickup;

DefaultProperties
{
    InventoryType=class'TUQ_JetPackFuel'

    PickupMessage="JetPackFuel gefunden"
    PickupSound=Sound'TUQSounds.Sounds.PickUp1'
    PickupForce="JetPackFuelPickUp"

    AmmoAmount=100

    CollisionHeight=50.000000

    StaticMesh=StaticMesh'TUQPickups.Items.JetPack'
    DrawType=DT_StaticMesh

    RespawnTime       = 10.0

    //AmbientGlow       = 255

    RotationRate      = (Yaw=20000)
    bRotateToDesired  = false
    bFixedRotationDir = true
    Physics           = PHYS_Rotating
}
