-- Persistent cache for the custom equipment data received by ItemGlobalTooltip.
-- One equipment GUID can have multiple cache IDs as its state changes.

FrozenData = FrozenData or {};

local FrozenCore = {};
local CaptureElapsed = 0;
local PendingGuids = {};
local PendingAt = {};
local PendingItemIds = {};
local PendingTooltipSnapshots = {};
local LastVersionCacheId = {};
local InvalidatedGuids = {};
local CacheSerial = 0;
local ValidateQueue = {};
local ValidateQueued = {};
local ValidateElapsed = 0;
local QueueCacheValidation;
local LoginPreloadQueue = {};
local LoginPreloadQueued = {};
local LoginPreloadStarted = false;
local LoginPreloadAt = nil;
local LoginPreloadElapsed = 0;
local LoginPreloadInterval = 0.5;
local LoginPreloadDelay = 1.0;
local MaxLoginPreloadItems = 32;

local function SplitItemLinkFields(Link)
    local Fields = {};
    local Text = tostring(Link or "");
    local Start = 1;
    while true do
        local Position = string.find(Text, ":", Start, true);
        if not Position then
            table.insert(Fields, string.sub(Text, Start));
            break;
        end
        table.insert(Fields, string.sub(Text, Start, Position - 1));
        Start = Position + 1;
    end
    return Fields;
end

local function GetGuidAndItemIdFromLink(Link)
    local ItemString = string.match(tostring(Link or ""), "item[%-?%d:]+");
    if not ItemString then
        return 0, 0;
    end

    local Fields = SplitItemLinkFields(ItemString);
    local ItemId = tonumber(Fields[2]) or 0;
    local LinkGuid = tonumber(Fields[9]) or 0;
    if LinkGuid <= 100000000 then
        return 0, ItemId;
    end

    return LinkGuid - 100000000, ItemId;
end

local function QueueLoginPreload(GuidLow, ItemId)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 or ItemId <= 0 then
        return;
    end

    local Key = tostring(GuidLow) .. ":" .. tostring(ItemId);
    if LoginPreloadQueued[Key] then
        return;
    end

    LoginPreloadQueued[Key] = true;
    FrozenCore_MarkOwnedGuid(GuidLow);
    table.insert(LoginPreloadQueue, {
        GuidLow = GuidLow,
        ItemId = ItemId,
        Key = Key,
    });
end

local function QueueLoginPreloadLink(Link)
    local GuidLow, ItemId = GetGuidAndItemIdFromLink(Link);
    QueueLoginPreload(GuidLow, ItemId);
end

local function QueueLoginPreloadLocations()
    local Count = 0;
    local function AddLink(Link)
        if Count >= MaxLoginPreloadItems then
            return;
        end
        local Before = #LoginPreloadQueue;
        QueueLoginPreloadLink(Link);
        if #LoginPreloadQueue > Before then
            Count = Count + 1;
        end
    end

    for Slot = 1, 19 do
        AddLink(GetInventoryItemLink and GetInventoryItemLink("player", Slot));
    end

    -- SoulItemMod keeps the original item GUID separately from its tooltip link.
    if Count < MaxLoginPreloadItems and type(SoulItemButtons) == "table" then
        for _, Button in pairs(SoulItemButtons) do
            local GuidLow = Button and tonumber(Button.ItemGuid) or 0;
            local _, ItemId = GetGuidAndItemIdFromLink(Button and Button.ItemLink);
            QueueLoginPreload(GuidLow, ItemId);
            if #LoginPreloadQueue >= MaxLoginPreloadItems then
                break;
            end
        end
    end
end

local function StartLoginPreload()
    if LoginPreloadStarted then
        return;
    end
    LoginPreloadStarted = true;
    QueueLoginPreloadLocations();
end

