//-----------------------------------------------------------
// Der gezeigte Text, wenn man auf Mitspieler Wartet
//-----------------------------------------------------------
class TUQ_WaitingMessage extends LocalMessage;

var localized string Status[4];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.Status[Switch];
}

DefaultProperties
{
    Status(0)="Warte auf weitere Mitspieler...";
    Status(1)="Warte auf 1 weiteren Mitspieler...";
    Status(2)="Warte auf 2 weitere Mitspieler...";
    Status(3)="Warte auf 3 weitere Mitspieler...";
    bFadeMessage=true
    DrawColor=(B=55,G=255,R=55,A=255)
     PosX=0.500000
     PosY=0.500000
}
