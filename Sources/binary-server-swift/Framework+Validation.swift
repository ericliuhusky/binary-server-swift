//
//  Framework+Validation.swift
//  
//
//  Created by lzh on 2022/6/29.
//

import Foundation
import CryptoKit
import Vapor

extension Framework {
    var isMD5Validated: Bool {
        guard let file = file else { return false }
        let data = Data(buffer: file.data)
        let _md5 = Insecure.MD5.hash(data: data).hexEncodedString()
        return md5 == nil || md5 == _md5
    }
    
    var isSHAValidated: Bool {
        guard let file = file else { return false }
        let data = Data(buffer: file.data)
        let _sha = Insecure.SHA1.hash(data: data).hexEncodedString()
        return sha == nil || sha == _sha
    }
}
