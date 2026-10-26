#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <map>
#include <vector>
#include "Client.h"
#include "Engine/Source/Base/Base.h"
#include "Engine/Source/Base/CmdLine.h"
#include "Engine/Source/BlizzardCore/OggDecompress.h"
#include "Engine/Source/BlizzardCore/SFile2-Core.h"
#include "Engine/Source/BlizzardCore/Source/Packages/Streaming/Manifests.h"
#include "Engine/Source/BlizzardCore/Source/Packages/Streaming/Streaming.h"
#include "Engine/Source/BlizzardCore/Source/Packages/Streaming/Tracker.h"
#include "Engine/Source/BlizzardCore/Source/Packages/Util/SHA1.h"
#include "Engine/Source/BlizzardCore/Source/System/Time/Time.h"
#include "Engine/Source/ConsoleBase/ConsoleCommand.h"
#include "Engine/Source/ConsoleBase/ConsoleVar.h"
#include "Engine/Source/ConsoleBase/IConsole.h"
#include "Engine/Source/ConsoleBase/Types.h"
#include "Engine/Source/Event/Event.h"
#include "Engine/Source/Frame/CSimpleRender.h"
#include "Engine/Source/Tempest/CImVector.h"
#include "Engine/Source/FrameScript/FrameScript.h"
#include "Engine/Source/FrameXML/FrameXML.h"
#include "Engine/Source/FrameXML/XMLTree.h"
#include "Engine/Source/Gx/CGxDevice/CGxDevice.h"
#include "Engine/Source/Gx/Gx.h"
#include "Engine/Source/Gxu/GxuLight.h"
#include "Engine/Source/lua-5.1/src/lua.h"
#include "Engine/Source/Model2/M2Cache.h"
#include "Engine/Source/Os/Gui.h"
#include "Engine/Source/Os/Input.h"
#include "Engine/Source/Os/OsFile.h"
#include "Engine/Source/Os/OsIME.h"
#include "Engine/Source/Os/Path.h"
#include "Engine/Source/Os/System.h"
#include "Engine/Source/Os/Time.h"
#include "Engine/Source/Os/TimeManager.h"
#include "Engine/Source/Scrn/Scrn.h"
#include "Engine/Source/Services/AsyncFile.h"
#include "Engine/Source/Services/ModelBlob.h"
#include "Engine/Source/Services/Profile.h"
#include "Engine/Source/Services/SysMessage.h"
#include "Engine/Source/Services/Texture.h"
#include "Engine/Source/SoundEngine/SoundCache.h"
#include "Engine/Source/Storm/H/storm.h"
#include "Engine/Source/Storm/Source/MD5.h"
#include "Engine/Source/Tempest/CRandom.h"
#include "WoW/Common/ComponentCore/CharacterComponent.h"
#include "WoW/Source/Console/ConsoleClient.h"
#include "WoW/Source/ConsoleDevice/ConsoleDevice.h"
#include "WoW/Source/DB/DBClient/DBCacheInstances.h"
#include "WoW/Source/DB/DBClient/DBClient.h"
#include "WoW/Source/DB/Rec/Cfg_ConfigsRec.h"
#include "WoW/Source/DB/Rec/MapRec.h"
#include "WoW/Source/Game/DeclinedWords.h"
#include "WoW/Source/Game/GameClient/ComSatClient.h"
#include "WoW/Source/Game/GameClient/PlayerName.h"
#include "WoW/Source/Game/GameClient/WardenClient.h"
#include "WoW/Source/Game/GameClient/WTOBJECT.h"
#include "WoW/Source/Game/GameTime.h"
#include "WoW/Source/Game/ValidateName.h"
#include "WoW/Source/GameClientCommands.h"
#include "WoW/Source/Glue/CGlueMgr.h"
#include "WoW/Source/Glue/GlueMgr.h"
#include "WoW/Source/Hardware.h"
#include "WoW/Source/LoadingScreen.h"
#include "WoW/Source/Magic/MagicClient/Spell_C.h"
#include "WoW/Source/Magic/MagicClient/SpellVisuals.h"
#include "WoW/Source/Net/NetClient/NetClient.h"
#include "WoW/Source/Object/ObjectClient/Container_C.h"
#include "WoW/Source/Object/ObjectClient/Corpse_C.h"
#include "WoW/Source/Object/ObjectClient/DynamicObject_C.h"
#include "WoW/Source/Object/ObjectClient/Effect_C.h"
#include "WoW/Source/Object/ObjectClient/GameObject_C.h"
#include "WoW/Source/Object/ObjectClient/Item_C.h"
#include "WoW/Source/Object/ObjectClient/LootRoll.h"
#include "WoW/Source/Object/ObjectClient/Missile_C.h"
#include "WoW/Source/Object/ObjectClient/Movement_C.h"
#include "WoW/Source/Object/ObjectClient/ObjectEffect.h"
#include "WoW/Source/Object/ObjectClient/Player_C.h"
#include "WoW/Source/Object/ObjectClient/Trade_C.h"
#include "WoW/Source/Object/ObjectClient/Unit_C.h"
#include "WoW/Source/ObjectAlloc/HeapUsage.h"
#include "WoW/Source/ObjectAlloc/ObjectAlloc.h"
#include "WoW/Source/ObjectMgrClient/ObjectMgrClient.h"
#include "WoW/Source/Game/GameClient/WorldText.h"
#include "WoW/Source/SoundInterface/SoundInterface2.h"
#include "WoW/Source/Ui/AddOns.h"
#include "WoW/Source/Ui/BarberShop.h"
#include "WoW/Source/Ui/BattlenetUI.h"
#include "WoW/Source/Ui/ChatFrame.h"
#include "WoW/Source/Ui/GameUI.h"
#include "WoW/Source/Ui/LootFrame.h"
#include "WoW/Source/NativeUIFormat.h"
#include "WoW/Source/NativeUIReader.h"
#include "WoW/Source/NativeUIProtocol.h"
#include "WoW/Source/Ui/PartyFrame.h"
#include "WoW/Source/Ui/ScriptEvents.h"
#include "WoW/Source/Ui/Tutorial.h"
#include "WoW/Source/Ui/Types.h"
#include "WoW/Source/Ui/WorldFrame.h"
#include "WoW/Source/UIUtil/BannedAddOns.h"
#include "WoW/Source/UIUtil/Camera.h"
#include "WoW/Source/UIUtil/InputControl.h"
#include "WoW/Source/UIUtil/SmartScreenRect.h"
#include "WoW/Source/WorldClient/AreaList.h"
#include "WoW/Source/WorldClient/FrameTime.h"
#include "WoW/Source/WorldClient/Map.h"
#include "WoW/Source/WorldClient/MapWeather.h"
#include "WoW/Source/WorldClient/shadow.h"
#include "WoW/Source/WorldClient/World.h"
#include "WoW/Source/WorldClient/WorldParam.h"
#include "WoW/Source/WowServices/PatchFiles.h"
#include "WoW/Source/WowServices/RealmConnection.h"
#include "WoW/Source/WowServices/WDataStore.h"
#include "WoW/Source/WowSvcs/WowSvcsClient/AccountData.h"
#include "WoW/Source/WowSvcs/WowSvcsClient/ClientServices.h"
#include "WoW/Source/WowSvcs/WowSvcsClient/FriendList.h"
#include "WoW/Source/WowSysMessageOutput.h"
#include "GameVersion.h"

namespace {

class ForEveryRunOnceWTF {
    public:
    /* 0000 */ TSGrowableArray<char*> m_files;

    static int32_t AppendFileName(OS_FILE_DATA& data, void* param);
    static int FileNameCompare(const void* a, const void* b);

    void Execute(int32_t (*callback)(const char*));
};

}

// STATIC: 0x009E1BE0
static const _ARGLIST s_wowArgList[] = {
    { 0, CMD_RES_800x600, "800x600", nullptr },
    { 0, CMD_RES_1024x768, "1024x768", nullptr },
    { 0, CMD_RES_1280x960, "1280x960", nullptr },
    { 0, CMD_RES_1280x1024, "1280x1024", nullptr },
    { 0, CMD_RES_1600x1200, "1600x1200", nullptr },
    { 0, CMD_16_BIT, "16bit", nullptr },
    { 0, CMD_UP_TO_DATE, "uptodate", nullptr },
    { 0, CMD_NO_SOUND, "nosound", nullptr },
    { 0, CMD_SOUND_CHAOS, "soundchaos", nullptr },
    { 0, CMD_NO_FIX_LAG, "nofixlag", nullptr },
    { 0, CMD_DEPTH_16, "d16", nullptr },
    { 0, CMD_DEPTH_24, "d24", nullptr },
    { 0, CMD_DEPTH_32, "d32", nullptr },
    { 0, CMD_WINDOWED, "windowed", nullptr },
    { 0, CMD_HW_DETECT, "hwdetect", nullptr },
    { 0, CMD_CONSOLE, "console", nullptr },
    { 0x20000, CMD_GX_OVERRIDE, "gxoverride", nullptr },
};

// STATIC: 0x00AB6164
static uint32_t s_startArchivePriority = 0x40;

// STATIC: 0x00AB6168
static ARCHIVEINFO s_archives[28] = {
    { "alternate.MPQ", 3, 3, false },
    { "interface.MPQ", 1, 1, false },
    { "misc.MPQ", 1, 1, false },
    { "model.MPQ", 1, 1, false },
    { "texture.MPQ", 1, 1, false },
    { "terrain.MPQ", 1, 1, false },
    { "wmo.MPQ", 1, 1, false },
    { "sound.MPQ", 1, 1, false },
    { "fonts.MPQ", 1, 1, false },
    { "dbc.MPQ", 1, 1, false },
    { "speech.MPQ", 1, 1, false },
    { "expansionloc.MPQ", 2, 1, false },
    { "lichkingloc.MPQ", 2, 1, false },
    { "expansionspeech.MPQ", 2, 1, false },
    { "lichkingspeech.MPQ", 2, 1, false },
    { "expansion.MPQ", 2, 3, false },
    { "lichking.MPQ", 2, 3, false },
    { "common.MPQ", 1, 2, false },
    { "common-2.MPQ", 2, 2, false },
    { "****\\locale-****.MPQ", 1, 2, false },
    { "****\\speech-****.MPQ", 1, 2, false },
    { "****\\expansion-locale-****.MPQ", 2, 2, false },
    { "****\\lichking-locale-****.MPQ", 2, 2, false },
    { "****\\expansion-speech-****.MPQ", 2, 2, false },
    { "****\\lichking-speech-****.MPQ", 2, 2, false },
    { "development.MPQ", 2, 1, false },
    { "streaming.MPQ", 4, 1, false },
    { "streamingloc.MPQ", 4, 1, false },
};
// STATIC: 0x009E0DA4
static const uint8_t s_signatureExponent[4] = { 0x01, 0x00, 0x01, 0x00 };

// STATIC: 0x00AB6028
static const uint8_t s_signatureModulus[256] = {
    0x4F, 0x6F, 0xD4, 0x65, 0x56, 0x85, 0x88, 0xD9, 0xAA, 0xE6, 0xF7, 0x05, 0x72, 0xBB, 0x2A, 0x20,
    0xE0, 0x24, 0x38, 0x2B, 0x77, 0xB3, 0x3D, 0xC2, 0xD3, 0x2D, 0x52, 0x5C, 0xB7, 0xA3, 0x0F, 0xE6,
    0x0F, 0x80, 0x93, 0x8D, 0x5C, 0xC4, 0x81, 0x5E, 0x9D, 0x58, 0x8E, 0xCA, 0xA6, 0x6F, 0x27, 0x36,
    0x52, 0x58, 0x0D, 0xCE, 0x65, 0xE2, 0xB5, 0x7A, 0xD2, 0x39, 0x74, 0x8A, 0xAC, 0xAA, 0xC1, 0x0E,
    0xE5, 0x67, 0x2B, 0x79, 0xC1, 0xFE, 0x08, 0x96, 0x54, 0x18, 0x2A, 0x34, 0x31, 0xA4, 0x06, 0x20,
    0x4B, 0x12, 0xD2, 0x47, 0x63, 0x53, 0x36, 0x38, 0x19, 0x88, 0x8E, 0x50, 0x2F, 0x2F, 0xD1, 0x68,
    0xC8, 0x5C, 0x9D, 0x3B, 0xDE, 0xFE, 0x56, 0x21, 0xD1, 0x59, 0x4D, 0x1C, 0x32, 0x1B, 0x70, 0x4B,
    0x40, 0xE2, 0x5E, 0x0C, 0x0E, 0x4B, 0x84, 0xD5, 0xD7, 0x52, 0x00, 0x50, 0x65, 0x81, 0xCE, 0x17,
    0x53, 0x25, 0x49, 0x9E, 0x40, 0xE9, 0x04, 0x94, 0x2C, 0xA7, 0x93, 0x5C, 0x5D, 0x54, 0xC8, 0xF9,
    0x6E, 0xD0, 0x69, 0xFC, 0xE5, 0x8F, 0xC0, 0xB6, 0x76, 0xF2, 0xEB, 0x34, 0x67, 0x9F, 0xF8, 0xD0,
    0x34, 0xB9, 0xEA, 0x9E, 0x80, 0xD0, 0x29, 0x8D, 0xB4, 0xB2, 0xEB, 0x3E, 0xF4, 0x4F, 0xD0, 0x84,
    0x43, 0x15, 0xF4, 0x19, 0xE3, 0xC6, 0x52, 0xA2, 0x18, 0x40, 0x08, 0x07, 0x21, 0xF4, 0x20, 0xEC,
    0xE6, 0x5A, 0x9C, 0x2B, 0x08, 0xF6, 0x17, 0x97, 0x72, 0xA6, 0xD7, 0xAB, 0x64, 0x0B, 0x04, 0x95,
    0x93, 0x0D, 0xCC, 0x8F, 0x02, 0x30, 0x91, 0xA2, 0xEE, 0x30, 0xE6, 0x5F, 0x2F, 0xD4, 0x13, 0xB5,
    0x5D, 0xCA, 0x5D, 0xCF, 0x7D, 0xC3, 0x6F, 0x6B, 0x9D, 0xBC, 0x6D, 0x86, 0x4C, 0x91, 0xC5, 0x51,
    0xE8, 0xFD, 0xA6, 0x33, 0x10, 0xD1, 0x12, 0x8F, 0x05, 0x80, 0xDA, 0x42, 0x57, 0x0C, 0xEB, 0xC0,
};
// STATIC: 0x00AB6158
static const char* s_dataDirectories[3] = { "Data\\", "..\\Data\\", "Data\\" };

// STATIC: 0x00AB6350
WowClientDB<Startup_StringsRec> g_startup_StringsDB;

