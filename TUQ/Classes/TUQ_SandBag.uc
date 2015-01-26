//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SandBag extends Weapon;

/*simulated function OutOfAmmo()
{
}*/

DefaultProperties
{
    ItemName="SandBag"

    bShowChargingBar=false
    bCanThrow=false
    FireModeClass(0)=class'TUQ_SandBagFire'
    FireModeClass(1)=class'TUQ_SandBagFire'
    InventoryGroup=2

    DrawScale=1.0

    SelectSound=sound'TUQSounds.Sounds.Clap'
}
