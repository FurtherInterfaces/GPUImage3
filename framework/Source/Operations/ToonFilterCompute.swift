//
//  ToonFilterCompute.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

public class ToonFilterCompute: ComputeOperation {
    public var threshold:Float = 0.2 { didSet { uniformSettings["threshold"] = threshold } }
    public var quantizationLevels:Float = 10.0 { didSet { uniformSettings["quantizationLevels"] = quantizationLevels } }
    
    public init() {
        super.init(computeKernelName: "toonKernel")
        
        ({threshold = 0.2})()
        ({quantizationLevels = 10.0})()
    }
}
