//
//  ZoomBlurCompute.metal
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    //float2 center;
    float size;
} ZoomBlurUniformCompute;

kernel void zoomblurKernel(texture2d<half, access::sample> inputTexture [[texture(0)]],
                           texture2d<half, access::write> outputTexture [[texture(1)]],
                           constant ZoomBlurUniformCompute& uniform [[buffer(0)]],
                           uint2 gid [[ thread_position_in_grid ]])
{
    constexpr sampler quadSampler;
    float width = inputTexture.get_width();
    float height = inputTexture.get_height();
    float2 uv = float2(float(gid.x) / width, float(gid.y) / height);
    float2 center = float2(0.5);
    
    float2 samplingOffset = 1.0/100.0 * (center - uv) * uniform.size;

    half4 color = inputTexture.sample(quadSampler, uv) * 0.18;
    
    color += inputTexture.sample(quadSampler, uv + samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, uv + (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, uv + (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, uv + (4.0h * samplingOffset)) * 0.05h;
    color += inputTexture.sample(quadSampler, uv - samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, uv - (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, uv - (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, uv - (4.0h * samplingOffset)) * 0.05h;

    outputTexture.write(color, gid);
}



