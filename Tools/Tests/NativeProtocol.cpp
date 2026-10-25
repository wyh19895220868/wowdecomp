#include <cassert>
#include <cstdio>
#include <cstring>
#include <vector>
#include "WoW/Source/NativeUIReader.h"
#include "WoW/Source/NativeUIFormat.h"

struct Packet {
    std::vector<unsigned char> bytes;
    uint32_t m_read = 0, m_size;
    Packet(std::initializer_list<unsigned char> data) : bytes(data), m_size(static_cast<uint32_t>(bytes.size())) {}
    void GetData(void* out, uint32_t size) { assert(m_read + size <= m_size); memcpy(out, bytes.data() + m_read, size); m_read += size; }
    template<class T> void Get(T& out) { GetData(&out, sizeof(out)); }
};

int main() {
    const char* maximum = "115792089237316195423570985008687907853269984665640564039457584007913129639935";
    assert(NativeUIIsInt256(maximum));
    assert(!NativeUIIsInt256("115792089237316195423570985008687907853269984665640564039457584007913129639936"));
    assert(!NativeUIIsInt256("1e30") && !NativeUIIsInt256("-") && !NativeUIIsInt256(nullptr));
    assert(strcmp(NativeUIInteger("+0004294967295").c_str(), "4294967295") == 0);
    assert(strcmp(NativeUIInteger("-000").c_str(), "0") == 0);
    char text[64];
    NativeUIFormatAmount("4294967295", text, sizeof(text));
    assert(strcmp(text, "42.9\xE4\xBA\xBF") == 0);
    NativeUIFormatAmount("12345", text, sizeof(text));
    assert(strcmp(text, "1.2\xE4\xB8\x87") == 0);
    NativeUIFormatAmount(maximum, text, sizeof(text));
    assert(strcmp(text, "1.1e+77") == 0);
    Packet packet{'a', 'b', 'c', 'd', 42};
    char small[3];
    assert(NativeUIReadText(&packet, 4, small, sizeof(small)) && strcmp(small, "ab") == 0);
    uint8_t next = 0;
    assert(NativeUIRead(&packet, next) && next == 42);
    assert(!NativeUIRead(&packet, next) && packet.m_read == 5);
    Packet truncated{'a', 'b'};
    assert(!NativeUIReadText(&truncated, 3, small, sizeof(small)) && truncated.m_read == 0);
    assert(!NativeUIReadText(&truncated, 1, small, 0));
    truncated.m_read = 3;
    assert(!NativeUIRead(&truncated, next));
    puts("Native protocol: 256-bit limits, >2^31 formatting, truncation and packet boundaries passed");
}
