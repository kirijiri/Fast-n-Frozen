//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SandPickUp extends Pickup;

DefaultProperties
{
    InventoryType=class'TUQ_Sand'

    PickupMessage="Ui das kratzt..."
    PickupSound=Sound'PickupSounds.AssaultAmmoPickup'
    PickupForce="SandPickUp"

    CollisionHeight=2.000000

    StaticMesh=StaticMesh'TUQPickups.Items.Sand'
    DrawType=DT_StaticMesh

    bInstantRespawn=false;

    RespawnTime       = 0.1

    Physics           = PHYS_Falling
}
