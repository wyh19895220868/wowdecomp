#ifndef WOW_SOURCE_OBJECT_OBJECTCLIENT_UNITCOMBAT_C_H
#define WOW_SOURCE_OBJECT_OBJECTCLIENT_UNITCOMBAT_C_H

#include <cstddef>
#include <cstdint>
#include "WoW/Source/Object/WGUID.h"
#include "WoW/Source/Object/ObjectClient/Types.h"
#include "WoW/Source/Net/Types.h"

class CDataStore;

class ATTACKROUNDINFO {
    public:
    /* 0000 */ WOWGUID m_attacker;
    /* 0008 */ WOWGUID m_target;
    /* 0010 */ uint32_t m_hitInfo;
    /* 0014 */ uint32_t m_damage;
    /* 0018 */ uint32_t m_overkill;
    /* 001C */ uint32_t m_schoolMask [2];
    /* 0024 */ float unk_0024 [2];
    /* 002C */ float unk_002C [2];
    /* 0034 */ float m_subDamage [2];
    /* 003C */ uint32_t m_subDamageInt [2];
    /* 0044 */ uint32_t m_absorbed [2];
    /* 004C */ uint32_t m_resisted [2];
    /* 0054 */ VICTIMSTATES m_victimState;
    /* 0058 */ uint32_t unk_0058;
    /* 005C */ uint32_t m_meleeSpellId;
    /* 0060 */ uint32_t m_blocked;
    /* 0064 */ uint32_t m_rageGained;
    /* 0068 */ uint32_t unk_0068;
    /* 006C */ float unk_006C [8];
    /* 008C */ uint32_t unk_008C [5];
    // Stock 3.3.5 packets carry uint32 amounts; the paired wide-resource server
    // uses uint64. Keep the legacy projections and the exact decoded amounts.
    /* 00A0 */ uint64_t m_damageWide;
    /* 00A8 */ uint64_t m_overkillWide;
    /* 00B0 */ uint64_t m_subDamageIntWide [2];
    /* 00C0 */ uint64_t m_absorbedWide [2];
    /* 00D0 */ uint64_t m_resistedWide [2];
    /* 00E0 */ uint64_t m_blockedWide;

    ATTACKROUNDINFO();
    ATTACKROUNDINFO& operator=(const ATTACKROUNDINFO& other);
    bool Unpack(CDataStore& msg);
};

void TargetAttacker(const WOWGUID& attacker);
int32_t Packet_Group_29(void* param, NETMESSAGE msgId, uint32_t time, CDataStore* msg);

void UnitCombatClientInitialize();
void UnitCombatClientShutdown();

#endif
