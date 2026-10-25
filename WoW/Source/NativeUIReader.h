#ifndef WOW_SOURCE_NATIVEUIREADER_H
#define WOW_SOURCE_NATIVEUIREADER_H

#include <cstdint>
#include <cstddef>

// Read lengths without changing the wire length when a destination is smaller.
template <typename Store, typename T>
inline bool NativeUIRead(Store* msg, T& value) {
    if (msg->m_read > msg->m_size || sizeof(T) > msg->m_size - msg->m_read) return false;
    uint32_t before = msg->m_read;
    msg->Get(value);
    return msg->m_read == before + sizeof(T);
}

template <typename Store>
inline bool NativeUIReadText(Store* msg, uint32_t length, char* out, size_t capacity) {
    if (!capacity || msg->m_read > msg->m_size || length > msg->m_size - msg->m_read) return false;
    uint32_t copied = length < capacity ? length : static_cast<uint32_t>(capacity - 1);
    uint32_t before = msg->m_read;
    if (copied) msg->GetData(out, copied);
    out[copied] = 0;
    uint32_t remaining = length - copied;
    char discard[256];
    while (remaining) {
        uint32_t chunk = remaining < sizeof(discard) ? remaining : sizeof(discard);
        msg->GetData(discard, chunk);
        remaining -= chunk;
    }
    return msg->m_read == before + length;
}

#endif