local function EnsureStore()
    FrozenData.SchemaVersion = FrozenData.SchemaVersion or 1;
    FrozenData.cacheid = FrozenData.cacheid or {};
    FrozenData.GuidCache = FrozenData.GuidCache or {};
    FrozenData.CurrentCacheId = FrozenData.CurrentCacheId or {};
    FrozenData.ServerCacheId = FrozenData.ServerCacheId or {};
    FrozenData.Characters = FrozenData.Characters or {};
    FrozenData.ItemGuid = FrozenData.ItemGuid or {};

    local Store = FrozenData.ItemGuid;
    Store.Stats = Store.Stats or {};
    Store.Forge = Store.Forge or {};
    Store.Enchant = Store.Enchant or {};
    Store.EnchantCount = Store.EnchantCount or {};
    Store.Runes = Store.Runes or {};
    Store.Develop = Store.Develop or {};
    Store.Additional = Store.Additional or {};
    Store.Template = Store.Template or {};
    Store.ItemId = Store.ItemId or {};
    Store.Hash = Store.Hash or {};
    Store.Record = Store.Record or {};

    for CacheId in pairs(FrozenData.cacheid) do
        local NumberId = tonumber(CacheId);
        if NumberId and NumberId > CacheSerial then
            CacheSerial = NumberId;
        end
    end
end

local function GetCharacterKey()
    local Realm = (GetRealmName and GetRealmName()) or "UnknownRealm";
    local Name = (UnitName and UnitName("player")) or "UnknownCharacter";
    return tostring(Realm) .. ":" .. tostring(Name);
end

local function GetCharacterStore()
    EnsureStore();
    local Key = GetCharacterKey();
    local Character = FrozenData.Characters[Key];
    if type(Character) ~= "table" then
        Character = {};
        FrozenData.Characters[Key] = Character;
    end
    Character.OwnedGuids = Character.OwnedGuids or {};
    return Character;
end

local function GetItemIdFromLink(Link)
    local ItemId = Link and string.match(tostring(Link), "item:(%d+)");
    return tonumber(ItemId) or 0;
end

function FrozenCore_MarkOwnedGuid(GuidLow)
    GuidLow = tonumber(GuidLow) or 0;
    if GuidLow <= 0 then
        return false;
    end
    GetCharacterStore().OwnedGuids[GuidLow] = true;
    return true;
end

local function Split(Text, Separator)
    local Result = {};
    Text = tostring(Text or "");
    Separator = Separator or "#";
    local Start = 1;
    while true do
        local Position = string.find(Text, Separator, Start, true);
        if not Position then
            table.insert(Result, string.sub(Text, Start));
            break;
        end
        table.insert(Result, string.sub(Text, Start, Position - 1));
        Start = Position + string.len(Separator);
    end
    return Result;
end

local function Join(Values, Separator)
    local Result = {};
    for Index = 1, #Values do
        Result[Index] = tostring(Values[Index] or "");
    end
    return table.concat(Result, Separator or "#");
end

local function HashText(Text)
    local Hash = 2166136261;
    Text = tostring(Text or "");
    for Index = 1, string.len(Text) do
        Hash = (Hash + string.byte(Text, Index) * 16777619) % 2147483647;
    end
    return tostring(Hash);
end

local function CopyTable(Source)
    if type(Source) ~= "table" then
        return Source;
    end

    local Result = {};
    for Key, Value in pairs(Source) do
        Result[Key] = type(Value) == "table" and CopyTable(Value) or Value;
    end
    return Result;
end

local function BuildStats(Data)
    if not Data then
        return "";
    end

    local Types = Split(Data.TStore or "", "#");
    local Values = Split(Data.VStore or "", "#");
    local Parts = {};
    for Index = 1, #Types do
        if Types[Index] ~= "" and Types[Index] ~= "-1" and Values[Index] and Values[Index] ~= "" then
            table.insert(Parts, Types[Index] .. " " .. Values[Index]);
        end
    end
    return Join(Parts, "#");
end

local function BuildForge(Data)
    if not Data then
        return "";
    end

    return Join({
        Data.ULevel,
        Data.Prefix,
        Data.Suffix,
        Data.LevelStr,
        Data.MinDmg,
        Data.MaxDmg,
        Data.DPS,
        Data.PutMod,
    }, "#");
end

local function BuildAdditional(ModuleData)
    if not ModuleData then
        return {};
    end

    return {
        BaseAttributes = ModuleData.BaseAttributes or "",
        AdditionalAttributes = ModuleData.AdditionalAttributes or "",
        SkillsData = ModuleData.SkillsData or "",
        SetData = ModuleData.SetData or "",
        RuneData = ModuleData.RuneData or "",
        EnhancementData = ModuleData.EnhancementData or "",
        GrowthData = ModuleData.GrowthData or "",
        HuanjingData = ModuleData.HuanjingData or "",
        IdentificationDisplay = ModuleData.IdentificationDisplay or "",
        PendingIdentifyData = ModuleData.PendingIdentifyData or "",
        TemplateStatsData = ModuleData.TemplateStatsData or "",
        Display = CopyTable(ModuleData.Display),
    };
