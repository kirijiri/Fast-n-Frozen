//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_DynamiteThrowAmmoPickUp extends UTAmmoPickup;

DefaultProperties
{
    InventoryType=class'TUQ_DynamiteThrowAmmo'

    PickupMessage="DynamiteThrowAmmo gefunden"
    PickupSound=Sound'TUQSounds.Sounds.PickUp1'
    PickupForce="DynamiteThrowAmmoPickUp"

    AmmoAmount=1

    CollisionHeight=50.000000

    StaticMesh=StaticMesh'TUQPickups.Items.Dynamite'
    DrawType=DT_StaticMesh

    RespawnTime       = 10.0

    //AmbientGlow       = 255

    RotationRate      = (Yaw=20000)
    bRotateToDesired  = false
    bFixedRotationDir = true
    Physics           = PHYS_Rotating
}