// STATIC: 0x00AD2FE0
const char* s_iniLocaleNames[9] = { "enUS", "koKR", "frFR", "deDE", "zhCN", "zhTW", "esES", "esMX", "ruRU" };

// STATIC: 0x00AD3004
uint32_t s_localeIds[9] = { 'enUS', 'koKR', 'frFR', 'deDE', 'zhCN', 'zhTW', 'esES', 'esMX', 'ruRU' };

// STATIC: 0x00B2F99C
int32_t s_region;

// STATIC: 0x00B2F9E1
uint8_t s_expansionLevel;

// STATIC: 0x00B2FA14
static uint32_t s_numPatchArchives;

// STATIC: 0x00B2FA18
static uint32_t s_firstBaseArchive;

// STATIC: 0x00B2FA30
CRndSeed g_rndSeed(0);

// STATIC: 0x00B2FA38
static TSGrowableArray<SArchive*> s_archiveHandles;

// STATIC: 0x00B2FE48
static char s_iniLocale[5];
// STATIC: 0x00AB6128
static const EGxTexFilter s_textureFilterModes[] = { GxTex_LinearMipNearest, GxTex_LinearMipLinear, GxTex_Anisotropic, GxTex_Anisotropic, GxTex_Anisotropic, GxTex_Anisotropic };

// STATIC: 0x00AB6140
static const uint32_t s_textureMaxAnisotropy[] = { 1, 1, 2, 4, 8, 16 };

// STATIC: 0x00B2F050
static uint32_t s_streamingDiag;

// STATIC: 0x00B2F059
static char s_streamingError[2051];

// STATIC: 0x00B2F994
HEVENTCONTEXT g_clientEventContext;

// STATIC: 0x00B2F9A4
static int32_t s_closeErrorStringId;

// STATIC: 0x00B2F9D8
static uint32_t s_timeTestError;

// STATIC: 0x00B2FA10
static uint32_t s_unk_B2FA10;

// STATIC: 0x00B2FA48
static char s_installLocation[1024];

// STATIC: 0x00C5DE90
bool g_hasIsoLocale[NUM_DB_LOCALES];

// STATIC: 0x00C5DE9C
int32_t s_locale;

// STATIC: 0x00B2F040
static const char* s_directory;

// STATIC: 0x00B2F044
static float s_spawnRotation;

// STATIC: 0x00B2F048
static uint32_t s_zoneID;

// STATIC: 0x00B2F998
int32_t s_isPvPRealm;

// STATIC: 0x00B2F9A0
static int32_t s_gameInitialized;

// STATIC: 0x00B2F9A8
static int32_t s_clientTaxiBenchIsOnTaxi;

// STATIC: 0x00B2F9AC
static int32_t s_clientTaxiBenchEnabled;

// STATIC: 0x00B2F9B0
static double s_clientTaxiBenchMinFPS;

// STATIC: 0x00B2F9B8
static double s_clientTaxiBenchMaxFPS;

// STATIC: 0x00B2F9C0
static double s_clientTaxiBenchTotalTime;

// STATIC: 0x00B2F9C8
static uint32_t s_clientTaxiBenchTotalFrames;

// STATIC: 0x00B2F9CC
static uint32_t s_clientTaxiBenchDelayTime;

// STATIC: 0x00B2F9D0
static uint64_t s_clientTaxiTimestamp;

// STATIC: 0x00B2F9E0
uint8_t s_botCheckEnabled;

// STATIC: 0x00B2F9E4
static uint32_t s_botCheckStartTime;

// STATIC: 0x00B2F9E8
int32_t s_botCheckDelay;

// STATIC: 0x00B2FA0C
volatile long s_additionalCheckArmed;

// STATIC: 0x00B2FA1C
static C3Vector s_spawnPosition;

// STATIC: 0x00B2FE50
template <>
CommandManager* StaticSingleton<CommandManager>::m_instance = nullptr;

// VERIFY: 3c887aa5 manual
// OFFSET: 0x004031C0
static int32_t ListArchiveFilter(const char* fileName, void* param) {
    ARCHIVELISTPARAMS* params = static_cast<ARCHIVELISTPARAMS*>(param);

    if (SStrCmpI(fileName, params->m_prefix, params->m_prefixLength)) {
        return 1;
    }

    return params->m_callback(fileName, params->m_param);
}

// VERIFY: 4bb4cdc6 auto
// OFFSET: 0x004049F0
static void ListArchives(const char* prefix, int32_t index, int32_t (*callback)(const char* fileName, void* param), void* param) {
    ARCHIVELISTPARAMS params;
    params.m_prefix = prefix;
    params.m_prefixLength = SStrLen(prefix);
    params.m_callback = callback;
    params.m_param = param;

    for (uint32_t i = 0; i < s_numPatchArchives; i++) {
        SFile::List(s_archiveHandles.m_data[i], ListArchiveFilter, &params);
    }

    SArchive* archive = s_archiveHandles.m_data[index + s_firstBaseArchive];

    if (archive) {
        SFile::List(archive, ListArchiveFilter, &params);
    }
}

// VERIFY: b482037d manual
// OFFSET: 0x00401220
CommandManager::~CommandManager() {
    for (uint32_t i = 0; i < this->m_count; i++) {
        this->m_commands[i]->Uninstall();
        delete this->m_commands[i];
    }
}

// VERIFY: 8b322739 manual
// OFFSET: 0x00401280
int32_t Packet_SMSG_NOTIFICATION(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    char text[4096];
    const char* message = text;
    bool show = true;
    bool chat = false;
    msg->GetString(text, sizeof(text));

    if (!SStrCmp(text, "DEBUGACTION: ", 13)) {
        message = &text[13];
    }

    if (*message != '~') {
        CGGameUI::AddErrorMessage(message, 1);
        ConsoleWriteA("%s", ERROR_COLOR, message);
        return 1;
    }

    message++;

    if (*message == '>') {
        show = false;
        message++;
    }

    if (*message == '#') {
        show = false;
        chat = true;
        message++;
    }

    int32_t type = 0;
    int32_t color = ERROR_COLOR;

    if (*message == '^') {
        type = message[1] - '0';
        color = type;
        message += 2;
    }

    if (show) {
        CGGameUI::AddErrorMessage(message, color == ERROR_COLOR);
    }

    ConsoleWriteA("%s", static_cast<COLOR_T>(color), message);

    if (chat) {
        CGChat::AddChatMessage(message, type, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID(), 0, WOWGUID(), 0, false, nullptr);
    }

    return 1;
}

// VERIFY: 004111ad auto
// OFFSET: 0x00401520
static void MovementInit() {
    char logFile[260];

    if (!SRegLoadString("World of Warcraft\\Client", "MoveLogFile", 0, logFile, sizeof(logFile)) || !logFile[0]) {
        SRegSaveString("World of Warcraft\\Client", "MoveLogFile", 0, "ClientMovement.txt");
        SStrCopy(logFile, "ClientMovement.txt", sizeof(logFile));
    }

    uint32_t processId = SGetCurrentProcessId();
    char* extension = SStrChrR(logFile, '.');
    SStrPrintf(extension, logFile + sizeof(logFile) - extension, "%04d.txt", processId);
    MovementInitialize(logFile);
    EventRegisterEx(EVENT_ID_IDLE, MovementIdleMoveUnits, nullptr, 2.0f);
}

// VERIFY: abdc92c0 auto
// OFFSET: 0x00401FD0
static int32_t PollNet(const void* data, void* param) {
    RealmConnection::PollNet(nullptr, nullptr);
    WardenClient_Process();
    return 1;
}

// VERIFY: dba6d823 auto
// OFFSET: 0x004020E0
static int32_t EnableCallback(const void* data, void* param) {
    const EVENT_DATA_UPDATE* update = static_cast<const EVENT_DATA_UPDATE*>(data);
    FrameTime::Update(update->m_elapsedSec, update->m_time);
    return 1;
}

// VERIFY: 6ea295ed auto
// OFFSET: 0x00402530
static void SetDefaults(OPTION_PAGE page) {
    DefaultSettings* defaults = ConsoleDeviceGetDefaultSettings();

    if (page == OPTION_PAGE_0) {
        if (s_desktopGammaCvar) {
            s_desktopGammaCvar->Set("0", true, false, false, true);
            s_desktopGammaCvar->Update();
        }

        if (s_gammaCvar) {
            s_gammaCvar->Set("1.0", true, false, false, true);
            s_gammaCvar->Update();
        }

        CVar* var = CVar::Lookup("windowResizeLock");

        if (var) {
            var->Set(var->m_defaultValue.m_str, true, false, false, true);
        }
    } else if (page == OPTION_PAGE_1) {
        if (s_cvTextureFilteringMode) {
            s_cvTextureFilteringMode->Set(defaults->m_trilinear ? "1" : "0", true, false, false, true);
        }
    } else if (page == OPTION_PAGE_2) {
        CVar* var = CVar::Lookup("gxStereoEnabled");

        if (var) {
            var->Set(var->m_defaultValue.m_str, true, false, false, true);
        }

        var = CVar::Lookup("gxStereoConvergence");

        if (var) {
            var->Set(var->m_defaultValue.m_str, true, false, false, true);
        }

        var = CVar::Lookup("gxStereoSeparation");

        if (var) {
            var->Set(var->m_defaultValue.m_str, true, false, false, true);
        }
    }
}

void ZoneDebugDestroy() {
}

static void NativeUISaveBundledAddOns();

// VERIFY: a6d33d4d auto
// OFFSET: 0x00402910
static void WowClientDestroy() {
    ValidateNameDestroy();
    DeclinedWordsDestroy();
    SpellVisualsShutdown();
    InputControlDestroy();
    CGlueMgr::Shutdown();
    NativeUISaveBundledAddOns();
    ShutdownAddOns();
    DestroyBannedAddOns();
    DBCache_ClearHandlers();
    DBCache_Destroy();
    ZoneDebugDestroy();
    CEffect::Destroy();
    CCharacterComponent::Destroy();
    FrameXML_FreeHashNodes();
    FrameXML_ClearFactories();
    ComSatClient_Shutdown();
    ObjectEffectSystem_ShutDown();
    SI2::ShutDown(0);
    FrameScript_Destroy();
    g_soundCache.Clear();
    LoadingScreenShutdown();
    WowSysMessageOutput::Shutdown();
    ConsoleCommandUnregister("reloadUI");
    ConsoleCommandUnregister("perf");
    ConsoleCommandUnregister("timingInfo");
    ClientDBShutdown();
    SysMsgShutdown();
}

// VERIFY: ebfeeaaf manual
// OFFSET: 0x004029B0
static bool IsPTRBuild() {
    bool isPTR = false;
    uint32_t size = 0;
    char* data = GetComponentVersionData(&size);

    if (data) {
        XMLTree* tree = XMLTree_Load(data, size);

        if (tree) {
            XMLNode* root = XMLTree_GetRoot(tree)->m_child;

            if (root) {
                XMLNode* product = root->GetChildByName("product");

                if (product && !SStrCmp(product->m_body, "WoWT", STORM_MAX_STR)) {
                    isPTR = true;
                }
            }

            XMLTree_Free(tree);
        }

        delete[] data;
    }

    return isPTR;
}

// VERIFY: 74297692 auto
// OFFSET: 0x00402A40
uint8_t GetClientExpansionLevel() {
    return s_expansionLevel;
}

// VERIFY: 45dcce86 auto
// OFFSET: 0x00402B20
void SetPaths() {
    SFile::DisableSFileCheckDisk();
    SFile::EnableDirectAccess(0);

    const char* path = CmdLineGetString(CMD_DATA_DIR);
    char buffer[260];

    if (!*path) {
        OsGetExePath(buffer, sizeof(buffer));
        path = buffer;
    }

    OsSetCurrentDirectory(path);
    SFile::SetBasePath(path);
    s_unk_B2FA10 = 0;
    SFile::SetDataPath(s_dataDirectories[0]);
}

// VERIFY: fb9a1306 auto
// OFFSET: 0x00402A50
const char* GetInstallLocationString() {
    if (!SFile::IsTrial()) {
        return nullptr;
    }

    if (!s_installLocation[0]) {
        if (IsPTRBuild()) {
            SRegLoadString("World of Warcraft\\PTR", "RetailInstallPath", 1, s_installLocation, sizeof(s_installLocation));
            return s_installLocation;
        }

        SRegLoadString("World of Warcraft", "RetailInstallPath", 1, s_installLocation, sizeof(s_installLocation));
    }

    return s_installLocation;
}

// VERIFY: 1ebb13ac auto
// OFFSET: 0x00402AA0
static bool BuildDataFileName(int32_t directory, char* buffer, uint32_t size, const char* pattern, const char* locale) {
    if (directory == 2) {
        if (!GetInstallLocationString()) {
            return false;
        }

        SStrPrintf(buffer, size, "%s%s%s", GetInstallLocationString(), s_dataDirectories[2], pattern);
    } else {
        SStrPrintf(buffer, size, "%s%s", s_dataDirectories[directory], pattern);
    }

    for (char* token = SStrStr(buffer, "****"); token; token = SStrStr(buffer, "****")) {
        memcpy(token, locale, 4);
    }

    return true;
}

// VERIFY: 4075680a manual
// OFFSET: 0x00402B90
bool CheckDataFilesExist() {
    char installPath[1024] = {};
    char dataPath[1024];
    char parentPath[1024];

    BuildDataFileName(0, dataPath, sizeof(dataPath), s_archives[17].m_name, "----");
    BuildDataFileName(1, parentPath, sizeof(parentPath), s_archives[17].m_name, "----");

    if (BuildDataFileName(2, installPath, sizeof(installPath), s_archives[17].m_name, "----")) {
        return OsFileExists(dataPath) || OsFileExists(parentPath) || OsFileExists(installPath);
    }

    return OsFileExists(dataPath) || OsFileExists(parentPath);
}

