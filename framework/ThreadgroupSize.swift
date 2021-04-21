//
//  ThreadgroupSize.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 7/8/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//
import MetalKit

public struct ThreadgroupSize {
    public let numThreadgroups: MTLSize
    public let threadsPerGroup: MTLSize
    
    init(forPipelineState pipelineState: MTLComputePipelineState, textureSize: MTLSize) {
        let groupWidth = pipelineState.threadExecutionWidth
        let groupHeight = pipelineState.maxTotalThreadsPerThreadgroup / groupWidth
        
        threadsPerGroup = MTLSizeMake(groupWidth, groupHeight, 1)
        let w = (textureSize.width + groupWidth - 1) / threadsPerGroup.width
        let h = (textureSize.height + groupHeight - 1) / threadsPerGroup.height
        numThreadgroups = MTLSizeMake(w, h, 1)
    }
}
