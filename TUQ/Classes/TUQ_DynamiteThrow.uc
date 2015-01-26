//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_DynamiteThrow extends Weapon;

/*simulated function OutOfAmmo()
{
}*/

DefaultProperties
{
    ItemName="DynamiteThrow"

    bShowChargingBar=false
    bCanThrow=false
    FireModeClass(0)=class'TUQ_DynamiteFire'
    FireModeClass(1)=class'TUQ_DynamiteFire'
    InventoryGroup=3

    SelectSound=sound'TUQSounds.Sounds.Clap'
}
