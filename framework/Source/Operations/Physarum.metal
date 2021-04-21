//
//  physarum.metal
//  GPUImage_iOS
//
//  Created by Phillip Pasqual on 7/9/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "NoiseUtil.h"
using namespace metal;

kernel void noise2PosKernel(texture2d<half, access::read_write> noiseTex [[ texture(0) ]],
                            uint2 gid [[ thread_position_in_grid ]])
{
    float width = noiseTex.get_width();
    float height = noiseTex.get_height();
    float aspect = height/width;

    half4 color = noiseTex.read(gid);
    color.r *= aspect;
    color.b *= TWOPI;
    color.a = 1.0;
    
    noiseTex.write(color, gid);
}

typedef struct PhysarumArgs {
    float sensorAngle [[ id(0) ]];
    float rotationAngle [[ id(1) ]];
    float seed [[ id(2) ]];
    float stepSize [[ id(3) ]];
    float sensorDistanceOffset [[ id(4) ]];
    float pctRandomDir [[ id(5) ]];
    float stepSizeMult [[ id(6) ]];
    float2 trailThresholds [[ id(7) ]];
    float2 depositThresholds [[ id(8) ]];
    float killPct [[ id(9) ]];
    float depositAmt [[ id(10) ]];
} PhysarumArgs;

kernel void physarumKernel(texture2d<float, access::sample> src_positions [[ texture(0) ]],
                              texture2d<float, access::sample> src_trails [[ texture(1) ]],
                              texture2d<float, access::sample> src_reset [[ texture(2) ]],
                              texture2d<float, access::write> dst [[ texture(3) ]],
                              device PhysarumArgs &physarumArgs [[ buffer(0) ]],
                              uint2 gid [[ thread_position_in_grid ]])
{
    constexpr sampler linearSampler(filter::linear, address::clamp_to_zero);
    
    float width = dst.get_width();
    float height = dst.get_height();
    float aspect = width/height;
    float2 uv = float2(float(gid.x) / width, float(gid.y) / height);

    float4 data = src_positions.sample(linearSampler, uv);
    float2 pos = data.xy;
    pos.x /= aspect;
    
    float heading = data.z;
    
    float angleA = heading + physarumArgs.sensorAngle;
    float angleB = heading;
    float angleC = heading - physarumArgs.sensorAngle;
    
    float sensorOffset = physarumArgs.sensorDistanceOffset;
    
    float2 tex = float2(src_trails.get_width(), src_trails.get_height()) * sensorOffset;
    float2 uvA = pos + tex * float2(cos(angleA), sin(angleA));
    float2 uvB = pos + tex * float2(cos(angleB), sin(angleB));
    float2 uvC = pos + tex * float2(cos(angleC), sin(angleC));
    
    float4 senA = src_trails.sample(linearSampler, uvA);
    float4 senB = src_trails.sample(linearSampler, uvB);
    float4 senC = src_trails.sample(linearSampler, uvC);
    
    float r1 = rand(uv.yx + float2(1.13646 * physarumArgs.seed, 1.3261564 * physarumArgs.seed));
    
    if(r1 < physarumArgs.pctRandomDir) {
        //rotate randomly left or right by rotation angle
        heading += rand(uv + float2(physarumArgs.seed, physarumArgs.seed)) > 0.5 ? -physarumArgs.rotationAngle : physarumArgs.rotationAngle;
    }
    else if ((senB.r > senA.r) && (senB.r > senC.r)) {
        //keep facing same direction
    }
    else if ((senB.r < senA.r) && (senB.r < senC.r)) {
        //rotate randomly left or right by rotation angle
        heading += rand(uv + float2(physarumArgs.seed, physarumArgs.seed)) > 0.5 ? -physarumArgs.rotationAngle : physarumArgs.rotationAngle;
    }
    else if (senA.r < senC.r) {
        //rotate right by rotation angle
        heading -= physarumArgs.rotationAngle;
    }
    else if(senC.r < senA.r) {
        //rotate left by rotation angle
        heading += physarumArgs.rotationAngle;
    }
    
    float2 tempVec = tex * float2(cos(heading), sin(heading));
    float2 tempPos = pos + physarumArgs.stepSize * tempVec;
    
    float4 newData = src_trails.sample(linearSampler, tempPos);
    
    float doDeposit = smoothstep(physarumArgs.depositThresholds.x, physarumArgs.depositThresholds.y, newData.r);// + 10.0;
    if(doDeposit == 0.0) {
        heading = rand(uv.yx + float2(-physarumArgs.seed, physarumArgs.seed)) * 6.28318530718;
    }
    
    float actualStepSize = physarumArgs.stepSize * 0.1 * mix(1.0, physarumArgs.stepSizeMult * 0.4, smoothstep(physarumArgs.trailThresholds.x, physarumArgs.trailThresholds.y, newData.r));
    pos += actualStepSize * tempVec;
    
    //boundary repeat
    pos = fract(pos);
    pos.x *= aspect;

    dst.write(float4(pos, heading, doDeposit*physarumArgs.depositAmt), gid);
}
