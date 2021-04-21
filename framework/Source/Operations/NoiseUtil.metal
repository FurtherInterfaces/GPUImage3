//
//  noiseUtil.metal
//  GPUImage_iOS
//
//  Created by Phillip Pasqual on 7/12/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float rand(float2 xy) {
    return fract(sin(dot(xy, float2(12.9898,78.233))) * 43758.5453123);
}