end

local function BuildSnapshot(GuidLow)
    if not Zs_GuidLowStoreData then
        return nil;
    end

    local GuidData = Zs_GuidLowStoreData.AtGuidData and Zs_GuidLowStoreData.AtGuidData[GuidLow];
    local EnchantData = Zs_GuidLowStoreData.EnchantData and Zs_GuidLowStoreData.EnchantData[GuidLow];
    local RuneData = Zs_GuidLowStoreData.AtRunesData and Zs_GuidLowStoreData.AtRunesData[GuidLow];
    local DevelopData = Zs_GuidLowStoreData.DevelopData and Zs_GuidLowStoreData.DevelopData[GuidLow];
    local EnchantCountData = Zs_GuidLowStoreData.ItemEnchAtCountData and Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow];
    local ModuleData = Zs_GuidLowStoreData.AllModuleData and Zs_GuidLowStoreData.AllModuleData[GuidLow];

    if not (GuidData or EnchantData or EnchantCountData or RuneData or DevelopData or ModuleData) then
        return nil;
    end

    local Enchant = {};
    if EnchantData then
        for Index = 1, #EnchantData do
            Enchant[Index] = EnchantData[Index];
        end
    end

    local Runes = {};
    if RuneData then
        Runes = {
            NowCount = RuneData.NowCount,
            MaxCount = RuneData.MaxCount,
            ItemStore = RuneData.ItemStore,
            OSpellStore = RuneData.OSpellStore,
            GName = RuneData.GName,
            GListStore = RuneData.GListStore,
        };
    end

    local Snapshot = {
        ItemId = (GuidData and GuidData.ItemId) or (RuneData and RuneData.ItemId) or PendingItemIds[GuidLow] or 0,
        Stats = BuildStats(GuidData),
        Forge = BuildForge(GuidData),
        Enchant = Join(Enchant, "#"),
        EnchantCount = EnchantCountData and Join(EnchantCountData, "#") or "",
        Runes = Runes,
        Develop = DevelopData and Join(DevelopData, "#") or "",
        Additional = BuildAdditional(ModuleData),
        Template = {},
        AtGuidData = CopyTable(GuidData),
        TooltipLines = CopyTable(PendingTooltipSnapshots[GuidLow]),
    };
    if Zs_EntryIdStoreData and Zs_EntryIdStoreData.BigItemStatData and Snapshot.ItemId > 0 then
        Snapshot.Template = CopyTable(Zs_EntryIdStoreData.BigItemStatData[Snapshot.ItemId] or {});
    end
    return Snapshot;
end

local function SnapshotSignature(Snapshot)
    if not Snapshot then
        return "";
    end

    local Rune = Snapshot.Runes or {};
    local Add = Snapshot.Additional or {};
    local Parts = {
        Snapshot.ItemId,
        Snapshot.Stats,
        Snapshot.Forge,
        Snapshot.Enchant,
        Snapshot.EnchantCount,
        Rune.NowCount, Rune.MaxCount, Rune.ItemStore, Rune.OSpellStore, Rune.GName, Rune.GListStore,
        Snapshot.Develop,
        Add.BaseAttributes, Add.AdditionalAttributes, Add.SkillsData, Add.SetData,
         Add.RuneData, Add.EnhancementData, Add.GrowthData,
         Add.HuanjingData, Add.IdentificationDisplay, Add.PendingIdentifyData, Add.TemplateStatsData,
        Snapshot.Template.TStore, Snapshot.Template.VStore,
        Snapshot.Template.DmgMin, Snapshot.Template.DmgMax, Snapshot.Template.DPS,
    };
    for Index = 1, #Parts do
        Parts[Index] = tostring(Parts[Index] or "");
    end
    return table.concat(Parts, "|");
end

local function GetGuidCacheList(GuidLow)
    local List = FrozenData.GuidCache[GuidLow];
    if type(List) ~= "table" then
        List = {};
        FrozenData.GuidCache[GuidLow] = List;
    end
    return List;
