//
//  ToonFilterCompute.metal
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float threshold;
    float quantizationLevels;
} ToonUniformCompute;

kernel void toonKernel(texture2d<half, access::read> inputTexture [[texture(0)]],
                           texture2d<half, access::write> outputTexture [[texture(1)]],
                           constant ToonUniformCompute& uniform [[buffer(0)]],
                           uint2 gid [[ thread_position_in_grid ]])
{
    float width = inputTexture.get_width();
    float height = inputTexture.get_height();
    
    half4 textureColor = inputTexture.read(gid);
    
    half bottomLeftIntensity = inputTexture.read(gid + uint2(0, 1)).r;
    half bottomRightIntensity = inputTexture.read(gid + uint2(1, 1)).r;
    half leftIntensity = inputTexture.read(gid + uint2(-1, 0)).r;
    half rightIntensity = inputTexture.read(gid + uint2(1, 0)).r;
    half bottomIntensity = inputTexture.read(gid + uint2(0, 1)).r;
    half topIntensity = inputTexture.read(gid + uint2(0, -1)).r;
    half topRightIntensity = inputTexture.read(gid + uint2(1, -1)).r;
    half topLeftIntensity = inputTexture.read(gid + uint2(-1, -1)).r;
    
    half h = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    half v = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    
    half mag = length(half2(h, v));
    
    half3 posterizedImageColor = floor((textureColor.rgb * uniform.quantizationLevels) + 0.5h) / uniform.quantizationLevels;
    
    half thresholdTest = 1.0h - step(half(uniform.threshold), mag);
    
    half4 outColor = half4(posterizedImageColor * thresholdTest, textureColor.a);
    
    outputTexture.write(outColor, gid);
}


