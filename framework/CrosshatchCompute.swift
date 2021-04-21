//
//  CrosshatchCompute.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

public class CrosshatchCompute: ComputeOperation {
    public var crossHatchSpacing:Float = 0.03 { didSet { uniformSettings["crossHatchSpacing"] = crossHatchSpacing } }
    public var lineWidth:Float = 0.003 { didSet { uniformSettings["lineWidth"] = lineWidth } }
    
    public init() {
        //super.init(fragmentFunctionName:"crosshatchFragment", numberOfInputs:1)
        super.init(computeKernelName: "crosshatchKernel")
        
        ({crossHatchSpacing = 0.03})()
        ({lineWidth = 0.003})()
    }
}
