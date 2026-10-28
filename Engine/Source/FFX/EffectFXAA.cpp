#include "Engine/Source/FFX/EffectFXAA.h"
#include "Engine/Source/FFX/FxaaShader.inc"
#include "Engine/Source/ConsoleBase/ConsoleVar.h"
#include "Engine/Source/Gx/CGxDevice/CGxDevice.h"
#include "Engine/Source/Gx/CGxDevice/CGxShader.h"
#include "Engine/Source/Gx/Gx.h"
#include "Engine/Source/Services/Texture.h"
#include "Engine/Source/Storm/H/storm.h"
#include <cstring>

PassFXAA::PassFXAA(FFX::Tex** inputs, uint32_t count, FFX::Tex* output, EGxBlend blend, bool flip) : FFX::Pass(inputs, count, output, blend, flip), m_shader(nullptr) {
    if (!g_theGxDevicePtr) {
        return;
    }

    this->m_shader = g_theGxDevicePtr->m_shaderList[GxSh_Pixel].New("FFXAA", 0, 0);

    if (!this->m_shader) {
        return;
    }

    this->m_shader->m_refCount++;
    this->m_shader->m_target = GxSh_Pixel;
    this->m_shader->m_code.SetCount(sizeof(g_fxaaPs));
    memcpy(this->m_shader->m_code.m_data, g_fxaaPs, sizeof(g_fxaaPs));
}

PassFXAA::~PassFXAA() {
    if (this->m_shader && g_theGxDevicePtr) {
        g_theGxDevicePtr->ShaderDestroy(this->m_shader);
    }
}

bool PassFXAA::Valid() {
    return this->m_shader && this->m_shader->Valid();
}

void PassFXAA::Execute() {
    if (!this->m_inputs[0] || !this->m_inputs[0]->m_size.x || !this->m_inputs[0]->m_size.y) {
        return;
    }

    FFX::SetupGx(this->m_output);
    FFX::SetupGeo_Quad(this->m_output->m_size, this->m_inputs[0]->m_size, this->m_inputs[0]->m_texSize, FFX::s_gridPos, FFX::s_gridTex, this->m_flip);

    float shade[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
    FFX::SetupVB_PCT(4, FFX::s_gridPos, FFX::s_gridTex, shade);
    g_theGxDevicePtr->PrimVertexMask(0x3D1);
    FFX::SetupIB();

    float texel[4] = {
        1.0f / static_cast<float>(this->m_inputs[0]->m_size.x),
        1.0f / static_cast<float>(this->m_inputs[0]->m_size.y),
        0.0f,
        0.0f
    };
    GxShaderConstantsSet(GxSh_Pixel, 0, texel, 1);

    g_theGxDevicePtr->RsSet(GxRs_Texture0, TextureGetGxTex(this->m_inputs[0]->m_texture, 1, nullptr));
    g_theGxDevicePtr->RsSet(GxRs_PixelShader, this->m_shader);
    g_theGxDevicePtr->Draw(&FFX::s_quadBatch, 1);
    FFX::SetupReset();
}

EffectFXAA::EffectFXAA() {
    this->m_cvar = CVar::Lookup("gxFXAA");

    FFX::Tex* inputs[] = { &FFX::s_full[0] };
    FFX::Pass* pass = new (__FILE__, __LINE__) PassFXAA(inputs, 1, &FFX::s_screen, GxBlend_Opaque, true);
    this->m_passes.New(pass);
}

EffectFXAA::~EffectFXAA() {
    for (uint32_t i = 0; i < this->m_passes.Count(); i++) {
        delete this->m_passes[i];
    }
}