end

function FrozenCore_RemoveGuidCache(GuidLow)
    GuidLow = tonumber(GuidLow) or 0;
    if GuidLow <= 0 then
        return false;
    end

    EnsureStore();
    local Store = FrozenData.ItemGuid;
    local CacheIds = FrozenData.GuidCache[GuidLow] or {};
    local CacheIdSet = {};
    for Index = 1, #CacheIds do
        local CacheId = tonumber(CacheIds[Index]);
        if CacheId then
            CacheIdSet[CacheId] = true;
        end
    end

    -- Also scan the reverse index so records created by an older cache format
    -- are removed by the same GUID-only protocol.
    for CacheId, CachedGuid in pairs(FrozenData.cacheid) do
        if tonumber(CachedGuid) == GuidLow then
            local NumericCacheId = tonumber(CacheId);
            if NumericCacheId then
                CacheIdSet[NumericCacheId] = true;
            end
        end
    end

    local Fields = { "Stats", "Forge", "Enchant", "EnchantCount", "Runes", "Develop", "Additional", "Template", "ItemId", "Hash", "Record" };
    for CacheId in pairs(CacheIdSet) do
        FrozenData.cacheid[CacheId] = nil;
        for Index = 1, #Fields do
            Store[Fields[Index]][CacheId] = nil;
        end
    end

    FrozenData.GuidCache[GuidLow] = nil;
    FrozenData.CurrentCacheId[GuidLow] = nil;
    FrozenData.ServerCacheId[GuidLow] = nil;
    InvalidatedGuids[GuidLow] = nil;
    for _, Character in pairs(FrozenData.Characters) do
        if Character.OwnedGuids then
            Character.OwnedGuids[GuidLow] = nil;
        end
    end
    return true;
end

local function SaveSnapshot(GuidLow, Snapshot)
    local Signature = HashText(SnapshotSignature(Snapshot));
    local CurrentCacheId = FrozenData.CurrentCacheId[GuidLow];
    local CurrentHash = CurrentCacheId and FrozenData.ItemGuid.Hash[CurrentCacheId] or nil;
    if not InvalidatedGuids[GuidLow] and CurrentHash == Signature then
        local CurrentRecord = CurrentCacheId and FrozenData.ItemGuid.Record[CurrentCacheId] or nil;
        if CurrentRecord and Snapshot.TooltipLines then
            CurrentRecord.TooltipLines = CopyTable(Snapshot.TooltipLines);
        end
        PendingTooltipSnapshots[GuidLow] = nil;
        if FrozenCore_OnSnapshotReady then
            FrozenCore_OnSnapshotReady(GuidLow);
        end
        return CurrentCacheId;
    end

    local CacheId = tonumber(FrozenData.ServerCacheId[GuidLow]);
    local ExistingGuid = CacheId and FrozenData.cacheid[CacheId] or nil;
    local ExistingHash = CacheId and FrozenData.ItemGuid.Hash[CacheId] or nil;
    if not CacheId or CacheId <= 0 or (ExistingGuid and tonumber(ExistingGuid) ~= tonumber(GuidLow)) or
        (ExistingHash and ExistingHash ~= Signature) then
        CacheSerial = CacheSerial + 1;
        CacheId = CacheSerial;
    elseif CacheId > CacheSerial then
        CacheSerial = CacheId;
    end

    FrozenData.cacheid[CacheId] = GuidLow;
    local CacheList = GetGuidCacheList(GuidLow);
    local AlreadyLinked = false;
    for Index = 1, #CacheList do
        if tonumber(CacheList[Index]) == CacheId then
            AlreadyLinked = true;
            break;
        end
    end
    if not AlreadyLinked then
        table.insert(CacheList, CacheId);
    end
    FrozenData.CurrentCacheId[GuidLow] = CacheId;

    local Store = FrozenData.ItemGuid;
    Store.ItemId[CacheId] = Snapshot.ItemId;
    Store.Stats[CacheId] = Snapshot.Stats;
    Store.Forge[CacheId] = Snapshot.Forge;
    Store.Enchant[CacheId] = Snapshot.Enchant;
    Store.EnchantCount[CacheId] = Snapshot.EnchantCount;
    Store.Runes[CacheId] = CopyTable(Snapshot.Runes);
    Store.Develop[CacheId] = Snapshot.Develop;
    Store.Additional[CacheId] = CopyTable(Snapshot.Additional);
    Store.Template[CacheId] = CopyTable(Snapshot.Template);
    Store.Hash[CacheId] = Signature;
    Store.Record[CacheId] = Snapshot;
    InvalidatedGuids[GuidLow] = nil;
    PendingTooltipSnapshots[GuidLow] = nil;
    if FrozenCore_OnSnapshotReady then
        FrozenCore_OnSnapshotReady(GuidLow);
    end
    return CacheId;
