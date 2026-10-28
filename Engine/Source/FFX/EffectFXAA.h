#ifndef ENGINE_SOURCE_FFX_EFFECTFXAA_H
#define ENGINE_SOURCE_FFX_EFFECTFXAA_H

#include "Engine/Source/FFX/FFX.h"

class CGxShader;

class PassFXAA : public FFX::Pass {
    public:
    CGxShader* m_shader;

    ~PassFXAA() override;
    bool Valid() override;
    void Execute() override;

    PassFXAA(FFX::Tex** inputs, uint32_t count, FFX::Tex* output, EGxBlend blend, bool flip);
};

class EffectFXAA : public FFX::Effect {
    public:
    ~EffectFXAA() override;
    EffectFXAA();
};

#endif
