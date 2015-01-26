//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SandBagAmmoPickUp extends UTAmmoPickup;

DefaultProperties
{
    InventoryType=class'TUQ_SandBagAmmo'

    PickupMessage="SandBagAmmo gefunden"
    PickupSound=Sound'TUQSounds.Sounds.PickUp1'
    PickupForce="SandBagAmmoPickUp"

    AmmoAmount=10

    CollisionHeight=50.000000

    StaticMesh=StaticMesh'TUQPickups.Items.SandBag'
    DrawType=DT_StaticMesh

    RespawnTime       = 10.0

    //AmbientGlow       = 255

    RotationRate      = (Yaw=20000)
    bRotateToDesired  = false
    bFixedRotationDir = true
    Physics           = PHYS_Rotating
}
