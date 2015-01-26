//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_SandBagFire extends WeaponFire;

var TUQ_SandPickUp sandy;
var vector X,Y,Z;

function DoFireEffect()
{
    GetAxes(Instigator.Controller.Rotation,X,Y,Z);

    sandy=Instigator.Spawn(class'TUQ_SandPickUp',,,Instigator.Location - 75*X);
    sandy=Instigator.Spawn(class'TUQ_SandPickUp',,,Instigator.Location - 75*X-35*Y);
    sandy=Instigator.Spawn(class'TUQ_SandPickUp',,,Instigator.Location - 75*X+35*Y);

    super.DoFireEffect();
}

DefaultProperties
{
    AmmoClass=class'TUQ_SandBagAmmo'
    AmmoPerFire=1
    FireRate=0.1
}
