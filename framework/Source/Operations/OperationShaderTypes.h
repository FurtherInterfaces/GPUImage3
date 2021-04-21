#include <metal_stdlib>
using namespace metal;

#ifndef OPERATIONSHADERTYPES_H
#define OPERATIONSHADERTYPES_H

#define MATHPI 3.141592653589793
#define TWOPI 6.28318530718

// Luminance Constants
constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);  // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};

#endif
