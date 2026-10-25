#ifndef WOW_SOURCE_WINDPI_H
#define WOW_SOURCE_WINDPI_H

#include <windows.h>

// Keep the client bitmap-independent on high-DPI displays. The Windows 8.1
// API is loaded dynamically so the same binary still runs on Windows 7; the
// older user32 fallback is sufficient there.
inline void SetWowProcessDpiAwareness() {
    using SetProcessDpiAwarenessFn = HRESULT(WINAPI*)(int);

    HMODULE shcore = LoadLibraryW(L"Shcore.dll");

    if (shcore) {
        SetProcessDpiAwarenessFn setProcessDpiAwareness = reinterpret_cast<SetProcessDpiAwarenessFn>(GetProcAddress(shcore, "SetProcessDpiAwareness"));

        if (setProcessDpiAwareness && SUCCEEDED(setProcessDpiAwareness(2))) {
            FreeLibrary(shcore);
            return;
        }

        FreeLibrary(shcore);
    }

    SetProcessDPIAware();
}

#endif