// VERIFY: 427545c4 manual
// OFFSET: 0x00402D50
static void CheckAvailableLocales(char* locale) {
    if (!CheckDataFilesExist()) {
        return;
    }

    for (int32_t i = 0; i < NUM_DB_LOCALES; i++) {
        char path[1024];
        g_hasIsoLocale[i] = false;

        for (int32_t directory = 0; directory < 3; directory++) {
            if (BuildDataFileName(directory, path, sizeof(path), s_archives[19].m_name, g_localeNames[i]) && OsFileExists(path)) {
                g_hasIsoLocale[i] = true;
                break;
            }
        }
    }

    int32_t index = LocaleNameToIndex(locale);

    for (int32_t i = 0; i < NUM_DB_LOCALES && !g_hasIsoLocale[index]; i++) {
        index = (index + 1) % NUM_DB_LOCALES;
    }

    SStrCopy(locale, g_localeNames[index], STORM_MAX_STR);
}
// VERIFY: 979d57c4 manual
// OFFSET: 0x00402F60
static void LoadMopaqFileSigningData(const char* locale) {
#ifdef DISABLE_SIGNATURE_CHECKS
    return;
#endif

    SFileClearAllFileFlags();

    char* data;
    uint32_t size;

    if (!SFile::LoadFile("signaturefile", reinterpret_cast<void**>(&data), &size, 0, nullptr)) {
        SErrPrepareAppFatal(__FILE__, __LINE__);
        SErrDisplayAppFatalCustom(2, "file: %s", "signaturefile");
    }

    SFileSetSignatureCallbacks(1);

    if (!SSignatureVerify(reinterpret_cast<const uint8_t*>(data), size, s_signatureModulus, sizeof(s_signatureModulus), s_signatureExponent, sizeof(s_signatureExponent))) {
        SErrPrepareAppFatal(__FILE__, __LINE__);
        SErrDisplayAppFatalCustom(0x4DC, "Could not authenticate the %s file.", "signaturefile");
    }

    char* line = SStrStr(data, "\r\n");
    *line = '\0';
    int32_t version = SStrToInt(data);

    char* signature = line + 2;
    line = SStrStr(signature, "\r\n");
    *line = '\0';
    int32_t signatureVersion = atol(signature);

    if (signatureVersion != 2) {
        SErrPrepareAppFatal(__FILE__, __LINE__);
        SErrDisplayAppFatalCustom(0x85100083, "Signature string (%s) in %s file does not match game's signature version (%d).", signature, "signaturefile", signatureVersion);
    }

    char* scope = line + 2;
    line = SStrStr(scope, "\r\n");
    *line = '\0';

    if (SStrCmp(scope, "RELEASE", 7)) {
        SErrPrepareAppFatal(__FILE__, __LINE__);
        SErrDisplayAppFatalCustom(0x85100083, "Illegal scope string %s in %s: must be \"RELEASE\".", scope, "signaturefile");
    }

    char* record = line + 2;

    if (version != 2) {
        SErrPrepareAppFatal(__FILE__, __LINE__);
        SErrDisplayAppFatalCustom(0x85100083, "Format version in %s file is not supported.", "signaturefile");
        SFile::Unload(data);
        return;
    }

    bool expansion = s_expansionLevel >= 1;
    uint32_t localeTag = *reinterpret_cast<const uint32_t*>(locale);

    while (record < data + size && SStrCmp(record, "NGIS", 4)) {
        char* hash = record + 7;
        char* name = hash + 0x21;
        record[4] = '\0';
        record[6] = '\0';
        hash[0x20] = '\0';

        char* end = SStrStr(name, "\r\n");
        *end = '\0';

        uint32_t tag = *reinterpret_cast<const uint32_t*>(record);

        if ((tag == 'esab' || tag == localeTag) && (record[5] == 'c' || (record[5] == 'e' && expansion))) {
            MD5 md5(hash);
            SFileSetFileBlockEntryMD5(name, md5);
        }

        record = end + 2;
    }

    SFile::Unload(data);
}
// VERIFY: c92cfd5d auto
// OFFSET: 0x00403300
int ForEveryRunOnceWTF::FileNameCompare(const void* a, const void* b) {
    return SStrSortUTF8I(*static_cast<char* const*>(a), *static_cast<char* const*>(b), STORM_MAX_STR);
}

static const bool s_nativeUIEnabled = true;
static bool s_nativeUIBundledAddOnsLoaded = false;

// VERIFY: f04c040b auto
// OFFSET: 0x00403340
static int32_t ClientIdle(const void* data, void* param) {
    ClientGameTimeTickHandler(data, param);
    Player_C_ZoneUpdateHandler(data, param);

    return 1;
}

// VERIFY: bf995614 auto
// OFFSET: 0x004033C0
void ClientPostClose(int32_t reason) {
    s_closeErrorStringId = reason;
    EventPostClose();
}

// VERIFY: a5f6adde manual
// OFFSET: 0x004033E0
static void LogRealmInfo(char* buffer, uint32_t size) {
    REALM_INFO* realm = ClientServices::GetSelectedRealm();

    if (realm && realm->m_realmName[0] && realm->m_realmAddress[0]) {
        SStrPack(buffer, "Realm: ", size);
        SStrPack(buffer, realm->m_realmName, size);
        SStrPack(buffer, " [", size);
        SStrPack(buffer, realm->m_realmAddress, size);
        SStrPack(buffer, "]", size);
    } else {
        SStrPack(buffer, "Realm: ???", size);
    }

    SStrPack(buffer, "\r\n", size);
}

// VERIFY: 91ca195e auto
// OFFSET: 0x00403460
static void LogObjectInfo(CGObject_C* object, const char* label, char* buffer, uint32_t size) {
    if (!SMemIsValidPointer(object, sizeof(CGObject_C), 0)) {
        return;
    }

    C3Vector position = object->GetPosition();
    WOWGUID guid = object->m_obj->m_guid;

    char line[260];
    SStrPrintf(line, sizeof(line), "%s: %s, %016I64X, (%g,%g,%g)\r\n", label, object->GetObjectName(), guid, position.x, position.y, position.z);
    SStrPack(buffer, line, size);
}

// VERIFY: bf3a602d auto
// OFFSET: 0x00403560
static void SetInstallPath() {
    const char* key = "World of Warcraft";

    if (IsPTRBuild()) {
        key = "World of Warcraft\\PTR";
    }

    if (SFile::IsTrial()) {
        key = "World of Warcraft Trial";
    }

    char path[1560];
    GetExecutablePathUTF8(path, sizeof(path));

    if (!path[0]) {
        return;
    }

    char* slash = SStrChrR(path, '\\');

    if (!slash) {
        return;
    }

    slash[1] = '\0';

    if (SFile::IsTrial()) {
        SRegSaveString(key, "InstallPath", 1, path);
    } else {
        SRegSaveString(key, "InstallPath", 4, path);
    }
}

// VERIFY: 835a84bd manual
// OFFSET: 0x00403600
static void LoadMFIL(const char* file) {
    Blizzard::Time::GetElapsedSinceStart(true);

    if (OsFileExists(file) && file) {
        s_streamingDiag |= 1;
        int32_t initialized = SFile::InitializeStreaming(file);
        OsDeleteFile("WoW.stor");

        if (initialized) {
            s_streamingDiag |= 2;
        } else {
            SStrCopy(s_streamingError, SFile::GetErrorDetails(), 2048);
        }
    }

    if (SFile::IsTrial()) {
        InitOggDecompression();
    }

    SFile::SetStreamingStatus(s_streamingDiag & 1, (s_streamingDiag >> 1) & 1, (s_streamingDiag >> 2) & 1, (s_streamingDiag >> 3) & 1, GAME_BUILD);
}

// VERIFY: 4b6c1aaa auto
// OFFSET: 0x004036B0
void StartupReport(bool firstRun) {
    uint32_t speedTest;

    if (!SRegLoadValue("World of Warcraft Trial", "SpeedTest", 1, &speedTest)) {
        speedTest = 0;
    }

    Blizzard::Streaming::FileManifest::SetSpeedTest(speedTest);
    StartupReportSetSpeedTest(speedTest);
    Tracker::SetLocale(CVar::Lookup("locale")->m_stringValue.m_str);
    Tracker::SetBuildnum(GAME_BUILD);
    StartupReportSendTelemetry(true, firstRun);
    World::SetFrameCntCallback(StartupReportFrameCallback);
}

// 335XS NativeUI: last kind-0 snapshot, kept so the bundled FrameXML layer can
// read the real 256-bit numbers through the NativeUnitValue() Lua function (see
// Interface/NativeUI/NativeUI.lua, which hooks the official character sheet).
// Declared up here because LoadNewWorld() resets it before the NativeUI block
// further down is visible to the compiler.
int32_t const kNativeUIMaxStats = 128;

struct NativeUIStat {
    char key[64];
    char value[1024];
};

static NativeUIStat s_nativeUIPlayerStats[kNativeUIMaxStats];
static int32_t s_nativeUIPlayerStatCount = 0;
static uint32_t s_nativeUIRevision = 0;
static uint64_t s_nativeUIPlayerGuid = 0;

bool NativeUIGetPlayerMoney(uint64_t& value) {
    if (s_nativeUIPlayerGuid != ClntObjMgrGetActivePlayer().m_guid) return false;
    for (int32_t i = 0; i < s_nativeUIPlayerStatCount; ++i) {
        auto const& field = s_nativeUIPlayerStats[i];
        if (strcmp(field.key, "MONEY") != 0) continue;
        uint64_t parsed = 0;
        if (!field.value[0]) return false;
        for (char const* digit = field.value; *digit; ++digit) {
            if (*digit < '0' || *digit > '9') return false;
            uint64_t next = static_cast<uint64_t>(*digit - '0');
            if (parsed > (UINT64_MAX - next) / 10) return false;
            parsed = parsed * 10 + next;
        }
        value = parsed;
        return true;
    }
    return false;
}
// kind=4 payload cache: item-growth (IGRO) data pushed without the addon
// message channel. Lua reads it through NativeUIGrowthData().
static char s_nativeUIGrowthData[65536] = { 0 };
static uint32_t s_nativeUIGrowthRevision = 0;
// kind=5 payload cache: UITQ ALL_MODULE_DATA (item tooltip aggregation).
static char s_nativeUITQData[65536] = { 0 };
static uint32_t s_nativeUITQRevision = 0;
struct NativeUICombatLogRecord {
    char amount[80];
    char sourceName[256];
    uint8_t kind;
    uint8_t incoming;
    uint32_t spellId;
};
static std::deque<NativeUICombatLogRecord> s_nativeUICombatLog;

// Unit resources are keyed by GUID; Lua receives decimal strings for every unit token.
static std::map<uint64_t, std::map<std::string, std::string>> s_nativeUIUnitValues;

// 335XS fix: "same map" is not the same as "world already loaded". On login
// ClntObjMgrGetMapID() can already equal the character's map, and the original
// check then skipped LoadNewWorld entirely -> client stayed on the loading bar.
static bool s_worldLoaded = false;

static void SendNativeUIHello();
// VERIFY: 2b64aabf manual
// OFFSET: 0x00403B70
static int32_t LoadNewWorld(const void* data, void* param) {
    s_worldLoaded = false;
    s_nativeUICombatLog.clear();
    ClientServices::Connection()->CharacterSetInGame(0);
    MovementDestroy();
    EventUnregister(EVENT_ID_IDLE, MovementIdleMoveUnits);
    CMissile::RemoveMissiles();
    Spell_C_StopTargeting();
    CGBarberShop::DisableBarberShop();
    s_nativeUIPlayerGuid = 0;
    s_nativeUIPlayerStatCount = 0;
    s_nativeUIUnitValues.clear();
    ClntObjMgrDestroy();
    SpellVisualsClear();
    CEffect::Destroy();
    CGWorldFrame::SetScreenEffect(0);

    if (CGWorldFrame::s_currentWorldFrame) {
        CGWorldFrame::s_currentWorldFrame->UnitClear();
    }

    CGUnit_C::StopMissileTrajectoryTargeting();
    World::UnloadMap();

    if (World::s_weather) {
        World::s_weather->Reset();
    }

    SI2::SetWeatherKitID(-1);
    Spell_C_ClearCooldowns();
    ClntObjMgrInitializeStd(s_zoneID);
    MovementInit();
    CloseAllLootRolls();
    CGPartyInfo::CheckClearLFGSlot();
    AsyncFileReadIngameProgressCallback(nullptr, nullptr);
    AsyncFileReadSetProgressCallback(LoadingScreenAsyncCallback, nullptr);
    World::SetLoadProgressCallback(LoadingScreenWorldCallback, nullptr);
    CWorld::LoadMap(s_directory, &s_spawnPosition, s_zoneID, 1);
    s_worldLoaded = true;
    AsyncFileReadSetProgressCallback(nullptr, nullptr);
    World::SetLoadProgressCallback(nullptr, nullptr);

    CGCamera* camera = CGWorldFrame::GetActiveCamera();
    camera->m_position = s_spawnPosition;
    camera->SetFacing(s_spawnRotation, 0.0f, 0.0f);
    camera->SetTarget(nullptr, 0);

    // The world load callbacks do not always fire when the map is served from
    // cache, which leaves s_progress below 1.0 and the loading screen up.
    // Force the world component to 100%; the screen still closes through its
    // normal path (progress > 0.99 && !IsStillLoading()).
    LoadingScreenWorldCallback(1.0f, nullptr);

    // NativeUI: handshake only after the world is fully loaded, so the server
    // does not start pushing snapshots while the client is still loading.
    s_nativeUIPlayerStatCount = 0;
    s_nativeUIUnitValues.clear();
    s_nativeUIPlayerGuid = 0;
    s_nativeUIGrowthData[0] = 0;
    ++s_nativeUIGrowthRevision;
    s_nativeUITQData[0] = 0;
    ++s_nativeUITQRevision;
    ++s_nativeUIRevision;
    SendNativeUIHello();

    if (param) {
        CDataStore msg;
        msg.Put(static_cast<uint32_t>(MSG_MOVE_WORLDPORT_ACK));
        msg.Finalize();
        ClientServices::Send2(&msg);
    }

    return 1;
}

// VERIFY: a5146d91 auto
// OFFSET: 0x00403D10
static int32_t Packet_SMSG_NEW_WORLD(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    msg->Get(s_zoneID);
    msg->Get(s_spawnPosition.x);
    msg->Get(s_spawnPosition.y);
    msg->Get(s_spawnPosition.z);
    msg->Get(s_spawnRotation);

    if (!msg->IsRead()) {
        ConsoleWrite("Bad SMSG_NEW_WORLD\n", DEFAULT_COLOR);
        msg->Reset();
        return 1;
    }

    MapRec* map = g_mapDB.GetRecord(s_zoneID);

    if (!map) {
        ConsoleWrite("Bad SMSG_NEW_WORLD zoneID\n", DEFAULT_COLOR);
        return 0;
    }

    s_directory = map->m_directory;
    s_worldLoaded = false;
    EventSetTimer(0, LoadNewWorld, reinterpret_cast<void*>(1));

    return 1;
}

// NativeUI uses a single Lua owner for unit-bar rendering.
static void NativeUILog(const char* message) { DebugLog("NativeUI: %s", message); }

// ---------------------------------------------------------------------------
// 335XS NativeUI v2 - custom protocol extension (not part of the original
// binary, therefore no OFFSET tag). Server side:
//   src/server/game/Handlers/ChatHandler.cpp
//   HandleNativeUIHello / UpdateNativeUI / SendNativeUISnapshot
//   CMSG_NATIVE_UI_HELLO (0x521)   : uint16 version = 2
//   SMSG_NATIVE_UI_SNAPSHOT (0x522): uint16 version, uint8 kind, uint64 guid, uint16 count
//        count * { uint8 keyLen, char key[keyLen],
//                  uint8 type (0 = int64, 1 = string, 2 = int256 decimal),
//                  int64 value or (uint16 len + bytes) }
//   kind: 0 = player stats, 1 = target, 2 = pet, 3 = visible unit resources
//         (guid != 0; count == 0 means the unit left visibility)
// ---------------------------------------------------------------------------
static int32_t s_nativeUISnapshotCount = 0;

