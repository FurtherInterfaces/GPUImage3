//
//  ZoomBlurCompute.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 4/20/21.
//  Copyright © 2021 Red Queen Coder, LLC. All rights reserved.
//

public class ZoomBlurCompute: ComputeOperation {
    public var blurSize:Float = 1.0 { didSet { uniformSettings["size"] = blurSize } }
    //public var blurCenter:Position = Position.center { didSet { uniformSettings["center"] = blurCenter } }
    
    public init() {
        super.init(computeKernelName: "zoomblurKernel")
        
        ({blurSize = 1.0})()
        //({blurCenter = Position.center})()
    }
}
