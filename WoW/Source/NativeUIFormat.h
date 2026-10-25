#ifndef WOW_SOURCE_NATIVEUIFORMAT_H
#define WOW_SOURCE_NATIVEUIFORMAT_H

// NativeUI v2 integers are canonical decimal strings with 256 magnitude bits.
// UTF-8 suffix escapes are required because the client compiles sources as GBK.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

inline bool NativeUIIsInt256(char const* text) {
    if (!text || !*text) return false;
    if (*text == '-' || *text == '+') ++text;
    if (!*text) return false;
    for (char const* p = text; *p; ++p) {
        if (*p < '0' || *p > '9') return false;
    }
    while (*text == '0' && text[1]) ++text;
    size_t length = strlen(text);
    char const* limit = "115792089237316195423570985008687907853269984665640564039457584007913129639935";
    return length < 78 || (length == 78 && strcmp(text, limit) <= 0);
}

class NativeUIInteger {
    std::string m_text;
public:
    NativeUIInteger(int64_t value = 0) {
        char buffer[32];
        _snprintf_s(buffer, sizeof(buffer), _TRUNCATE, "%lld", static_cast<long long>(value));
        m_text = buffer;
    }
    explicit NativeUIInteger(char const* value) {
        if (!NativeUIIsInt256(value)) {
            m_text = "0";
            return;
        }
        bool negative = *value == '-';
        if (*value == '+' || *value == '-') ++value;
        while (*value == '0' && value[1]) ++value;
        m_text = negative && strcmp(value, "0") ? "-" : "";
        m_text += value;
    }
    char const* c_str() const { return m_text.c_str(); }
    explicit operator long double() const { return strtold(m_text.c_str(), nullptr); }
    bool operator>(int value) const { return static_cast<long double>(*this) > value; }
    bool operator<=(int value) const { return !(*this > value); }
};

inline void NativeUIFormatAmount(char const* text, char* buffer, size_t size) {
    if (!NativeUIIsInt256(text)) {
        _snprintf_s(buffer, size, _TRUNCATE, "%s", text ? text : "0");
        return;
    }
    bool negative = *text == '-';
    if (*text == '-' || *text == '+') ++text;
    while (*text == '0' && text[1]) ++text;
    size_t length = strlen(text);
    if (length <= 4) {
        _snprintf_s(buffer, size, _TRUNCATE, "%s%s", negative && strcmp(text, "0") ? "-" : "", text);
        return;
    }
    // Very large values use scientific notation so 78 digits fit into unit frames.
    if (length > 28) {
        _snprintf_s(buffer, size, _TRUNCATE, "%s%c.%ce+%u", negative ? "-" : "", text[0], text[1],
            static_cast<unsigned>(length - 1));
        return;
    }
    unsigned exponent = length > 24 ? 24 : length > 20 ? 20 : length > 16 ? 16 :
        length > 12 ? 12 : length > 8 ? 8 : 4;
    char const* suffix = exponent == 24 ? "\xE7\xA7\xAD" : exponent == 20 ? "\xE5\x9E\x93" :
        exponent == 16 ? "\xE4\xBA\xAC" : exponent == 12 ? "\xE5\x85\x86" :
        exponent == 8 ? "\xE4\xBA\xBF" : "\xE4\xB8\x87";
    size_t split = length - exponent;
    char digits[32];
    memcpy(digits, text, split);
    digits[split] = 0;
    char fraction[3] = {'.', text[split], 0};
    if (fraction[1] == '0') fraction[0] = 0;
    _snprintf_s(buffer, size, _TRUNCATE, "%s%s%s%s", negative ? "-" : "", digits, fraction, suffix);
}

inline void NativeUIFormatAmount(NativeUIInteger const& value, char* buffer, size_t size) {
    NativeUIFormatAmount(value.c_str(), buffer, size);
}

inline void NativeUIFormatAmount(int64_t value, char* buffer, size_t size) {
    NativeUIFormatAmount(NativeUIInteger(value), buffer, size);
}

inline char const* NativeUIFormatAmountIfInteger(char const* value, char* scratch, size_t size) {
    if (!NativeUIIsInt256(value)) return value ? value : "";
    NativeUIFormatAmount(value, scratch, size);
    return scratch;
}

#endif
