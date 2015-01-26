//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_JetPack extends Weapon config(user);

//var TUQ_JetPackTrail JetPackTrailLeft;
//var TUQ_JetPackTrail JetPackTrailRight;
//var bool canMakeNewTrail;
//var vector X,Y,Z;
//var sound FireSound;


/*simulated function OutOfAmmo()
{
}*/

simulated function SetAmmo(int AmmoCount)
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = AmmoCount;
		if ( (AmmoClass[1] != None) && (AmmoClass[0] != AmmoClass[1]) )
			AmmoCharge[1] = AmmoCount;
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = AmmoCount;
	if ( Ammo[1] != None )
		Ammo[1].AmmoAmount = AmmoCount;
}

/*
simulated function bool StartFire(int Mode)
{
    if (!TUQ_Controller(Instigator.Controller).IsInState('PlayerSliding'))
        return false;

    return super.StartFire(mode);
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if (!TUQ_Controller(Instigator.Controller).IsInState('PlayerSliding'))
        return;

    super.ClientStartFire(mode);
}

//// server only ////
event ServerStartFire(byte Mode)
{
    if (!TUQ_Controller(Instigator.Controller).IsInState('PlayerSliding'))
        return;

    super.ServerStartFire(mode);
}
*/

/*
simulated event StopFire(int Mode)
{
    super.StopFire(Mode);

    if(JetPackTrailLeft!=none)JetPackTrailLeft.Kill();
    if(JetPackTrailRight!=none)JetPackTrailRight.Kill();
    canMakeNewTrail=true;
}

simulated function bool IsFiring()
{
    if(AmmoAmount(0)<=0)
    {
        if(JetPackTrailLeft!=none)JetPackTrailLeft.Kill();
        if(JetPackTrailRight!=none)JetPackTrailRight.Kill();
        canMakeNewTrail=true;
    }

    return super.IsFiring();
}
*/

DefaultProperties
{
    ItemName="JetPack"

    bShowChargingBar=false
    bCanThrow=false
    FireModeClass(0)=class'TUQ_JetPackFire'
    FireModeClass(1)=class'TUQ_JetPackFire'
    InventoryGroup=1

    SelectSound=sound'TUQSounds.Sounds.Clap'

    //FireSound=sound'TUQSounds.Sounds.Drip'
}