static void SendNativeUIHello() {
    // Master switch off: skip the handshake entirely, so the server never
    // starts pushing snapshots and keeps using the addon message channel.
    if (!s_nativeUIEnabled) {
        return;
    }

    CDataStore msg;
    msg.Put(static_cast<uint32_t>(CMSG_NATIVE_UI_HELLO));
    msg.Put(NativeUIProtocol::WideVersion);
    msg.Finalize();
    ClientServices::Send2(&msg);
}

static void NativeUIAppendField(char* buffer, size_t capacity, const char* key, const char* value) {
    size_t used = strlen(buffer);

    if (used + 2 >= capacity) {
        return;
    }

    _snprintf_s(buffer + used, capacity - used, _TRUNCATE, " %s=%s", key, value);
}

// --- Lua bridge ------------------------------------------------------------
// Interface/NativeUI/NativeUI.lua is bundled FrameXML: it hooks the official
// character sheet and asks these three globals for the values. Keeping the
// numbers in C++ means the sheet shows the real 256-bit stats instead of the
// 32-bit unit fields, without any addon.
static int32_t Script_NativeUnitValue(lua_State* L) {
    static bool logged = false;

    if (!logged) {
        logged = true;
        NativeUILog("LUA NativeUnitValue called (bundled FrameXML bridge active)");
    }

    char const* unit = lua_tostring(L, 1);
    char const* key = lua_tostring(L, 2);

    if (!key || !*key) {
        return 0;
    }

    if (!unit) {
        unit = "player";
    }

    if (_stricmp(unit, "player") == 0) {
        for (int32_t i = 0; i < s_nativeUIPlayerStatCount; ++i) {
            if (_stricmp(s_nativeUIPlayerStats[i].key, key) == 0) {
                lua_pushstring(L, s_nativeUIPlayerStats[i].value);
                return 1;
            }
        }

        return 0;
    }

    WOWGUID selectedGuid = WOWGUID();
    if (!Script_GetGUIDFromToken(unit, selectedGuid, false)) {
        return 0;
    }
    auto found = s_nativeUIUnitValues.find(selectedGuid.m_guid);
    if (found != s_nativeUIUnitValues.end()) {
        auto field = found->second.find(key);
        if (field != found->second.end()) {
            lua_pushstring(L, field->second.c_str());
            return 1;
        }
    }

    return 0;
}

#if defined(_WIN64)
static int32_t Script_NativeMoneyString(lua_State* L) {
    uint64_t money = 0;
    if (!NativeUIGetPlayerMoney(money)) return 0;
    char text[32];
    _snprintf_s(text, sizeof(text), _TRUNCATE, "%llu", static_cast<unsigned long long>(money));
    lua_pushstring(L, text);
    return 1;
}
#endif

static int32_t Script_NativeUIRevision(lua_State* L) {
    lua_pushnumber(L, static_cast<lua_Number>(s_nativeUIRevision));
    return 1;
}

static int32_t Script_NativeUIGrowthData(lua_State* L) {
    lua_pushstring(L, s_nativeUIGrowthData);
    lua_pushnumber(L, static_cast<lua_Number>(s_nativeUIGrowthRevision));
    return 2;
}

static int32_t Script_NativeUITQData(lua_State* L) {
    lua_pushstring(L, s_nativeUITQData);
    lua_pushnumber(L, static_cast<lua_Number>(s_nativeUITQRevision));
    return 2;
}

static int32_t Script_NativeUIHello(lua_State* L) {
    SendNativeUIHello();
    return 0;
}

static int32_t Script_NativeUITooltipQuery(lua_State* L) {
    if (!s_nativeUIEnabled || !lua_isnumber(L, 1) || !lua_isnumber(L, 2))
        return 0;

    uint32_t itemId = static_cast<uint32_t>(lua_tointeger(L, 1));
    uint32_t guidLow = static_cast<uint32_t>(lua_tointeger(L, 2));
    if (!itemId)
        return 0;

    CDataStore msg;
    msg.Put(static_cast<uint32_t>(CMSG_NATIVE_UI_TOOLTIP_QUERY));
    msg.Put(static_cast<uint16_t>(1));
    msg.Put(itemId);
    msg.Put(guidLow);
    msg.Finalize();
    ClientServices::Send2(&msg);
    return 0;
}

static int32_t Script_NativeUICombatLogData(lua_State* L) {
    if (s_nativeUICombatLog.empty())
        return 0;

    NativeUICombatLogRecord record = s_nativeUICombatLog.front();
    s_nativeUICombatLog.pop_front();
    lua_pushstring(L, record.amount);
    lua_pushnumber(L, record.kind);
    lua_pushnumber(L, record.incoming);
    lua_pushstring(L, record.sourceName);
    lua_pushnumber(L, record.spellId);
    return 5;
}

static bool s_nativeUIScriptsRegistered = false;
static bool s_nativeUIBundledLuaLoaded = false;

static void NativeUIRegisterScriptFunctions() {
    if (s_nativeUIScriptsRegistered) {
        return;
    }

    s_nativeUIScriptsRegistered = true;
    FrameScript_RegisterFunction("NativeUnitValue", Script_NativeUnitValue);
#if defined(_WIN64)
    FrameScript_RegisterFunction("NativeMoneyString", Script_NativeMoneyString);
#endif
    FrameScript_RegisterFunction("NativeUIRevision", Script_NativeUIRevision);
    FrameScript_RegisterFunction("NativeUIGrowthData", Script_NativeUIGrowthData);
    FrameScript_RegisterFunction("NativeUITQData", Script_NativeUITQData);
    FrameScript_RegisterFunction("NativeUIHello", Script_NativeUIHello);
    FrameScript_RegisterFunction("NativeUITooltipQuery", Script_NativeUITooltipQuery);
    FrameScript_RegisterFunction("NativeUICombatLogData", Script_NativeUICombatLogData);
}

struct NativeUIBundledAddon {
    const char* name;
    const char* const* files;
    uint32_t fileCount;
    const char* const* savedVariables;
    uint32_t savedVariableCount;
};

static const char* const s_nativeUIBundledFunctionFiles[] = {
    "DreamTemplate.xml", "___DreamConfig.lua", "__DreamFunction.lua", "CustomTargetHealth.lua", "BanListAddon.lua",
    "CustomInfo.lua", "DmgRank.lua", "DressItemTransmog.lua", "EqUpgrade.lua", "EventSignIn.lua",
    "ItemCards.lua", "BeastCards.lua", "ItemGlobalTooltip.lua", "ItemShop.lua", "ItemUpChoice.lua",
    "ItemUpRandom.lua", "ItemVsInfo.lua", "NewLuck.lua", "OnGameEventShow.lua", "GuildBattleUI.lua",
    "AsPlayerBattleUI.lua", "Other.lua", "PlayerDeadRevive.lua", "PlayerNtRank.lua", "TipButton.lua",
    "PlayerActivity.lua", "SecretPlaceMod.lua", "PlayerItemMagic.lua", "ItemEnchantment.lua", "SoulItemMod.lua",
    "NewItemEnchantment.lua", "SpellItemEnchantmentData.lua", "ItemSubNameData.lua", "ItemBuyInfo.lua", "ItemVendorInfo.lua",
    "ItemSellGuidInfo.lua", "PlayerItemZodiac.lua", "CombatPet.lua", "MapProgressUI.lua", "TaskEnchSpellMod.lua",
    "PicGuide.lua", "locallzation.lua",
};

static const char* const s_nativeUIBundledFrozenFiles[] = { "FrozenCore.lua" };
static const char* const s_nativeUIBundledItemForgeFiles[] = { "ItemForgeUI.lua" };
static const char* const s_nativeUIBundledDamageFiles[] = { "DamageDisplayUI.lua", "NativeCombatText.lua" };

static const char* const s_nativeUIBundledFunctionVariables[] = {
    "Zs_GuidLowStoreData", "Zs_EntryIdStoreData", "BossHealthBarSavedVars", "ItemForgeUIDB", "MapProgressUIDB",
};
static const char* const s_nativeUIBundledFrozenVariables[] = { "FrozenData" };
static const char* const s_nativeUIBundledItemForgeVariables[] = { "ItemForgeUIDB" };
static const char* const s_nativeUIBundledDamageVariables[] = { "DamageDisplayUIDB", "LargeDamageTextDB" };

static const NativeUIBundledAddon s_nativeUIBundledAddons[] = {
    { "____Function", s_nativeUIBundledFunctionFiles, sizeof(s_nativeUIBundledFunctionFiles) / sizeof(s_nativeUIBundledFunctionFiles[0]), s_nativeUIBundledFunctionVariables, sizeof(s_nativeUIBundledFunctionVariables) / sizeof(s_nativeUIBundledFunctionVariables[0]) },
    { "FrozenCore", s_nativeUIBundledFrozenFiles, sizeof(s_nativeUIBundledFrozenFiles) / sizeof(s_nativeUIBundledFrozenFiles[0]), s_nativeUIBundledFrozenVariables, sizeof(s_nativeUIBundledFrozenVariables) / sizeof(s_nativeUIBundledFrozenVariables[0]) },
    { "ItemForgeUI", s_nativeUIBundledItemForgeFiles, sizeof(s_nativeUIBundledItemForgeFiles) / sizeof(s_nativeUIBundledItemForgeFiles[0]), s_nativeUIBundledItemForgeVariables, sizeof(s_nativeUIBundledItemForgeVariables) / sizeof(s_nativeUIBundledItemForgeVariables[0]) },
    { "DamageDisplayUI", s_nativeUIBundledDamageFiles, sizeof(s_nativeUIBundledDamageFiles) / sizeof(s_nativeUIBundledDamageFiles[0]), s_nativeUIBundledDamageVariables, sizeof(s_nativeUIBundledDamageVariables) / sizeof(s_nativeUIBundledDamageVariables[0]) },
};

static void NativeUIBundledSavedVariablesPath(const NativeUIBundledAddon& addon, char* path, uint32_t pathSize) {
    SStrPrintf(path, pathSize, "WTF\\Account\\%s\\SavedVariables\\%s.lua", ClientServices::GetAccountName(), addon.name);
}

static void NativeUILoadBundledSavedVariables(const NativeUIBundledAddon& addon, CStatus* status) {
    char path[260];
    NativeUIBundledSavedVariablesPath(addon, path, sizeof(path));
    if (SFile::FileExistsEx(path, 1)) {
        FrameScript_LoadVariables(path, status);
    }
}

static void NativeUISaveBundledSavedVariables(const NativeUIBundledAddon& addon) {
    char directory[260];
    SStrPrintf(directory, sizeof(directory), "WTF\\Account\\%s\\SavedVariables", ClientServices::GetAccountName());
    if (!OsDirectoryExists(directory)) {
        OsCreateDirectory(directory, 1);
    }

    char path[260];
    NativeUIBundledSavedVariablesPath(addon, path, sizeof(path));
    if (OsFileExists(path)) {
        char backup[260];
        SStrCopy(backup, path, sizeof(backup));
        SStrPack(backup, ".bak", sizeof(backup));
        OsMoveFile(path, backup);
    }

    HOSFILE file = OsCreateFile(path, OS_GENERIC_WRITE, 0, OS_CREATE_ALWAYS, OS_FILE_ATTRIBUTE_NORMAL, OS_FILE_TYPE_ANY);
    if (file == OS_INVALID_FILE) {
        return;
    }

    for (uint32_t i = 0; i < addon.savedVariableCount; ++i) {
        FrameScript_PrintVariable(file, addon.savedVariables[i]);
    }

    uint32_t written;
    OsWriteFile(file, "\r\n", 2, &written);
    OsCloseFile(file);
}

static void NativeUIEnsureBundledAddOns() {
    if (s_nativeUIBundledAddOnsLoaded) {
        return;
    }

    s_nativeUIBundledAddOnsLoaded = true;
    CStatus status;

    for (const NativeUIBundledAddon& addon : s_nativeUIBundledAddons) {
        MD5_CTX md5;
        MD5Init(&md5);

        for (uint32_t i = 0; i < addon.fileCount; ++i) {
            char path[260];
            SStrPrintf(path, sizeof(path), "Interface\\NativeUI\\BundledAddOns\\%s\\%s", addon.name, addon.files[i]);
            const char* extension = SStrChrR(const_cast<char*>(path), '.');
            if (extension && !SStrCmpI(extension, ".xml", STORM_MAX_STR)) {
                FrameXML_ProcessFile(path, addon.name, &md5, &status);
            } else {
                FrameScript_ExecuteFile(path, addon.name, &md5, &status);
            }
        }

        uint8_t digest[16];
        MD5Final(digest, &md5);
        NativeUILoadBundledSavedVariables(addon, &status);
        FrameScript_SignalEvent(SCRIPT_EVENT_ADDON_LOADED, "%s", addon.name);
    }

    if (status.m_highestSeverity > STATUS_INFO) {
        NativeUILog("Bundled add-on load reported script errors");
    }
}

static void NativeUISaveBundledAddOns() {
    if (!s_nativeUIBundledAddOnsLoaded) {
        return;
    }

    for (const NativeUIBundledAddon& addon : s_nativeUIBundledAddons) {
        NativeUISaveBundledSavedVariables(addon);
    }
}

void NativeUIShutdownFrameXML() {
    NativeUISaveBundledAddOns();
    s_nativeUIBundledAddOnsLoaded = false;
    s_nativeUIBundledLuaLoaded = false;
    s_nativeUIScriptsRegistered = false;
}

// The bundled FrameXML file lives next to the client (Interface\NativeUI) and
// hooks the official character sheet. Load it during game FrameXML creation:
// some FrameXML revisions never load that folder on their own. The file starts
// with a re-entry guard, so a second load is a no-op.
static void NativeUIEnsureBundledLua() {
    if (s_nativeUIBundledLuaLoaded) {
        return;
    }

    s_nativeUIBundledLuaLoaded = true;

    if (!FrameScript_ExecuteFile("Interface\\NativeUI\\NativeUI.lua", nullptr, nullptr, nullptr)) {
        NativeUILog("LUA bundled NativeUI.lua not found or failed to load");
    }
}

// Called exactly once from CGGameUI::InitializeFrameXML, before PLAYER_LOGIN.
// Loading is never triggered by a bar pointer change or a per-frame retry.
void NativeUIInitializeFrameXML() {
    s_nativeUIScriptsRegistered = false;
    s_nativeUIBundledLuaLoaded = false;
    s_nativeUIBundledAddOnsLoaded = false;
    NativeUIRegisterScriptFunctions();
    NativeUIEnsureBundledLua();
    NativeUIEnsureBundledAddOns();

}