end

local function HydrateGuid(GuidLow, CacheId)
    local Record = FrozenData.ItemGuid.Record[CacheId];
    if not Record or not Zs_GuidLowStoreData then
        return;
    end

    Zs_GuidLowStoreData.AtGuidData = Zs_GuidLowStoreData.AtGuidData or {};
    Zs_GuidLowStoreData.EnchantData = Zs_GuidLowStoreData.EnchantData or {};
    Zs_GuidLowStoreData.ItemEnchAtCountData = Zs_GuidLowStoreData.ItemEnchAtCountData or {};
    Zs_GuidLowStoreData.AtRunesData = Zs_GuidLowStoreData.AtRunesData or {};
    Zs_GuidLowStoreData.DevelopData = Zs_GuidLowStoreData.DevelopData or {};
    Zs_GuidLowStoreData.AllModuleData = Zs_GuidLowStoreData.AllModuleData or {};
    Zs_EntryIdStoreData = Zs_EntryIdStoreData or {};
    Zs_EntryIdStoreData.BigItemStatData = Zs_EntryIdStoreData.BigItemStatData or {};

    if Record.AtGuidData then Zs_GuidLowStoreData.AtGuidData[GuidLow] = CopyTable(Record.AtGuidData); end
    if Record.Enchant ~= "" then Zs_GuidLowStoreData.EnchantData[GuidLow] = Split(Record.Enchant, "#"); end
    if (Record.EnchantCount or "") ~= "" then Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow] = Split(Record.EnchantCount, "#"); end
    if Record.Runes and Record.Runes.GName then Zs_GuidLowStoreData.AtRunesData[GuidLow] = CopyTable(Record.Runes); end
    if Record.Develop ~= "" then Zs_GuidLowStoreData.DevelopData[GuidLow] = Split(Record.Develop, "#"); end
    if Record.Additional and (
        Record.Additional.BaseAttributes ~= "" or
        Record.Additional.AdditionalAttributes ~= "" or
        Record.Additional.SkillsData ~= "" or
        Record.Additional.SetData ~= "" or
        Record.Additional.RuneData ~= "" or
        Record.Additional.EnhancementData ~= "" or
        Record.Additional.GrowthData ~= "" or
        Record.Additional.HuanjingData ~= "" or
        Record.Additional.IdentificationDisplay ~= "" or
        Record.Additional.PendingIdentifyData ~= "" or
        Record.Additional.TemplateStatsData ~= ""
    ) then
        Zs_GuidLowStoreData.AllModuleData[GuidLow] = CopyTable(Record.Additional);
        Zs_GuidLowStoreData.AllModuleData[GuidLow].GuidLow = GuidLow;
        Zs_GuidLowStoreData.AllModuleData[GuidLow].ItemId = Record.ItemId;
    end
    if Record.Template and Record.ItemId and Record.ItemId > 0 then
        Zs_EntryIdStoreData.BigItemStatData[Record.ItemId] = CopyTable(Record.Template);
    end
end

local function HydrateAll()
    EnsureStore();
    for GuidLow, CacheId in pairs(FrozenData.CurrentCacheId) do
        HydrateGuid(tonumber(GuidLow), CacheId);
    end
end

function FrozenCore_RehydrateSavedVariables()
    HydrateAll();
end

function FrozenCore_BeginGuidRequest(GuidLow, ItemId)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 then
        return;
    end

    PendingGuids[GuidLow] = true;
    PendingAt[GuidLow] = (GetTime and GetTime()) or 0;
    if ItemId > 0 then
        PendingItemIds[GuidLow] = ItemId;
    end
end

