//
//  noise.metal
//  GPUImage
//
//  Created by Phillip Pasqual on 7/5/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

float rand2(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
}

kernel void noiseKernel(texture2d<half, access::write> dst [[ texture(0) ]],
                         uint2 gid [[ thread_position_in_grid ]])
{
    float width = dst.get_width();
    float height = dst.get_height();
    
    // get the normalized position of this pixel
    float2 uv = float2(float(gid.x) / width, float(gid.y) / height);

    half r = clamp(0., 1., rand2(uv));
    half g = clamp(0., 1., rand2(uv * uv));
    half b = clamp(0., 1., rand2(uv * uv * uv));

    dst.write(half4(r, r, r, 1.0), gid);
}
