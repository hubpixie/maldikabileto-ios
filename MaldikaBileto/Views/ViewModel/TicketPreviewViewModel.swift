//
//  TicketPreviewViewModel.swift
//  Commoney
//
//  Created by x.yang on 2018/07/26.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import Foundation

struct TicketPreviewViewModel {
    /** チケット種別 */
    var ticketType: Ticket.TicketType
    
    /** チケットの金額 */
    var ticketAmount: Int

    /** チケットの有効期限 */
    var ticketExpirationDate: String

    /** 紐づけるカードID */
    var cardId: String

    /** チケットに表示する文言 */
    var ticketTitle: String?
    
    init(ticketType: Ticket.TicketType, ticketAmount: Int, ticketExpirationDate: String, cardId: String, ticketTitle: String?) {
        self.ticketType = ticketType
        self.ticketAmount = ticketAmount
        self.ticketExpirationDate = ticketExpirationDate
        self.cardId = cardId
        self.ticketTitle = ticketTitle
    }
}