function FrozenCore_BeginGuidUpdate(GuidLow, ServerCacheId)
    GuidLow = tonumber(GuidLow) or 0;
    ServerCacheId = tonumber(ServerCacheId) or 0;
    if GuidLow <= 0 then
        return;
    end

    if ServerCacheId > 0 and LastVersionCacheId[GuidLow] ~= ServerCacheId then
        LastVersionCacheId[GuidLow] = ServerCacheId;
        InvalidatedGuids[GuidLow] = true;
        PendingTooltipSnapshots[GuidLow] = nil;
        -- Keep the currently rendered payload while the new version is being
        -- fetched. Clearing these tables here makes the equipment tooltip
        -- oscillate between the rune width and the normal width, and also
        -- removes the visible module sections for one or more frames. The
        -- incoming legacy/module packets replace the data atomically; a
        -- cache miss is handled by the normal no-data path.
    end

    FrozenCore_BeginGuidRequest(GuidLow);
end

function FrozenCore_MarkGuidDataUpdated(GuidLow, ItemId)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 then
        return;
    end

    PendingGuids[GuidLow] = true;
    PendingAt[GuidLow] = (GetTime and GetTime()) or 0;
    if ItemId > 0 then
        PendingItemIds[GuidLow] = ItemId;
    end
end

function FrozenCore_CancelGuidSnapshot(GuidLow)
    GuidLow = tonumber(GuidLow) or 0;
    PendingGuids[GuidLow] = nil;
    PendingAt[GuidLow] = nil;
    PendingItemIds[GuidLow] = nil;
    PendingTooltipSnapshots[GuidLow] = nil;
end

function FrozenCore_CaptureTooltipSnapshot(GuidLow, ItemId, Tooltip)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 or ItemId <= 0 or not Tooltip or not Tooltip.NumLines or not Tooltip.GetName then
        return false;
    end

    local Lines = {};
    for Index = 1, Tooltip:NumLines() do
        local Left = _G[Tooltip:GetName() .. "TextLeft" .. Index];
        local Right = _G[Tooltip:GetName() .. "TextRight" .. Index];
        local LeftText = Left and Left:GetText() or nil;
        local RightText = Right and Right:GetText() or nil;
        if (LeftText and LeftText ~= "" and LeftText ~= "正在获取物品信息") or (RightText and RightText ~= "") then
            Lines[Index] = {
                Left = LeftText,
                Right = RightText,
            };
        end
    end

    if not next(Lines) then
        return false;
    end

    PendingTooltipSnapshots[GuidLow] = Lines;
    PendingItemIds[GuidLow] = ItemId;
    local CacheId = FrozenData.CurrentCacheId[GuidLow];
    local Record = CacheId and FrozenData.ItemGuid.Record[CacheId] or nil;
    if Record and tonumber(Record.ItemId) == ItemId then
        Record.TooltipLines = CopyTable(Lines);
        PendingTooltipSnapshots[GuidLow] = nil;
    end
    return true;
end

local function CapturePending()
    local Now = (GetTime and GetTime()) or 0;
    for GuidLow in pairs(PendingGuids) do
        if Now - (PendingAt[GuidLow] or Now) >= 0.45 then
            local Snapshot = BuildSnapshot(GuidLow);
            if Snapshot and Snapshot.ItemId and Snapshot.ItemId > 0 then
                SaveSnapshot(GuidLow, Snapshot);
            end
            PendingGuids[GuidLow] = nil;
            PendingAt[GuidLow] = nil;
            PendingItemIds[GuidLow] = nil;
        end
    end
end

function FrozenCore_RequestGuidCache(GuidLow, ItemId)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 or ItemId <= 0 then
        return false;
    end

    EnsureStore();
    FrozenCore_BeginGuidRequest(GuidLow, ItemId);
    local CurrentCacheId = tonumber(FrozenData.CurrentCacheId[GuidLow]) or 0;
    local HasLocalSnapshot = CurrentCacheId > 0 and
        not InvalidatedGuids[GuidLow] and
        FrozenData.ItemGuid.Record[CurrentCacheId] and
        tonumber(FrozenData.ItemGuid.ItemId[CurrentCacheId]) == ItemId;
    local ServerCacheId = HasLocalSnapshot and (tonumber(FrozenData.ServerCacheId[GuidLow]) or 0) or 0;
    local Message = tostring(GuidLow) .. "$" .. string.format("%.0f", ServerCacheId) .. "$" .. tostring(ItemId);
    if Dream_SendData then
        Dream_SendData("FrozenCoreCacheCheck", Message);
    elseif SendAddonMessage then
        SendAddonMessage("FrozenCoreCacheCheck", Message, "GUILD", UnitName("player"));
    else
        return false;
    end
    return true;