static int32_t Packet_SMSG_NATIVE_UI_SNAPSHOT(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint16_t version = 0, count = 0;
    uint8_t kind = 0;
    uint64_t guid = 0;
    if (!NativeUIRead(msg, version) || !NativeUIRead(msg, kind) || !NativeUIRead(msg, guid) ||
        !NativeUIRead(msg, count) || (version != NativeUIProtocol::LegacyVersion && version != NativeUIProtocol::WideVersion) || kind > NativeUIProtocol::LastSnapshotKind || count > NativeUIProtocol::MaxFields) return 1;

    std::vector<NativeUIStat> fields;
    fields.reserve(count);
    std::string extendedPayload;
    bool hasExtendedPayload = false;
    for (uint16_t i = 0; i < count; ++i) {
        NativeUIStat field = {};
        uint8_t keyLength = 0, type = 0;
        if (!NativeUIRead(msg, keyLength) || !keyLength || keyLength > NativeUIProtocol::MaxKeyBytes ||
            !NativeUIReadText(msg, keyLength, field.key, sizeof(field.key)) ||
            !NativeUIRead(msg, type)) return 1;
        if (type == 0) {
            uint64_t number = 0;
            if (!NativeUIRead(msg, number)) return 1;
            _snprintf_s(field.value, sizeof(field.value), _TRUNCATE, "%lld", static_cast<long long>(number));
        } else if (type == 1 || (version == NativeUIProtocol::WideVersion && type == 2)) {
            uint16_t length = 0;
            if (!NativeUIRead(msg, length)) return 1;
            if (type == 1 && ((kind == 4 && strcmp(field.key, "IGRO_DATA") == 0) ||
                (kind == 5 && strcmp(field.key, "UITQ_DATA") == 0))) {
                std::vector<char> data(static_cast<size_t>(length) + 1);
                if (!NativeUIReadText(msg, length, data.data(), data.size())) return 1;
                extendedPayload.assign(data.data(), length);
                hasExtendedPayload = true;
            } else {
                if (length > NativeUIProtocol::MaxValueBytes) return 1;
                if (!NativeUIReadText(msg, length, field.value, sizeof(field.value))) return 1;
                if (type == 2 && (length > NativeUIProtocol::MaxIntegerBytes || !NativeUIIsInt256(field.value))) return 1;
            }
        } else {
            return 1;
        }
        fields.push_back(field);
    }
    if (msg->m_read != msg->m_size) return 1;

    uint64_t previousMoney = 0;
    bool hadMoney = NativeUIGetPlayerMoney(previousMoney);
    if (kind == 0) {
        if (guid != ClntObjMgrGetActivePlayer().m_guid) return 1;
        s_nativeUIPlayerStatCount = 0;
        s_nativeUIPlayerGuid = guid;
    }
    if (kind <= 3 && guid) {
        if (count == 0) {
            s_nativeUIUnitValues.erase(guid);
        } else {
            auto& resources = s_nativeUIUnitValues[guid];
            resources.clear();
            for (auto const& field : fields) resources[field.key] = field.value;
        }
    }
    if (kind == 0) {
        for (auto const& field : fields) s_nativeUIPlayerStats[s_nativeUIPlayerStatCount++] = field;
    }
    if (hasExtendedPayload) {
        if (kind == 4) {
            _snprintf_s(s_nativeUIGrowthData, sizeof(s_nativeUIGrowthData), _TRUNCATE, "%s", extendedPayload.c_str());
            ++s_nativeUIGrowthRevision;
        } else if (kind == 5) {
            _snprintf_s(s_nativeUITQData, sizeof(s_nativeUITQData), _TRUNCATE, "%s", extendedPayload.c_str());
            ++s_nativeUITQRevision;
        }
    }
    if (kind == 0) {
        ++s_nativeUIRevision;
#if defined(_WIN64)
        uint64_t currentMoney = 0;
        if (NativeUIGetPlayerMoney(currentMoney) && (!hadMoney || currentMoney != previousMoney)) {
            FrameScript_SignalEvent(SCRIPT_EVENT_PLAYER_MONEY, nullptr);
        }
#endif
    }
    if (s_nativeUISnapshotCount++ == 0) {
        NativeUILog("protocol connected");
    }
    return 1;
}

static int32_t Packet_SMSG_NATIVE_UI_TOOLTIP_DATA(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint16_t version = 0;
    uint32_t itemId = 0;
    uint32_t guidLow = 0;
    uint16_t length = 0;
    if (!NativeUIRead(msg, version) || version != 1 || !NativeUIRead(msg, itemId) || !itemId ||
        !NativeUIRead(msg, guidLow) || !NativeUIRead(msg, length) ||
        length >= sizeof(s_nativeUITQData) || !NativeUIReadText(msg, length, s_nativeUITQData, sizeof(s_nativeUITQData)) ||
        msg->m_read != msg->m_size)
        return 1;

    ++s_nativeUITQRevision;
    (void)param;
    (void)msgId;
    (void)time;
    return 1;
}

// ---------------------------------------------------------------------------
// 335XS NativeUI v2: exact 256-bit floating combat text.
// The stock combat text goes through COMBAT_TEXT_UPDATE with an int32 amount,
// so any value above 2^31 is already gone by the time Lua sees it. This opcode
// carries exact decimal text and the client renders it with the engine's own world
// text (same fade/ascend animation the game uses for floating labels).
//   uint16 version = 2
//   uint8  kind    (0 = damage, 1 = crit, 2 = heal)
//   uint64 guid    (unit that took the hit / heal)
//   uint16 decimalLength; char amount[decimalLength] (v1 retains int64)
//   uint8  schoolMask
// ---------------------------------------------------------------------------
static int32_t Packet_SMSG_NATIVE_UI_COMBAT_TEXT(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint16_t version = 0;
    uint8_t kind = 0;
    uint64_t rawGuid = 0;
    uint8_t schoolMask = 0;
    uint32_t spellId = 0;
    uint8_t incoming = 0;
    char sourceName[256] = {};
    if (!NativeUIRead(msg, version) || !NativeUIRead(msg, kind) || !NativeUIRead(msg, rawGuid)) return 1;
    char amount[80] = {};
    if (version == 1) {
        uint64_t rawAmount = 0;
        if (!NativeUIRead(msg, rawAmount)) return 1;
        _snprintf_s(amount, sizeof(amount), _TRUNCATE, "%lld", static_cast<long long>(rawAmount));
    } else if (version == 2 || version == 3) {
        uint16_t length = 0;
        if (!NativeUIRead(msg, length) || length >= sizeof(amount) ||
            !NativeUIReadText(msg, length, amount, sizeof(amount)) || !NativeUIIsInt256(amount)) return 1;
    } else return 1;
    if (!NativeUIRead(msg, schoolMask) || rawGuid == 0 || kind > 2 || NativeUIInteger(amount) <= 0) return 1;
    if (version == 3) {
        uint8_t nameLength = 0;
        if (!NativeUIRead(msg, spellId) || !NativeUIRead(msg, incoming) || incoming > 1 ||
            !NativeUIRead(msg, nameLength) || !NativeUIReadText(msg, nameLength, sourceName, sizeof(sourceName))) return 1;
    }
    if (msg->m_read != msg->m_size) return 1;

    if (version == 3 && strlen(amount) >= 10 &&
        (strlen(amount) > 10 || strcmp(amount, "2147483647") > 0) && s_nativeUICombatLog.size() < 256) {
        NativeUICombatLogRecord record = {};
        SStrCopy(record.amount, amount, sizeof(record.amount));
        SStrCopy(record.sourceName, sourceName, sizeof(record.sourceName));
        record.kind = kind;
        record.incoming = incoming;
        record.spellId = spellId;
        s_nativeUICombatLog.push_back(record);
    }

    // Keep the native floating text switch independent from the combat-log queue.
    CVar* nativeCombatText = CVar::Lookup("nativeCombatText");

    if (nativeCombatText && !nativeCombatText->m_intValue) {
        return 1;
    }

    bool needsNativeFloat = strlen(amount) > 10 || (strlen(amount) == 10 && strcmp(amount, "2147483647") > 0);
    if (!needsNativeFloat)
        return 1;

    WOWGUID guid;
    guid.m_guid = rawGuid;

    CGObject_C* object = ClntObjMgrObjectPtr(guid, TYPE_UNIT, __FILE__, __LINE__);

    if (!object) {
        return 1;
    }

    C3Vector position = object->GetPosition();
    position.z += 2.2f;

    char text[96];
    NativeUIFormatAmount(amount, text, sizeof(text));

    uint32_t type = 0;
    CImVector color(0xFF, 0xFF, 0xFF, 0xFF);   // damage: white

    if (kind == 1) {
        type = 3;
        color = CImVector(0x00, 0xE0, 0xFF, 0xFF);   // crit: yellow
    } else if (kind == 2) {
        type = 6;
        color = CImVector(0x00, 0xFF, 0x00, 0xFF);   // heal: green
    }

    WorldTextCreate(type, position, text, &color, nullptr);

    (void)param;
    (void)msgId;
    (void)time;
    (void)schoolMask;
    return 1;
}


// VERIFY: 1eb347a4 auto
// OFFSET: 0x00403DE0
static int32_t Packet_SMSG_LOGIN_VERIFY_WORLD(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint32_t zoneID;
    C3Vector position = { 0.0f, 0.0f, 0.0f };
    float rotation;

    msg->Get(zoneID);
    msg->Get(position.x);
    msg->Get(position.y);
    msg->Get(position.z);
    msg->Get(rotation);

    if (s_worldLoaded && zoneID == ClntObjMgrGetMapID()) {
        return 1;
    }

    s_spawnRotation = rotation;
    s_spawnPosition = position;
    s_zoneID = zoneID;

    MapRec* map = g_mapDB.GetRecord(zoneID);

    if (!map) {
        ConsoleWrite("Bad SMSG_NEW_WORLD zoneID\n", DEFAULT_COLOR);
        return 0;
    }

    s_directory = map->m_directory;
    LoadNewWorld(nullptr, nullptr);

    return 1;
}

// VERIFY: 2ecb4537 auto
// OFFSET: 0x00404130
static void InitializeClient() {
    EventRegister(EVENT_ID_UPDATE, EnableCallback);
    SysMsgInitialize();
    WowSysMessageOutput::Initialize();
    ClientRegisterConsoleCommands();
    ClientDBInitialize();
    LoadingScreenInitialize();
    FrameScript_Initialize(0);
    SI2::Init(0);
    ObjectEffectSystem_Initialize();
    FrameXML_RegisterDefault();
    GlueScriptEventsInitialize();
    ScriptEventsInitialize();
    SpecialUnitEffectsInitialize();
    CCharacterComponent::Initialize();
    ClientServices::Initialize();
    ClientServices::SetMessageHandler(SMSG_TUTORIAL_FLAGS, CGTutorial::OnTutorialFlags, nullptr);

    CVar* voiceChat = CVar::Lookup("EnableVoiceChat");

    if (voiceChat && voiceChat->m_intValue) {
        ComSatClient_Init();
    }

    DBCache_RegisterHandlers();
    DBCache_Initialize();
    CWorldParam::Initialize();
    CWorld::Initialize();
    ShadowInit();
    GxuLightInitialize();
    GxuLightSetGridSize(16.665001f);
    InputControlInitialize();
    CGlueMgr::Initialize();

    if (GetConsoleMessage()) {
        CGlueMgr::AddChangedOptionWarning(GetConsoleMessage());
        SetConsoleMessage(nullptr);
    }

    if (SFile::IsTrial()) {
        StartDataPreloadThread();
    }

    if (s_expansionLevel == 1) {
        if (s_cvExpansionMovie->m_intValue == 1) {
            s_cvExpansionMovie->Set("0", true, false, false, true);
            s_cvMovie->Set("0", true, false, false, true);
            CGlueMgr::SetScreen("movie");
        } else {
            CGlueMgr::SetScreen("login");
        }
    } else if (s_cvMovie->m_intValue == 1) {
        s_cvMovie->Set("0", true, false, false, true);
        CGlueMgr::SetScreen("movie");
    } else {
        CGlueMgr::SetScreen("login");
    }

    CGlueMgr::m_pendingTimerAlert = s_timeTestError;
    SpellVisualsInitialize();
    EventRegister(EVENT_ID_POLL, PollNet);
}

// VERIFY: 56a0f6b5 auto
// OFFSET: 0x004047E0
int32_t InitializeEngineCallback(const void* data, void* param) {
    BaseInitializeContext();
    HeapUsageInitialize();
    AsyncFileReadRegisterCVars();
    TextureInitialize();
    ModelBlobLoad("world\\model.blob");

    if (SFile::IsStreamingMode()) {
        TextureLoadBlob("world\\liquid.tex");
    }

    ScrnInitialize(0);
    ConsoleScreenInitialize(nullptr);

    s_cvTextureFilteringMode = CVar::Register("textureFilteringMode", "Texture filtering mode", 1, "1", CWorldParam::TextureFilteringCallback, CATEGORY_GRAPHICS, false, nullptr, false);
    s_cvarUIFaster = CVar::Register("UIFaster", "UI acceleration option", 0, "3", UIFasterCallback, CATEGORY_GRAPHICS, false, nullptr, false);
    s_cvTextureCacheSize = CVar::Register("textureCacheSize", "Texture cache size in bytes", 1, "32", TextureCacheSizeCallback, CATEGORY_GRAPHICS, false, nullptr, false);
    TextureSetCacheSize(s_cvTextureCacheSize->m_intValue << 20);

    uint32_t m2Flags = GetM2CvarFlags();
    AddConsoleDeviceDefaultCallback(SetDefaults);

    if (ConsoleDeviceHardwareChanged()) {
        for (uint32_t page = OPTION_PAGE_0; page < NUM_OPTION_PAGES; page++) {
            SetDefaults(static_cast<OPTION_PAGE>(page));
        }
    }

    M2Initialize(m2Flags, 0);

    int32_t mode = s_cvTextureFilteringMode->m_intValue;
    TextureSetFilterMode(s_textureFilterModes[mode]);
    TextureSetMaxAnisotropy(s_textureMaxAnisotropy[mode]);

    InitializeClient();

    return 1;
}

// VERIFY: 12e55922 auto
// OFFSET: 0x00404930
static bool OpenArchiveWithRetry(const char* name, int32_t priority, uint32_t slot, const char* locale) {
    for (int32_t directory = 0; directory < 3; directory++) {
        char path[260];

        if (!BuildDataFileName(directory, path, sizeof(path), name, locale)) {
            continue;
        }

        if (SFile::OpenArchive(path, priority, 0xC00, &s_archiveHandles[slot])) {
            return true;
        }

        s_archiveHandles[slot] = nullptr;

        switch (SErrGetLastError()) {
            case 5:
            case 38:
            case 108:
            case 131:
            case 0x8510006C:
            case 0x85100083:
                return false;
        }
    }

    return false;
}

