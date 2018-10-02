//
// Ticket.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Ticket: Codable {

    public enum TicketType: String, Codable { 
        case gift = "gift"
        case _private = "private"
    }
    public enum TicketStatus: String, Codable {
        case unused = "unused"
        case used = "used"
        case error = "error"

        static var allValues = [unused, used, error]
    }
    public enum PaymentedStatus: String, Codable { 
        case completed = "completed"
        case error = "error"
        case canceled = "canceled"

        static var allValues = [completed, error, canceled]
    }
    /** チケット番号 */
    public var ticketNumber: String
    /** チケット種別(gift:通常チケット、private:自分用チケット) */
    public var ticketType: TicketType
    /** チケットステータス(unused:未使用, used:使用済, error:決済エラー) */
    public var ticketStatus: TicketStatus

    /** チケットに表示する文言 */
    public var ticketTitle: String?

    /** チケットの金額 */
    public var ticketAmount: Int?

    /** チケットの有効期限日 */
    public var ticketExpirationDate: String?

    /** チケット画像 */
    public var ticketImage: String?

    /** レシート画像 */
    public var receiptImage: String?

    /** チケット作成日時(UTC) */
    public var createdAt: String

    /** マスクされたカード番号 */
    public var cardInformation: String

    /** カード会社名 */
    public var cardCompany: String

    /** 決済店舗名 */
    public var paymentedStoreName: String?

    /** 決済金額 */
    public var paymentedAmount: Int?

    /** 決済日時(UTC) */
    public var paymentedAt: String?
    /** 決済ステータス(completed:完了, error:エラー, canceled:取り消し) */
    public var paymentedStatus: PaymentedStatus?

    /** 決済エラーコード(ベリトランスからの応答:vResultCode) */
    public var paymentedErrorCode: String?

    /** 決済エラーメッセージ(ベリトランスからの応答:merrMsg) */
    public var paymentedErrorMessage: String?

    /** 決済取り消し日時(UTC) */
    public var canceledAt: String?

    public init(ticketNumber: String, ticketType: TicketType, ticketStatus: TicketStatus, ticketTitle: String, ticketAmount: Int, ticketExpirationDate: String, ticketImage: String, receiptImage: String?, createdAt: String, cardInformation: String, cardCompany: String, paymentedStoreName: String?, paymentedAmount: Int?, paymentedAt: String?, paymentedStatus: PaymentedStatus?, paymentedErrorCode: String?, paymentedErrorMessage: String?, canceledAt: String?) {
        self.ticketNumber = ticketNumber
        self.ticketType = ticketType
        self.ticketStatus = ticketStatus
        self.ticketTitle = ticketTitle
        self.ticketAmount = ticketAmount
        self.ticketExpirationDate = ticketExpirationDate
        self.ticketImage = ticketImage
        self.receiptImage = receiptImage
        self.createdAt = createdAt
        self.cardInformation = cardInformation
        self.cardCompany = cardCompany
        self.paymentedStoreName = paymentedStoreName
        self.paymentedAmount = paymentedAmount
        self.paymentedAt = paymentedAt
        self.paymentedStatus = paymentedStatus
        self.paymentedErrorCode = paymentedErrorCode
        self.paymentedErrorMessage = paymentedErrorMessage
        self.canceledAt = canceledAt
    }

    public enum CodingKeys: String, CodingKey { 
        case ticketNumber = "ticket_number"
        case ticketType = "ticket_type"
        case ticketStatus = "ticket_status"
        case ticketTitle = "ticket_title"
        case ticketAmount = "ticket_amount"
        case ticketExpirationDate = "ticket_expiration_date"
        case ticketImage = "ticket_image"
        case receiptImage = "receipt_image"
        case createdAt = "created_at"
        case cardInformation = "card_information"
        case cardCompany = "card_company"
        case paymentedStoreName = "paymented_store_name"
        case paymentedAmount = "paymented_amount"
        case paymentedAt = "paymented_at"
        case paymentedStatus = "paymented_status"
        case paymentedErrorCode = "paymented_error_code"
        case paymentedErrorMessage = "paymented_error_message"
        case canceledAt = "canceled_at"
    }


}

