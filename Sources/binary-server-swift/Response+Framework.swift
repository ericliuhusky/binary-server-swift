//
//  Response+Framework.swift
//  
//
//  Created by lzh on 2022/6/29.
//

import Vapor

extension Response {
    enum Message {
        case createSuccess
        case deleteSuccess
        case notFoundFileInDatabase
        case notFoundFileOnDisk
        case notFoundFileInBody
        case missingParameters
        case notMD5Validated
        case notSHAValidated
        case fileAlreadyExists
        
        var userMessage: String {
            switch self {
            case .createSuccess: return "保存成功"
            case .deleteSuccess: return "删除成功"
            case .notFoundFileInDatabase: return "无二进制文件"
            case .notFoundFileOnDisk: return "无二进制文件"
            case .notFoundFileInBody: return "没有上传文件"
            case .missingParameters: return "缺少参数"
            case .notMD5Validated: return "md5验证失败"
            case .notSHAValidated: return "sha验证失败"
            case .fileAlreadyExists: return "二进制文件已存在"
            }
        }
    }
    
    static func response(status: HTTPResponseStatus, message: Message, other: @autoclosure () -> String = "") -> Response {
        Response(status: status,
                 body: Body(string: "\(message.userMessage) \(other())\n"))
    }
    
    static func ok(message: Message, other: @autoclosure () -> String = "") -> Response {
        response(status: .ok, message: message, other: other())
    }
    
    static func notFound(message: Message, other: @autoclosure () -> String = "") -> Response {
        response(status: .notFound, message: message, other: other())
    }
    
    static func badRequest(message: Message, other: @autoclosure () -> String = "") -> Response {
        response(status: .badRequest, message: message, other: other())
    }
    
    static func created(message: Message, other: @autoclosure () -> String = "") -> Response {
        response(status: .created, message: message, other: other())
    }
    
    static func conflict(message: Message, other: @autoclosure () -> String = "") -> Response {
        response(status: .conflict, message: message, other: other())
    }
}