end

function QueueCacheValidation(GuidLow, ItemId)
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    if GuidLow <= 0 or ItemId <= 0 then
        return;
    end

    local Key = tostring(GuidLow) .. ":" .. tostring(ItemId);
    if ValidateQueued[Key] then
        return;
    end

    ValidateQueued[Key] = true;
    table.insert(ValidateQueue, { GuidLow = GuidLow, ItemId = ItemId, Key = Key });
end

function FrozenCore_IsGuidCached(GuidLow, ItemId)
    EnsureStore();
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    local CacheId = FrozenData.CurrentCacheId[GuidLow];
    return CacheId and FrozenData.ItemGuid.Record[CacheId] and
        not InvalidatedGuids[GuidLow] and
        tonumber(FrozenData.ItemGuid.ItemId[CacheId]) == ItemId or false;
end

function FrozenCore_GetSnapshot(GuidLow, ItemId)
    EnsureStore();
    GuidLow = tonumber(GuidLow) or 0;
    ItemId = tonumber(ItemId) or 0;
    local CacheId = FrozenData.CurrentCacheId[GuidLow];
    local Record = CacheId and FrozenData.ItemGuid.Record[CacheId] or nil;
    if InvalidatedGuids[GuidLow] or not Record or (ItemId > 0 and tonumber(Record.ItemId) ~= ItemId) then
        return nil, nil;
    end
    return Record, CacheId;
end

function FrozenCore_GetCurrentCacheId(GuidLow)
    EnsureStore();
    return FrozenData.CurrentCacheId[GuidLow];
end

local Frame = CreateFrame("Frame", "FrozenCoreCacheFrame");
Frame:RegisterEvent("VARIABLES_LOADED");
Frame:RegisterEvent("PLAYER_LOGIN");
Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
Frame:SetScript("OnEvent", function(_, Event)
    EnsureStore();
    if Event == "VARIABLES_LOADED" then
        HydrateAll();
    elseif Event == "PLAYER_LOGIN" or Event == "PLAYER_ENTERING_WORLD" then
        LoginPreloadAt = (GetTime and GetTime() or 0) + LoginPreloadDelay;
    end
end);
Frame:SetScript("OnUpdate", function(_, Elapsed)
    CaptureElapsed = CaptureElapsed + (Elapsed or 0);
    if CaptureElapsed >= 0.2 then
        CaptureElapsed = 0;
        CapturePending();
    end
    ValidateElapsed = ValidateElapsed + (Elapsed or 0);
    if ValidateElapsed >= 0.08 then
        ValidateElapsed = 0;
        local Request = table.remove(ValidateQueue, 1);
        if Request then
            ValidateQueued[Request.Key] = nil;
            FrozenCore_RequestGuidCache(Request.GuidLow, Request.ItemId);
        end
    end
    if LoginPreloadAt and not LoginPreloadStarted then
        local Now = (GetTime and GetTime()) or 0;
        if Now >= LoginPreloadAt then
            LoginPreloadAt = nil;
            StartLoginPreload();
        end
    end
    if LoginPreloadStarted and #LoginPreloadQueue > 0 then
        LoginPreloadElapsed = LoginPreloadElapsed + (Elapsed or 0);
        if LoginPreloadElapsed >= LoginPreloadInterval then
            LoginPreloadElapsed = 0;
            local Request = table.remove(LoginPreloadQueue, 1);
            if Request then
                LoginPreloadQueued[Request.Key] = nil;
                FrozenCore_RequestGuidCache(Request.GuidLow, Request.ItemId);
            end
        end
    end
end);

-- Legacy hover requests remain disabled; login preload uses the same GUID/cache
-- validation protocol but sends only one item request per interval.
FrozenCore_DisableLegacyTooltipRequests = true;
FrozenCore_AllowLegacyRequest = false;
EnsureStore();