// VERIFY: 47b56ac0 manual
// OFFSET: 0x00404AD0
static void CloseAllArchives() {
    for (uint32_t i = s_archiveHandles.Count(); i; i--) {
        if (s_archiveHandles[i - 1]) {
            SFile::CloseArchive(s_archiveHandles[i - 1]);
        }
    }
}

// VERIFY: f3490184 auto
// OFFSET: 0x00404B00
static void LogZoneInfo(CGObject_C* object, char* buffer, uint32_t size) {
    C3Vector position = object->GetPosition();
    SStrPack(buffer, "Local Zone: ", size);

    uint32_t areaId = 0;
    CMap::QueryAreaId(object->m_worldObject, areaId);

    char name[260];
    AreaListGetName(areaId, name, sizeof(name), 1);
    SStrPack(buffer, name, size);
    SStrPack(buffer, "\r\n", size);
}

// VERIFY: 4c651ee9 manual
// OFFSET: 0x00404B80
int32_t STORMAPI WowLogHeader(char* buffer, uint32_t bufferchars) {
    SStrPrintf(buffer, bufferchars, "WoWBuild: %d\r\n", GAME_BUILD);

    if (ClntObjMgrIsValid(0)) {
        CGObject_C* player = ClntObjMgrObjectPtr(ClntObjMgrGetActivePlayer(), TYPE_PLAYER, __FILE__, __LINE__);

        if (player && SMemIsValidPointer(player, sizeof(CGPlayer_C), 0)) {
            LogRealmInfo(buffer, bufferchars);
            LogZoneInfo(player, buffer, bufferchars);
            LogObjectInfo(player, "Local Player", buffer, bufferchars);

            CGObject_C* object = ClntObjMgrObjectPtr(static_cast<CGPlayer_C*>(player)->m_combat.m_attacking, TYPE_OBJECT, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Attacking Target", buffer, bufferchars);
            }

            object = ClntObjMgrObjectPtr(CGGameUI::m_currentObjectTrack, TYPE_OBJECT, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Current Object Track", buffer, bufferchars);
            }

            object = ClntObjMgrObjectPtr(CGGameUI::m_interactTarget, TYPE_OBJECT, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Interact Target", buffer, bufferchars);
            }

            object = ClntObjMgrObjectPtr(CGGameUI::m_lockedTarget, TYPE_OBJECT, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Locked Target", buffer, bufferchars);
            }

            object = ClntObjMgrObjectPtr(CGGameUI::m_lastEnemyTarget, TYPE_OBJECT, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Last Enemy Target", buffer, bufferchars);
            }

            object = ClntObjMgrObjectPtr(CGGameUI::GetCursorItem(), TYPE_ITEM, __FILE__, __LINE__);

            if (object) {
                LogObjectInfo(object, "Cursor Item", buffer, bufferchars);
            }

            char line[1024];
            line[0] = '\0';

            SStrPrintf(line, sizeof(line), "Total lua memory: %dKB\n", FrameScript_GetTotalMemoryUsed());
            SStrPack(buffer, line, bufferchars);

            SStrPrintf(line, sizeof(line), "Current Addon: %s\n", lua_tainted);
            SStrPack(buffer, line, bufferchars);

            char function[1024];
            FrameScript_GetCurrentFunction(FrameScript_GetContext(), function, sizeof(function));
            SStrPrintf(line, sizeof(line), "Current Addon function: %s\n", function);
            SStrPack(buffer, line, bufferchars);

            SStrPrintf(line, sizeof(line), "Current Addon object: %s\n", FrameScript_GetCurrentObject(FrameScript_GetContext(), 2));
            SStrPack(buffer, line, bufferchars);

            if (GetNumAddOns()) {
                SStrPack(buffer, "Add Ons: ", bufferchars);

                for (uint32_t i = 0; i < GetNumAddOns(); i++) {
                    const char* name = GetAddOnByIndex(i);

                    if (IsAddOnLoading(name)) {
                        SStrPack(buffer, name, bufferchars);
                        SStrPack(buffer, " ", bufferchars);
                    }
                }

                SStrPack(buffer, "\r\n", bufferchars);
            }
        }
    }

    SStrPack(buffer, "Settings: \r\n", bufferchars);
    CVar::LogAll(buffer, bufferchars, 0, 64);
    GxLogCrashInfo(buffer, bufferchars);

    return 1;
}

// VERIFY: 4abe30a5 manual
// OFFSET: 0x00405540
void ClientInitializeGame(uint32_t mapId, C3Vector position) {
    if (SFile::IsTrial()) {
        SetClientInitialized(0);
    }

    g_theGxDevicePtr->MasterEnableSet(GxMasterEnable_Fog, 1);

    if (World::s_weather) {
        World::s_weather->Reset();
    }

    SI2::SetWeatherKitID(-1);

    REALM_INFO* realm = ClientServices::GetSelectedRealm();

    for (uint32_t i = 0; i < g_cfg_ConfigsDB.m_numRecords; i++) {
        Cfg_ConfigsRec* config = i < g_cfg_ConfigsDB.m_numRecords ? &g_cfg_ConfigsDB.m_records[i] : nullptr;

        if (config->m_realmType == realm->m_type) {
            s_isPvPRealm = config->m_playerKillingAllowed != 0;
            break;
        }
    }

    AccountDataInitialize(false);
    ClntObjMgrInitializeShared();
    ClntObjMgrInitializeStd(mapId);
    CGUnit_C::ClientInitialize();
    SI2::InitZoneSoundsHandler();
    SI2::InitZoneIntros();
    LootInitialize();
    CGGameUI::InitializeGame();
    CGWorldFrame::GetActiveCamera()->m_position = position;
    WorldTextInitialize();
    PlayerNameInitialize();
    WeaponTrailsInitialize();
    CGObject_C::Initialize();
    SpellTableInitialize();
    CGUnit_C::Initialize();
    CGGameObject_C::Initialize();
    PlayerClientInitialize();
    CGPlayer_C::Initialize();
    CGItem_C::Initialize();
    CGContainer_C::Initialize();
    CGCorpse_C::Initialize();
    CGDynamicObject_C::Initialize();
    FriendList::Initialize();
    SmartScreenRectClearAllGrids();
    Trade_C_Initialize();
    MovementInit();
    EventRegister(EVENT_ID_IDLE, ClientIdle);
    ClientInitializeGameTime();

    CommandManager* manager = StaticSingleton<CommandManager>::Instance();
    manager->m_connection = ClientServices::Connection();
    GameClientCommands* commands = new (__FILE__, __LINE__) GameClientCommands;
    manager = StaticSingleton<CommandManager>::Instance();
    manager->m_commands[manager->m_count++] = commands;
    commands->Install();

    ClientServices::SetMessageHandler(SMSG_NOTIFICATION, Packet_SMSG_NOTIFICATION, nullptr);
    ClientServices::SetMessageHandler(SMSG_PLAYED_TIME, Packet_SMSG_PLAYED_TIME, nullptr);
    ClientServices::SetMessageHandler(SMSG_NEW_WORLD, Packet_SMSG_NEW_WORLD, nullptr);
    ClientServices::SetMessageHandler(SMSG_TRANSFER_PENDING, Packet_SMSG_TRANSFER_PENDING, nullptr);
    ClientServices::SetMessageHandler(SMSG_TRANSFER_ABORTED, Packet_SMSG_TRANSFER_ABORTED, nullptr);
    ClientServices::SetMessageHandler(SMSG_LOGIN_VERIFY_WORLD, Packet_SMSG_LOGIN_VERIFY_WORLD, nullptr);
    ClientServices::SetMessageHandler(SMSG_NATIVE_UI_SNAPSHOT, Packet_SMSG_NATIVE_UI_SNAPSHOT, nullptr);
    ClientServices::SetMessageHandler(SMSG_NATIVE_UI_TOOLTIP_DATA, Packet_SMSG_NATIVE_UI_TOOLTIP_DATA, nullptr);
    NativeUIRegisterScriptFunctions();
    ClientServices::SetMessageHandler(SMSG_NATIVE_UI_COMBAT_TEXT, Packet_SMSG_NATIVE_UI_COMBAT_TEXT, nullptr);
    ClientServices::SetMessageHandler(SMSG_KICK_REASON, CGlueMgr::OnKickReasonMsg, nullptr);

    MapRec* map = g_mapDB.GetRecord(mapId);

    if (!map) {
        DebugLog("Bad zone ID %i", mapId);
    }

    AsyncFileReadIngameProgressCallback(nullptr, nullptr);
    AsyncFileReadSetProgressCallback(LoadingScreenAsyncCallback, nullptr);
    World::SetLoadProgressCallback(LoadingScreenWorldCallback, nullptr);

    if (SFile::IsTrial()) {
        SetClientInitialized(1);
    }

    CWorld::LoadMap(map->m_directory, &position, mapId, 1);
    AsyncFileReadSetProgressCallback(nullptr, nullptr);
    World::SetLoadProgressCallback(nullptr, nullptr);

    s_botCheckStartTime = OsGetAsyncTimeMs();
    s_botCheckDelay = 1200;
    s_botCheckEnabled = 1;
    BattlenetUI_EnterRealm();
    s_gameInitialized = 1;
}

// VERIFY: a768ccd6 manual
// OFFSET: 0x00405DD0
static void OpenArchives() {
    int32_t availability = CheckDataFilesExist() + 1;

    for (uint32_t i = 0; i < sizeof(s_archives) / sizeof(s_archives[0]); i++) {
        s_archives[i].m_opened = false;
    }

    const char* locale = (availability & 2) ? CVar::Lookup("locale")->m_stringValue.m_str : "----";

    PatchFiles patches(locale, false);

    int32_t priority = 64;
    uint32_t slot = 0;
    s_archiveHandles.SetCount(64);

    for (uint32_t i = patches.m_files.Count(); i; i--) {
        if (SFile::OpenArchive(patches.m_files[i - 1], priority, 0xC00, &s_archiveHandles[slot])) {
            if (SStrStrI(patches.m_files[i - 1], "Start.MPQ")) {
                s_startArchivePriority = priority;
            }

            slot++;
            priority++;
        }
    }

    uint32_t patchCount = slot;

    for (uint32_t i = 0; i < sizeof(s_archives) / sizeof(s_archives[0]); i++) {
        if (s_archives[i].m_unk04 == 3 && OpenArchiveWithRetry(s_archives[i].m_name, priority, slot, locale)) {
            slot++;
            s_archives[i].m_opened = true;
            priority++;
        }
    }

    for (uint32_t patch = 0; patch < patchCount; patch++) {
        SArchive* patchArchive = s_archiveHandles[patch];

        for (uint32_t i = 0; i < sizeof(s_archives) / sizeof(s_archives[0]); i++) {
            if (s_archives[i].m_unk04 != 3) {
                continue;
            }

            if (!s_archives[i].m_opened && SStrCmpI(locale, "zhCN", STORM_MAX_STR) && SStrCmpI(locale, "enCN", STORM_MAX_STR) && SStrCmpI(locale, "zhTW", STORM_MAX_STR) && SStrCmpI(locale, "enTW", STORM_MAX_STR)) {
                continue;
            }

            char path[256];
            SStrCopy(path, s_archives[i].m_name, sizeof(path));
            path[SStrLen(path) - 4] = '\0';

            if (SFile::OpenPathAsArchive(patchArchive, path, priority, 0, &s_archiveHandles[slot])) {
                slot++;
                priority++;
            }
        }
    }

    s_numPatchArchives = slot;
    int32_t basePriority = 63;
    s_firstBaseArchive = slot;

    for (uint32_t i = 0; i < sizeof(s_archives) / sizeof(s_archives[0]); i++) {
        s_archiveHandles[slot] = nullptr;

        if (s_archives[i].m_unk04 == 3 || s_archives[i].m_unk04 == 4) {
            slot++;
            continue;
        }

        bool optional = s_archives[i].m_unk04 == 2;
        bool available = (availability & s_archives[i].m_unk08) != 0;
        bool allowed = !SFile::IsTrial() || s_archives[i].m_unk04 != 2;

        if (allowed && available) {
            if (!OpenArchiveWithRetry(s_archives[i].m_name, basePriority, slot, locale) && !optional) {
                char path[260];
                SStrPrintf(path, sizeof(path), "%s%s", s_dataDirectories[0], s_archives[i].m_name);

                for (char* token = SStrStr(path, "****"); token; token = SStrStr(path, "****")) {
                    memcpy(token, locale, 4);
                }

                const char* details = SFile::GetErrorDetails();
                char errorText[256];
                SErrGetErrorStr(SErrGetLastError(), errorText, sizeof(errorText));

                if (s_streamingDiag & 1) {
                    SErrDisplayAppFatal("Failed to read data from the network. Please check your Internet connection and try again.\n\nDebug Details:\n\n%s%sStorm Error Msg:%s", details, s_streamingError, errorText);
                }

                char message[256];
                SStrPrintf(message, sizeof(message), "Failed to open archive %s.", s_archives[i].m_name);

                char title[256];
                SStrCopy(title, "Missing or corrupted data", STORM_MAX_STR);
                OsGuiMessageBox(OsGuiGetWindow(OSGUI_WINDOW_TYPE_FRONT), OSGUI_MESSAGE_STYLE_OK, message, title);
                StormExit(SErrGetLastError());
            }
        }

        slot++;
        basePriority--;
        s_archives[i].m_opened = true;
    }

    if (SFile::IsTrial()) {
        basePriority = 64;
    }

    if (SFile::IsStreamingMode()) {
        for (uint32_t i = 0; i < sizeof(s_archives) / sizeof(s_archives[0]); i++) {
            if (s_archives[i].m_unk04 == 4 && OpenArchiveWithRetry(s_archives[i].m_name, basePriority, slot, locale)) {
                s_archives[i].m_opened = true;
                slot++;
            }
        }
    }

    s_archiveHandles.SetCount(slot);

    if (s_archiveHandles[s_firstBaseArchive + 16]) {
        s_expansionLevel = 2;
    } else {
        s_expansionLevel = s_archiveHandles[s_firstBaseArchive + 15] != nullptr;
    }

    void* profile = ProfileCreate();

    if (ProfileReadFile(profile, "Wow.ini")) {
        ProfileGetValue(profile, "WoW Config", "Region", &s_region, 0);

        char language[16];
        char country[16];

        if (ProfileGetValue(profile, "WoW Config", "Language", language, sizeof(language), 0) && ProfileGetValue(profile, "WoW Config", "Country", country, sizeof(country), 0)) {
            SStrPrintf(s_iniLocale, sizeof(s_iniLocale), "%s%s", language, country);

            uint32_t code = 0;

            for (uint32_t i = 0; i < 4 && s_iniLocale[i]; i++) {
                code = (code << 8) + s_iniLocale[i];
            }

            SFile::s_locale = code;
            bool isGB = SStrCmpI("enGB", s_iniLocale, STORM_MAX_STR) == 0;

            for (int32_t i = 0; i < 9; i++) {
                if (!SStrCmpI(s_iniLocale, s_iniLocaleNames[i], STORM_MAX_STR) || (isGB && !SStrCmpI("enUS", s_iniLocaleNames[i], STORM_MAX_STR))) {
                    s_locale = i;

                    switch (i) {
                        case 1:
                        case 2:
                        case 4:
                        case 5:
                            FrameScript_SetPluralRule(PLURAL_RULE_1);
                            break;

                        case 8:
                            FrameScript_SetPluralRule(PLURAL_RULE_2);
                            break;

                        default:
                            FrameScript_SetPluralRule(PLURAL_RULE_0);
                            break;
                    }

                    if (availability & 1) {
                        CVar::Lookup("locale")->Set(s_iniLocale, true, false, false, true);
                        locale = s_iniLocale;
                    }

                    break;
                }
            }
        }
    }

    ProfileClose(profile);
    ClientServices::InitLoginServerCVars(1, locale);
    LoadMopaqFileSigningData(locale);
}
// VERIFY: 18427c91 manual
// OFFSET: 0x004064A0
int32_t ForEveryRunOnceWTF::AppendFileName(OS_FILE_DATA& data, void* param) {
    TSGrowableArray<char*>* files = static_cast<TSGrowableArray<char*>*>(param);
    char** slot = files->New();
    *slot = SStrDupA(data.fileName, __FILE__, __LINE__);

    return 0;
}

