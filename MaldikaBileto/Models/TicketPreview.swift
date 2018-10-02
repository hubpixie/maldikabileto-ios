//
//  TicketPreview.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/25.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation


public struct TicketImageData: Codable {
    
    /** イメージ文字列 */
    public var ticketImage: String
    
    
    public init(ticketImage: String) {
        self.ticketImage = ticketImage
    }
    
    public enum CodingKeys: String, CodingKey {
        case ticketImage = "ticket_image"
    }
}

public struct TicketPreviewImageData: Codable {
    
    /** プレビューイメージ文字列 */
    public var previewTicketImage: String
    
    
    public init(previewTicketImage: String) {
        self.previewTicketImage = previewTicketImage
    }
    
    public enum CodingKeys: String, CodingKey {
        case previewTicketImage = "preview_ticket_image"
    }
}
