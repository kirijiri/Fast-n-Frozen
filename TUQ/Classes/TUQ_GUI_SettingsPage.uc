//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_GUI_SettingsPage extends UT2K4SettingsPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    c_Tabs.RemoveTab(PanelCaption[0]);
    c_Tabs.RemoveTab(PanelCaption[1]);
    c_Tabs.RemoveTab(PanelCaption[2]);
    c_Tabs.RemoveTab(PanelCaption[3]);
    c_Tabs.RemoveTab(PanelCaption[4]);
    c_Tabs.RemoveTab(PanelCaption[5]);
    c_Tabs.RemoveTab(PanelCaption[6]);

    c_Tabs.AddTab("Display","TUQ.TUQ_GUI_DetailSettingsTab",, "Displayeinstellungen");
    c_Tabs.AddTab("Audio","TUQ.TUQ_GUI_AudioSettingsTab",, "Soundeinstellungen");
    c_Tabs.AddTab("Eingabe","TUQ.TUQ_GUI_IForceSettingsTab",, "Eingabeeinstellungen");

    //tp_Game = UT2K4Tab_GameSettings(c_Tabs.BorrowPanel(PanelCaption[3]));
}

DefaultProperties
{

}
