//
//  CrosshatchCompute.metal
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float crossHatchSpacing;
    float lineWidth;
} CrosshatchUniformCompute;

kernel void crosshatchKernel(texture2d<half, access::sample> inputTexture [[texture(0)]],
                               texture2d<half, access::write> outputTexture [[texture(1)]],
                               constant CrosshatchUniformCompute& uniform [[buffer(0)]],
                               uint2 gid [[ thread_position_in_grid ]])
{
    constexpr sampler quadSampler;
    float width = inputTexture.get_width();
    float height = inputTexture.get_height();
    float2 uv = float2(float(gid.x) / width, float(gid.y) / height);
    
    half4 color = inputTexture.sample(quadSampler, uv); // Do we use these? How??
    
    half luminance = dot(color.rgb, half3(0.2125, 0.7154, 0.0721));
    
    half4 colorToDisplay = half4(1.0); // I think you only need one value if they're all the same
    
    if (luminance < 1.00)
    {
        if (mod(uv.x + uv.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.75)
    {
        if (mod(uv.x - uv.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.50)
    {
        if (mod(uv.x + uv.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.3)
    {
        if (mod(uv.x - uv.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    outputTexture.write(colorToDisplay, gid);
}
