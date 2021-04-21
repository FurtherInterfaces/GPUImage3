//
//  Physarum.swift
//  GPUImage
//
//  Created by Phillip Pasqual on 7/13/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

public class Physarum: BasicOperation {
    public init() {
        super.init(fragmentFunctionName:"hardLightBlendFragment", numberOfInputs:2)
    }
}