// VERIFY: fedc85e6 manual
// OFFSET: 0x00406510
void ClientDestroyGame(int32_t charSelect, int32_t resumeGlue, int32_t worldLogin) {
    if (!s_gameInitialized) {
        return;
    }

    s_botCheckEnabled = 0;
    s_nativeUICombatLog.clear();
    EventUnregister(EVENT_ID_IDLE, ClientIdle);
    ClientServices::ClearMessageHandler(SMSG_NOTIFICATION);
    ClientServices::ClearMessageHandler(SMSG_PLAYED_TIME);
    ClientServices::ClearMessageHandler(SMSG_NEW_WORLD);
    ClientServices::ClearMessageHandler(SMSG_TRANSFER_PENDING);
    ClientServices::ClearMessageHandler(SMSG_TRANSFER_ABORTED);
    ClientServices::ClearMessageHandler(SMSG_CHANNEL_NOTIFY);
    ClientServices::ClearMessageHandler(SMSG_CHANNEL_LIST);
    ClientServices::ClearMessageHandler(SMSG_LOGIN_VERIFY_WORLD);
    ClientServices::ClearMessageHandler(SMSG_NATIVE_UI_SNAPSHOT);
    ClientServices::ClearMessageHandler(SMSG_NATIVE_UI_TOOLTIP_DATA);
    ClientServices::ClearMessageHandler(SMSG_NATIVE_UI_COMBAT_TEXT);
    ClientServices::ClearMessageHandler(SMSG_KICK_REASON);

    if (StaticSingleton<CommandManager>::m_instance) {
        delete StaticSingleton<CommandManager>::m_instance;
        StaticSingleton<CommandManager>::m_instance = nullptr;
    }

    Trade_C_Destroy();
    FriendList::Destroy();
    AreaListShutdown();
    CGItem_C::Shutdown();
    CGPlayer_C::Shutdown();
    PlayerClientShutdown();
    LootDestroy();
    SpellTableDestroy();
    CGUnit_C::Shutdown();
    CGGameObject_C::Shutdown();
    CGObject_C::Shutdown();
    MovementDestroy();
    LootRollShutdown();
    EventUnregister(EVENT_ID_IDLE, MovementIdleMoveUnits);
    Spell_C_StopTargeting();
    s_worldLoaded = false;
    s_nativeUIPlayerGuid = 0;
    s_nativeUIPlayerStatCount = 0;
    s_nativeUIUnitValues.clear();
    s_nativeUIGrowthData[0] = 0;
    s_nativeUITQData[0] = 0;
    ++s_nativeUIGrowthRevision;
    ++s_nativeUITQRevision;
    ++s_nativeUIRevision;
    ClntObjMgrDestroy();
    CGUnit_C::PostShutdown();
    SpellVisualsClear();
    CEffect::Destroy();
    CGWorldFrame::SetScreenEffect(0);

    if (CGWorldFrame::s_currentWorldFrame) {
        CGWorldFrame::s_currentWorldFrame->UnitClear();
    }

    World::UnloadMap();
    WeaponTrailsShutdown();
    PlayerNameShutdown();
    WorldTextShutdown();
    CGGameUI::ShutdownGame();
    ClientDestroyGameTime();
    SI2::ShutdownZoneSoundsHandler();
    SI2::StopAllSounds();
    SI2::FreeZoneIntros();
    SI2::ClearSuppressorSounds();
    ClntObjMgrDestroyShared();
    AccountDataDestroy(false);
    s_gameInitialized = 0;
    LoadingScreenDisable();

    if (s_clientTaxiBenchEnabled) {
        s_clientTaxiBenchEnabled = 0;
        s_clientTaxiBenchIsOnTaxi = 0;
    }

    BattlenetUI_LeaveRealm();

    if (resumeGlue) {
        CGlueMgr::Resume();

        if (worldLogin) {
            CGlueMgr::m_idleState = IDLE_WORLD_LOGIN;
        }

        CGlueMgr::SetScreen(charSelect ? "charselect" : "login");
    }
}

// VERIFY: e61971e0 auto
// OFFSET: 0x004066D0
int32_t DestroyEngineCallback(const void* data, void* param) {
    RemoveConsoleDeviceDefaultCallback(SetDefaults);
    ClientDestroyGame(0, 0, 0);
    WowClientDestroy();
    ClientServices::ClearMessageHandler(SMSG_TUTORIAL_FLAGS);
    ClientServices::Destroy();
    ShadowDestroy();
    CWorld::Destroy();
    ConsoleScreenDestroy();
    ScrnDestroy();
    M2Destroy();
    ModelBlobDestroy();
    TextureDestroy();
    AsyncFileReadDestroy();
    GxuLightShutdown();
    HeapUsageDestroy();
    ObjectAllocDestroy();
    BaseDestroyContext();

    return 1;
}

// VERIFY: 84c3b1d6 manual
// OFFSET: 0x00406740
void ForEveryRunOnceWTF::Execute(int32_t (*callback)(const char*)) {
    char basePath[260];
    SFile::GetBasePath(basePath, sizeof(basePath));

    char dir[260];
    SStrPrintf(dir, sizeof(dir), "%sWTF\\", basePath);
    OsFileList(dir, "RunOnce*.wtf", ForEveryRunOnceWTF::AppendFileName, &this->m_files, 1);

    uint32_t count = this->m_files.Count();
    qsort(this->m_files.Ptr(), count, sizeof(char*), ForEveryRunOnceWTF::FileNameCompare);

    for (int32_t i = 0; i < static_cast<int32_t>(count); i++) {
        callback(this->m_files[i]);
        SMemFree(this->m_files[i], __FILE__, __LINE__, 0);
    }
}

// VERIFY: f4d6d325 manual
// OFFSET: 0x004067F0
bool InitializeGlobal() {
    SCmdRegisterArgList(s_wowArgList, sizeof(s_wowArgList) / sizeof(s_wowArgList[0]));
    CmdLineProcess();
    LoadMFIL("WoW.mfil");

    if (s_unk_B2FA10 != 2) {
        SetInstallPath();
    }

    bool firstRun = false;

    if (SFile::IsTrial()) {
        firstRun = !OsDirectoryExists("WTF/Account");
    }

    ClientServices::LoadCDKey();
    ConsoleInitializeClientCommand();
    CVar::Initialize("Config.wtf");
    CVar::ArchiveCodeRegisteredOnly();

    {
        ForEveryRunOnceWTF runOnce;
        runOnce.Execute(static_cast<int32_t (*)(const char*)>(CVar::Load));
    }

    CVar::Register("dbCompress", "Database compression", 0, "-1", nullptr, CATEGORY_DEFAULT, false, nullptr, false);
    CVar* locale = CVar::Register("locale", "Set the game locale", 0, "****", LocaleCallback, CATEGORY_DEFAULT, false, nullptr, false);

    if (!SStrCmp(locale->m_stringValue.m_str, "****", STORM_MAX_STR)) {
        locale->Set("enUS", true, false, false, true);
    }

    CVar::Register("useEnglishAudio", "override the locale and use English audio", 0, "0", nullptr, CATEGORY_DEFAULT, false, nullptr, false);

    if (SFile::IsTrial()) {
        StartupReport(firstRun);
    }

    char localeName[5];
    SStrCopy(localeName, locale->m_stringValue.m_str, sizeof(localeName));
    CheckAvailableLocales(localeName);
    locale->Set(localeName, true, false, false, true);

    char dataPath[260];
    SStrPrintf(dataPath, sizeof(dataPath), "%s%s", s_dataDirectories[0], locale->m_stringValue.m_str);
    SFile::SetDataPathAlternate(dataPath);
    SFile::RebuildHash();
    OpenArchives();

    CVar* affinity = CVar::Register("processAffinityMask", "Sets which core(s) WoW may execute on - changes require restart to take effect", 2, "0", ProcessAffinityMaskCallback, CATEGORY_DEBUG, false, nullptr, false);
    CVar* videoOptionsVersion = CVar::Lookup("videoOptionsVersion");

    if (!videoOptionsVersion || videoOptionsVersion->m_intValue < 3) {
        char value[8];
        SStrPrintf(value, sizeof(value), "%u", 0);
        affinity->Set(value, true, false, false, true);
        affinity->Update();
    }

    uint32_t mask = affinity->m_intValue;

    if (mask) {
        SSetCurrentProcessAffinityMask(mask);
    }

    BaseInitializeGlobal();
    EventInitialize(1, 0);

    CVar* timingTestError = CVar::Register("timingTestError", "Error reported by the timing validation system", 6, "0", nullptr, CATEGORY_DEFAULT, false, nullptr, false);
    CVar* timingMethod = CVar::Register("timingMethod", "Desired method for game timing", 2, "0", TimingMethodCallback, CATEGORY_DEFAULT, false, timingTestError, false);
    OsTimeStartup(static_cast<OsTimeManager::TimingMethod>(timingMethod->m_intValue));
    ConsoleCommandRegister("timingInfo", CCommand_TimingInfo, CATEGORY_DEBUG, nullptr);

    s_timeTestError = OsTimeGetTestError();

    if (s_timeTestError != static_cast<uint32_t>(timingTestError->m_intValue)) {
        char buffer[16];
        sprintf(buffer, "%d", s_timeTestError);
        timingTestError->SetReadOnly(false);
        timingTestError->Set(buffer, true, false, false, true);
        timingTestError->Update();
        timingTestError->SetReadOnly(true);
        ConsolePrintf("Timing test error: %d", timingTestError);
    }

    g_startup_StringsDB.Load(__FILE__, __LINE__);

    ConsoleDeviceInitialize(CLIENT_NAME, 1, 1);

    OsIMEInitialize();
    g_rndSeed.SetSeed(OsGetAsyncTimeMs());
    g_clientEventContext = EventCreateContextEx(1, InitializeEngineCallback, DestroyEngineCallback, 0, 0);

    return true;
}

// VERIFY: 87ba0ad5 manual
// OFFSET: 0x00406B70
void BeginCloseGame() {
    SMemSetDebugFlags(0, 8);
    OsIMEDestroy();
    OsTimeShutdown();
    EventDestroy();
    ConsoleDeviceDestroy();

    {
        ForEveryRunOnceWTF runOnce;
        runOnce.Execute(CVar::Delete);
    }

    CVar::Destroy();
    ConsoleCommandDestroy();
    BaseDestroyGlobal();
    CloseAllArchives();
    ShutdownStreamingIfTrial();
    StopStreaming();

    if (s_closeErrorStringId) {
        Startup_StringsRec* title = g_startup_StringsDB.GetRecord(1);
        Startup_StringsRec* message = g_startup_StringsDB.GetRecord(s_closeErrorStringId);
        OsGuiMessageBox(nullptr, OSGUI_MESSAGE_STYLE_OK, message ? message->m_message : "Unknown Error", title ? title->m_message : "World of Warcraft");
    }
}

// VERIFY: cfa3efeb auto
// OFFSET: 0x00406C70
int32_t CommonMain() {
    StormInitialize();
    SErrCatchUnhandledExceptions();
    CreateNamedEventA("Blizzard Entertainment World of Warcraft", 0);

    int32_t option = 1;
    StormSetOption(10, &option, sizeof(option));
    option = 1;
    StormSetOption(11, &option, sizeof(option));

    OsSystemEnableCpuLog();
    SetPaths();

    uint32_t sendErrorLogs = 1;

    if (!SRegLoadValue("World of Warcraft\\Client", "SendErrorLogs", 0, &sendErrorLogs)) {
        sendErrorLogs = 1;
        SRegSaveValue("World of Warcraft\\Client", "SendErrorLogs", 0, 1);
    }

    SErrSetLogTitleString("World of WarCraft (build " GAME_BUILD_STRING ")");
    SErrSetLogCallback(WowLogHeader);

    if (sendErrorLogs) {
        SErrRegisterHandler(SendErrorLog);
    }

    if (InitializeGlobal()) {
        EventDoMessageLoop();
        BeginCloseGame();
    }

    StormDestroy();

    if (SFile::IsTrial()) {
        ShutdownOggDecompression();
    }

    Blizzard::Time::GetElapsedSinceStart(false);

    if (SFile::IsTrial()) {
        StartupReportSendTelemetry(false, false);
    }

    return 0;
}

// VERIFY: 8f0a8d05 manual
// OFFSET: 0x00404A80
void ListInterfaceArchive(const char* prefix, int32_t (*callback)(const char* fileName, void* param), void* param) {
    if (s_archiveHandles.m_data[s_firstBaseArchive + 1]) {
        ListArchives(prefix, 1, callback, param);
    } else {
        ListArchives(prefix, 19, callback, param);
    }
}

// VERIFY: df6c53d5 auto
// OFFSET: 0x00406EF0
void GameClientCommands::Uninstall() {
    ConsoleCommandUnregister("port");
    ConsoleCommandUnregister("charmport");
    ConsoleCommandUnregister("worldport");
    ConsoleCommandUnregister("setrawpos");
    ConsoleCommandUnregister("showplayer");
    ConsoleCommandUnregister("togglehelm");
    ConsoleCommandUnregister("togglecloak");
}

