//
//  MimeTypes.swift
//  Telegram-Mac
//
//  Created by keepcoder on 19/10/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa
import SwiftSignalKitMac

fileprivate var mimestore:[String:String] = [:]
fileprivate var extensionstore:[String:String] = [:]


private func initializeMimeStore() {
    do {
        if mimestore.isEmpty && extensionstore.isEmpty {
            let path = Bundle.main.path(forResource: "mime-types", ofType: "txt")
            let content = try? String(contentsOfFile: path ?? "")
            let mimes = content?.components(separatedBy: CharacterSet.newlines)
            
            if let mimes = mimes {
                for mime in mimes {
                    let single = mime.components(separatedBy: ":")
                    if single.count == 2 {
                        extensionstore[single[0]] = single[1]
                        mimestore[single[1]] = single[0]
                    }
                }
            }
        }
    }
}

func resourceType(mimeType:String? = nil, orExt:String? = nil) -> Signal<String?,Void> {
    
    initializeMimeStore()
    
    assert(mimeType != nil || orExt != nil)
    assert((mimeType != nil && orExt == nil) || (mimeType == nil && orExt != nil))
    
    return Signal<String?,Void> { (subscriber) -> Disposable in
        
        var result:String?
        
        if let mimeType = mimeType {
            result = mimestore[mimeType]
        } else if let orExt = orExt {
            result = extensionstore[orExt.lowercased()]
        }
        
        subscriber.putNext(result)
        subscriber.putCompletion()
        
        return EmptyDisposable
        
    } |> runOn(resourcesQueue)
}

func MIMEType(_ fileExtension: String) -> String {
    
    initializeMimeStore()

    if let ext = extensionstore[fileExtension] {
        return ext
    } else {
        if !fileExtension.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
            let UTI = UTIRef?.takeRetainedValue()
            if let UTI = UTI {
                let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)
                if MIMETypeRef != nil
                {
                    let MIMEType = MIMETypeRef?.takeRetainedValue()
                    return MIMEType as String? ?? "application/octet-stream"
                }
            }
            
        }
        return "application/octet-stream"
    }
    
    
}

let voiceMime = "audio/ogg"
let musicMime = "audio/mp3"
