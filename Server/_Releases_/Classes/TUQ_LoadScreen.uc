//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_LoadScreen extends UT2K4LoadingPageBase;

#exec OBJ LOAD FILE=Textures\TUQMenue.utx

simulated event Init()
{
    Super.Init();

	SetImage();
	SetText();
}

simulated function SetImage()
{
    local int image;
    local texture imageTex;

    image=Rand(4)+1;
    imageTex=texture(DynamicLoadObject("TUQLoadScreens.LS"$image, class'texture'));

    DrawOpImage(Operations[0]).Image=imageTex;
}

simulated function string StripMap(string s)
{
	local int p;

	p = len(s);
	while (p>0)
	{
		if ( mid(s,p,1) == "." )
		{
			s = left(s,p);
			break;
		}
		else
		 p--;
	}

	p = len(s);
	while (p>0)
	{
		if ( mid(s,p,1) == "\\" || mid(s,p,1) == "/" || mid(s,p,1) == ":" )
			return Right(s,len(s)-p-1);
		else
		 p--;
	}

	return s;
}

simulated function SetText()
{
    DrawOpText(Operations[1]).Top=0.80;
	DrawOpText(Operations[1]).Text = "Lade...";
    DrawOpText(Operations[2]).Top=0.9;
	DrawOpText(Operations[2]).Text = StripMap(MapName);
}

defaultproperties
{
     Operations(0)=DrawOpImage'GUI2K4.UT2K4ServerLoading.OpBackground'
     Operations(1)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpLoading'
     Operations(2)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpMapname'
     Operations(3)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpHint'
}

