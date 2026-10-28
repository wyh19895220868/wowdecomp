sampler s0 : register(s0);
float2 rcpFrame : register(c0);

float Luma(float3 rgb) {
    return dot(rgb, float3(0.299, 0.587, 0.114));
}

float4 main(float2 pos : TEXCOORD0) : COLOR0 {
    float3 rgbN = tex2D(s0, pos + float2(0.0, -1.0) * rcpFrame).rgb;
    float3 rgbW = tex2D(s0, pos + float2(-1.0, 0.0) * rcpFrame).rgb;
    float3 rgbM = tex2D(s0, pos).rgb;
    float3 rgbE = tex2D(s0, pos + float2(1.0, 0.0) * rcpFrame).rgb;
    float3 rgbS = tex2D(s0, pos + float2(0.0, 1.0) * rcpFrame).rgb;

    float lumaN = Luma(rgbN);
    float lumaW = Luma(rgbW);
    float lumaM = Luma(rgbM);
    float lumaE = Luma(rgbE);
    float lumaS = Luma(rgbS);

    float rangeMin = min(lumaM, min(min(lumaN, lumaW), min(lumaS, lumaE)));
    float rangeMax = max(lumaM, max(max(lumaN, lumaW), max(lumaS, lumaE)));

    if (rangeMax - rangeMin < max(0.0833, rangeMax * 0.166)) {
        return float4(rgbM, 1.0);
    }

    float2 dir = float2(lumaW - lumaE, lumaN - lumaS);
    float dirReduce = max((lumaN + lumaS + lumaE + lumaW) * (0.25 * 0.125), 0.0078125);
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = clamp(dir * rcpDirMin, -8.0, 8.0) * rcpFrame;

    float3 rgbA = 0.5 * (
        tex2D(s0, pos + dir * (1.0 / 3.0 - 0.5)).rgb +
        tex2D(s0, pos + dir * (2.0 / 3.0 - 0.5)).rgb);
    float3 rgbB = rgbA * 0.5 + 0.25 * (
        tex2D(s0, pos + dir * -0.5).rgb +
        tex2D(s0, pos + dir * 0.5).rgb);

    float lumaB = Luma(rgbB);
    return float4((lumaB < rangeMin || lumaB > rangeMax) ? rgbA : rgbB, 1.0);
}
