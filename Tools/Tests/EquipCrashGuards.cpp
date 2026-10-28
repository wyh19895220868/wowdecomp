#include <cstdint>
#include <cstdio>
#include <cstdlib>

// Mirrors Engine/Source/Model2/M2Shared.cpp M2RangeInFile.
static int M2RangeInFile(uint32_t offset, uint32_t count, uint32_t elemSize, uint32_t fileSize) {
    if (!elemSize || offset > fileSize) {
        return 0;
    }

    return count <= (fileSize - offset) / elemSize;
}

// Mirrors CM2Shared::GetSkinProfileIndex. The classic table has four entries.
static uint32_t SkinProfileIndex(uint32_t count, uint32_t maxBones) {
    static const uint32_t boneCounts[4] = { 256, 64, 53, 21 };

    if (!count) {
        return 0xFFFFFFFFu;
    }

    if (count > 4) {
        return 0;
    }

    for (uint32_t i = 0; i < count; i++) {
        if (boneCounts[4 - count + i] <= maxBones) {
            return i;
        }
    }

    return 0xFFFFFFFFu;
}

// The previous formula indexed boneCounts[4 - count + i]. count > 4 wraps.
static int OldSkinIndexInRange(uint32_t count) {
    if (!count) {
        return 1;
    }

    for (uint32_t i = 0; i < count && i < 8; i++) {
        uint32_t index = 4u - count + i;

        if (index >= 4u) {
            return 0;
        }
    }

    return 1;
}

// Mirrors CBLPFile::MipBytes range test.
static int MipInFile(uint32_t offset, uint32_t mipSize, uint32_t fileSize) {
    if (!mipSize || offset > fileSize || mipSize > fileSize - offset) {
        return 0;
    }

    return 1;
}

static int g_failed;

static void Expect(int condition, const char* name) {
    if (!condition) {
        std::printf("FAIL %s\n", name);
        g_failed = 1;
    }
}

int main() {
    Expect(M2RangeInFile(0, 0, 4, 0) == 1, "empty array at start");
    Expect(M2RangeInFile(8, 2, 4, 16) == 1, "array fits");
    Expect(M2RangeInFile(8, 3, 4, 16) == 0, "array past end");
    Expect(M2RangeInFile(0, 0x40000000u, 8, 32) == 0, "wrapped count rejected");

    Expect(SkinProfileIndex(0, 256) == 0xFFFFFFFFu, "no skins");
    Expect(SkinProfileIndex(4, 256) == 0, "full detail");
    Expect(SkinProfileIndex(4, 21) == 3, "lowest classic skin");
    Expect(SkinProfileIndex(4, 20) == 0xFFFFFFFFu, "no classic skin fits");
    Expect(SkinProfileIndex(1, 256) == 0, "single classic skin");
    Expect(SkinProfileIndex(5, 256) == 0, "extra hd skin uses profile 0");
    Expect(OldSkinIndexInRange(5) == 0, "old formula leaves the four-entry table");

    Expect(MipInFile(16, 32, 64) == 1, "mip inside file");
    Expect(MipInFile(0x706C623Eu, 4, 128) == 0, "string-sized offset is not a mip");
    Expect(MipInFile(60, 8, 64) == 0, "mip crosses end");
    Expect(MipInFile(0, 0, 64) == 0, "empty mip");

    if (g_failed) {
        return 1;
    }

    std::printf("equip crash guards ok\n");
    return 0;
}
