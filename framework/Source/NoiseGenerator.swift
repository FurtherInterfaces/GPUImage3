//
//  NoiseGenerator.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 7/5/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

import Metal
import GPUImage

public class NoiseGenerator: ImageGenerator {

    private let pipelineState: MTLComputePipelineState
    private let threadgroupSize: ThreadgroupSize
    
    public override init(size: Size) {
        let (pipelineState, _) = generateComputePipelineState(device: sharedMetalRenderingDevice,
                                                              kernelName: "noiseKernel",
                                                              operationName: "Noise Generator")
        let textureSize = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
        self.threadgroupSize = ThreadgroupSize(forPipelineState: pipelineState, textureSize: textureSize)
        self.pipelineState = pipelineState
        super.init(size: size)
    }
    
    public func renderNoise() {
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else { return }

        let noiseTexture = internalTexture//Texture(orientation: .portrait, texture: internalTexture as! MTLTexture)
        //commandBuffer.renderQuad(pipelineState: self.pipelineState,
                                 //outputTexture: noiseTexture!)
        let noiseCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        noiseCommandEncoder?.setComputePipelineState(pipelineState)
        noiseCommandEncoder?.setTexture(noiseTexture?.texture, index: 0)
        noiseCommandEncoder?.dispatchThreadgroups(threadgroupSize.numThreadgroups, threadsPerThreadgroup: threadgroupSize.threadsPerGroup)
        noiseCommandEncoder?.endEncoding()

        commandBuffer.commit()
        
        notifyTargets()
    }
}