// VERIFY: 0fe7767a auto
// OFFSET: 0x00407870
void GameClientCommands::Install() {
    ConsoleCommandRegister("port", CCommand_Teleport, CATEGORY_DEBUG, nullptr);
    ConsoleCommandRegister("charmport", CCommand_CharmTeleport, CATEGORY_DEBUG, nullptr);
    ConsoleCommandRegister("worldport", CCommand_WorldTeleport, CATEGORY_DEBUG, nullptr);
    ConsoleCommandRegister("setrawpos", CCommand_SetRawPos, CATEGORY_DEBUG, nullptr);
    ConsoleCommandRegister("showplayer", CCommand_TogglePlayer, CATEGORY_GRAPHICS, nullptr);
    ConsoleCommandRegister("togglehelm", CCommand_ToggleHelm, CATEGORY_GAME, nullptr);
    ConsoleCommandRegister("togglecloak", CCommand_ToggleCloak, CATEGORY_GAME, nullptr);
}

// VERIFY: 94d63d11 auto
// OFFSET: 0x00401480
int32_t Packet_SMSG_TRANSFER_PENDING(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint32_t transportEntry = 0;
    uint32_t mapID = 0;
    msg->Get(mapID);
    int32_t transportMap = -1;

    if (!msg->IsRead()) {
        uint32_t value = 0;
        msg->Get(value);
        transportEntry = value;
        value = 0;
        msg->Get(value);
        transportMap = value;
    }

    CGGameUI::ClearClientControls();
    ConsolePrintf("World transfer pending...");

    if (!transportEntry || transportMap == -1) {
        LoadingScreenEnable(mapID, true);
        return 1;
    }

    LoadingScreenEnableShip(transportEntry, transportMap, mapID);
    return 1;
}

// VERIFY: 78f957a4 auto
// OFFSET: 0x00403910
int32_t Packet_SMSG_TRANSFER_ABORTED(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    uint32_t mapID;
    uint8_t reason;
    msg->Get(mapID);
    msg->Get(reason);
    MapRec* map = g_mapDB.GetRecord(mapID);

    if (map) {
        const char* text = nullptr;
        char token[64];

        switch (reason) {
            case 1:
                text = FrameScript_GetText("TRANSFER_ABORT_ERROR", -1, GENDER_NOT_APPLICABLE);
                break;
            case 2:
                text = FrameScript_GetText("TRANSFER_ABORT_MAX_PLAYERS", -1, GENDER_NOT_APPLICABLE);
                break;
            case 3:
            case 12:
            case 13:
            case 14:
                text = FrameScript_GetText("TRANSFER_ABORT_NOT_FOUND", -1, GENDER_NOT_APPLICABLE);
                break;
            case 4:
                text = FrameScript_GetText("TRANSFER_ABORT_TOO_MANY_INSTANCES", -1, GENDER_NOT_APPLICABLE);
                break;
            case 6:
                text = FrameScript_GetText("TRANSFER_ABORT_ZONE_IN_COMBAT", -1, GENDER_NOT_APPLICABLE);
                break;
            case 7: {
                uint8_t expansion;
                msg->Get(expansion);
                SStrPrintf(token, sizeof(token), "TRANSFER_ABORT_INSUF_EXPAN_LVL%d", expansion);
                text = FrameScript_GetText(token, -1, GENDER_NOT_APPLICABLE);
                break;
            }
            case 8: {
                uint8_t difficulty;
                msg->Get(difficulty);
                MapDifficultyRec* entry = GetMapDifficultyEntryByMapIdAndDifficulty(map->m_id, difficulty, nullptr);

                if (!entry || !(text = entry->m_message) || !*text) {
                    char difficultyToken[64];
                    SStrPrintf(difficultyToken, sizeof(difficultyToken), "TRANSFER_ABORT_DIFFICULTY%d", difficulty + 1);
                    text = FrameScript_GetText(difficultyToken, -1, GENDER_NOT_APPLICABLE);
                }

                break;
            }
            case 9: {
                uint8_t message;
                msg->Get(message);
                char messageToken[64];
                SStrPrintf(messageToken, sizeof(messageToken), "TRANSFER_ABORT_UNIQUE_MESSAGE%d", message);
                text = FrameScript_GetText(messageToken, -1, GENDER_NOT_APPLICABLE);
                break;
            }
            case 10:
                text = FrameScript_GetText("TRANSFER_ABORT_TOO_MANY_REALM_INSTANCES", -1, GENDER_NOT_APPLICABLE);
                break;
            case 11:
                text = FrameScript_GetText("TRANSFER_ABORT_NEED_GROUP", -1, GENDER_NOT_APPLICABLE);
                break;
            case 15:
                text = FrameScript_GetText("TRANSFER_ABORT_REALM_ONLY", -1, GENDER_NOT_APPLICABLE);
                break;
            case 16:
                text = FrameScript_GetText("TRANSFER_ABORT_MAP_NOT_ALLOWED", -1, GENDER_NOT_APPLICABLE);
                break;
        }

        if (text && *text) {
            char buffer[1024];
            SStrPrintf(buffer, sizeof(buffer), text, map->m_mapName);
            CGChat::AddChatMessage(buffer, 0, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID{ 0 }, 0, WOWGUID{ 0 }, 0, false, nullptr);
        }
    }

    ConsolePrintf("World transfer aborted...");
    LoadingScreenDisable();
    return 1;
}

// VERIFY: d7d71bd8 auto
// OFFSET: 0x004034F0
int32_t STORMAPI SendErrorLog(uint32_t errorcode, const char* description, const char* filename, int32_t linenumber, const char* errorstring) {
    char path[260];

    if (SErrGetLogLastPath(path, sizeof(path))) {
        char commandLine[520];
        SStrPrintf(commandLine, sizeof(commandLine), "%s %s", "WowError.exe", path);
        SCreateProcess("WowError.exe", commandLine, nullptr, nullptr);
    }

    return 1;
}

// VERIFY: b4bcd439 manual
// OFFSET: 0x00404EE0
static void ClientBeginTaxiBenchmarkMode() {
    CGPlayer_C* player = static_cast<CGPlayer_C*>(ClntObjMgrObjectPtr(ClntObjMgrGetActivePlayer(), TYPE_PLAYER, __FILE__, __LINE__));

    if (!player || !(player->m_player->m_playerFlags & 0x20000)) {
        return;
    }

    s_clientTaxiBenchEnabled = 1;
    s_clientTaxiBenchMinFPS = 99999.0;
    s_clientTaxiBenchIsOnTaxi = 1;
    s_clientTaxiBenchTotalFrames = 0;
    s_clientTaxiBenchMaxFPS = 0.0;
    s_clientTaxiBenchTotalTime = 0.0;
    s_clientTaxiBenchDelayTime = OsGetAsyncTimeMs() + 5000;
}

// VERIFY: a664a31a manual
// OFFSET: 0x00404F60
static void ClientEndTaxiBenchmarkMode(int32_t silent) {
    if (!s_clientTaxiBenchEnabled) {
        return;
    }

    s_clientTaxiBenchEnabled = 0;
    s_clientTaxiBenchIsOnTaxi = 0;

    if (silent || !s_clientTaxiBenchTotalFrames) {
        return;
    }

    CGPlayer_C* player = static_cast<CGPlayer_C*>(ClntObjMgrObjectPtr(ClntObjMgrGetActivePlayer(), TYPE_PLAYER, __FILE__, __LINE__));

    if (!player || player->IsDeadOrGhost()) {
        return;
    }

    char text[3000];
    CGChat::AddChatMessage(FrameScript_GetText("BENCHMARK_TAXI_RESULTS", -1, GENDER_NOT_APPLICABLE), CHAT_MSG_SYSTEM, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID(), 0, WOWGUID(), 0, false, nullptr);
    SStrPrintf(text, sizeof(text), FrameScript_GetText("BENCHMARK_TAXI_MIN_FPS", -1, GENDER_NOT_APPLICABLE), s_clientTaxiBenchMinFPS);
    CGChat::AddChatMessage(text, CHAT_MSG_SYSTEM, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID(), 0, WOWGUID(), 0, false, nullptr);
    SStrPrintf(text, sizeof(text), FrameScript_GetText("BENCHMARK_TAXI_MAX_FPS", -1, GENDER_NOT_APPLICABLE), s_clientTaxiBenchMaxFPS);
    CGChat::AddChatMessage(text, CHAT_MSG_SYSTEM, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID(), 0, WOWGUID(), 0, false, nullptr);
    SStrPrintf(text, sizeof(text), FrameScript_GetText("BENCHMARK_TAXI_AVERAGE_FPS", -1, GENDER_NOT_APPLICABLE), s_clientTaxiBenchTotalFrames / s_clientTaxiBenchTotalTime);
    CGChat::AddChatMessage(text, CHAT_MSG_SYSTEM, nullptr, 0, nullptr, nullptr, nullptr, WOWGUID(), 0, WOWGUID(), 0, false, nullptr);
}

// VERIFY: 79999d66 manual
// OFFSET: 0x00405130
void ClientUpdateTaxiBenchmarkMode() {
    CGPlayer_C* player = static_cast<CGPlayer_C*>(ClntObjMgrObjectPtr(ClntObjMgrGetActivePlayer(), TYPE_PLAYER, __FILE__, __LINE__));

    if (!player) {
        return;
    }

    if (s_clientTaxiBenchIsOnTaxi) {
        if (!(player->m_unit->m_unitFieldFlags & 0x100000) || !(player->m_player->m_playerFlags & 0x20000)) {
            ClientEndTaxiBenchmarkMode(0);
        }
    } else if ((player->m_unit->m_unitFieldFlags & 0x100000) && (player->m_player->m_playerFlags & 0x20000)) {
        ClientBeginTaxiBenchmarkMode();
    }

    if (!s_clientTaxiBenchEnabled) {
        return;
    }

    uint64_t now = OsGetAsyncTimeClocks();
    double elapsed = static_cast<double>(static_cast<int64_t>(now - s_clientTaxiTimestamp)) / static_cast<double>(OsGetAsyncClocksPerSecond());

    if (elapsed <= 0.0) {
        return;
    }

    s_clientTaxiTimestamp = now;

    if (static_cast<int32_t>(OsGetAsyncTimeMs() - s_clientTaxiBenchDelayTime) < 0) {
        return;
    }

    s_clientTaxiBenchTotalFrames++;
    double fps = 1.0 / elapsed;
    s_clientTaxiBenchTotalTime += elapsed;

    if (fps <= s_clientTaxiBenchMinFPS) {
        s_clientTaxiBenchMinFPS = fps;
    }

    if (fps >= s_clientTaxiBenchMaxFPS) {
        s_clientTaxiBenchMaxFPS = fps;
    }
}

// VERIFY: ada684ee auto
// OFFSET: 0x00403FC0
void CheckAndSendBotDetected() {
    if (!s_botCheckEnabled) {
        return;
    }

    ClientConnection* connection = ClientServices::Connection();

    if (!s_gameInitialized || !connection) {
        return;
    }

    uint32_t now = OsGetAsyncTimeMs();

    if (now - s_botCheckStartTime < 1000) {
        return;
    }

    s_botCheckStartTime = now;

    if (--s_botCheckDelay > 0) {
        return;
    }

    s_botCheckEnabled = 0;

    uint8_t check1;
    uint8_t check2;
    uint8_t check3;

    if (!GatherAdditionalChecks(&check1, &check2, &check3)) {
        return;
    }

    SHA1 sha;
    sha.Prepare();
    sha.Process(connection->GetSessionKey(), sizeof(LoginData::m_sessionKey));
    sha.Process(&check1, sizeof(check1));
    sha.Process(&check2, sizeof(check2));
    sha.Process(&check3, sizeof(check3));
    sha.Process(connection->GetSessionKey(), sizeof(LoginData::m_sessionKey));
    SHA1::Digest digest;
    sha.Finish(digest);

    WDataStore msg;
    msg.Put(static_cast<uint32_t>(CMSG_BOT_DETECTED));
    msg.Put(check1);
    msg.Put(check2);
    msg.Put(check3);
    msg.PutArray(digest.m_data, sizeof(digest.m_data));
    msg.Finalize();
    ClientServices::Send2(&msg);
}

// VERIFY: b337a4a2 manual
// OFFSET: 0x00401390
int32_t Packet_SMSG_PLAYED_TIME(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg) {
    int32_t total;
    int32_t level;
    uint8_t show = 0;
    msg->Get(reinterpret_cast<uint32_t&>(total));
    msg->Get(reinterpret_cast<uint32_t&>(level));
    msg->Get(show);

    WOWGUID guid = ClntObjMgrGetActivePlayer();

    if (guid) {
        CGPlayer_C* player = static_cast<CGPlayer_C*>(ClntObjMgrObjectPtr(guid, TYPE_PLAYER, __FILE__, __LINE__));

        if (player) {
            player->SetPlayedTime(total);
        }
    }

    if (show) {
        char text[256];
        ConsolePrintf("Time played:");
        FormatTime(text, sizeof(text), total);
        ConsolePrintf("Total: %s", text);
        FormatTime(text, sizeof(text), level);
        ConsolePrintf("Level: %s", text);
        FrameScript_SignalEvent(SCRIPT_EVENT_TIME_PLAYED_MSG, "%d%d", total, level);
    }

    return 1;
}

// VERIFY: 89d97e9f auto
// OFFSET: 0x004033B0
void ClientKillTimer(uint32_t id, EVENTHANDLERFUNC handler, const char* name) {
    EventKillTimer(id, handler, name);
}

// VERIFY: ba8cfe2c manual
// OFFSET: 0x00402720
void* Client_MemAlloc(uint32_t bytes) {
    return SMemAlloc(bytes, __FILE__, __LINE__, 0);
}

// VERIFY: 8c344a50 manual
// OFFSET: 0x00402740
void Client_MemFree(void* ptr) {
    SMemFree(ptr, __FILE__, __LINE__, 0);
}

// VERIFY: af0e97c3 manual
// OFFSET: 0x00404610
void SendBotDetected2(uint32_t msgId, uint32_t code) {
    WDataStore msg;
    msg.Put(msgId);
    msg.Put(code);
    msg.Finalize();
    ClientServices::Send2(&msg);
}

// VERIFY: 3ceca495 auto
// OFFSET: 0x00403370
uint32_t ClientSetTimer(uint32_t delay, EVENTHANDLERFUNC handler, void* param) {
    return EventSetTimer(delay, handler, param);
}

// VERIFY: 25a365e6 auto
// OFFSET: 0x00403380
uint32_t ClientSetTimer(uint32_t delay, EVENTHANDLERGUIDFUNC handler, uint64_t guid, void* param) {
    return EventSetTimer(delay, handler, guid, param);
}
