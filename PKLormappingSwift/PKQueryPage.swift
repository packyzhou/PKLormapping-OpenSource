
//
//  PKQueryPage.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/17.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

public class PKQueryPage: NSObject {
    public var rows:Int = 0 //每页行数
    public var page:Int = 0 //第x页
    public var recordCount:Int = 0 //总行数
    public var pageCount:Int = 0 //总页数
    
    public init(rows:Int,page:Int) {
        self.rows = rows
        self.page = page
    }
    
    override init() {
        super.init()
    }
}
