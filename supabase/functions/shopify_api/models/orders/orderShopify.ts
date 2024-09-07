// deno-lint-ignore-file
import { CustomerAddressShopify } from "./customerAddressShopify.ts";
import { LineItemShopify } from "./lineItemShopify.ts";
import { OrderCustomerShopify } from "./orderCustomerShopify.ts";
import {
    OrderShopifyPriceSet,
    OrderShopifyTaxLine,
} from "./orderShopifyTaxLine.ts";
import { ShippingLineShopify } from "./shippingLineShopify.ts";

export enum OrderShopifyFinancialStatus {
    Pending = "pending",
    Authorized = "authorized",
    PartiallyPaid = "partially_paid",
    Paid = "paid",
    PartiallyRefunded = "partially_refunded",
    Refunded = "refunded",
    Voided = "voided",
}

export enum OrderShopifyFulfillmentStatus {
    Fulfilled = "fulfilled",
    Unfulfilled = "unfulfilled",
    Partial = "partial",
    Restocked = "restocked",
}

export class OrderShopify {
    appId: number;
    billingAddress: CustomerAddressShopify;
    browserIp: string;
    buyerAcceptsMarketing: boolean;
    cancelReason?: string;
    cancelledAt?: string;
    cartToken?: string;
    checkoutToken: string;
    clientDetails?: { [key: string]: any };
    closedAt?: string;
    company?: { [key: string]: any };
    confirmationNumber: string;
    createdAt: string;
    currency: string;
    currentTotalAdditionalFeesSet?: string;
    currentTotalDiscounts: string;
    currentTotalDiscountsSet: { [key: string]: any };
    currentTotalDutiesSet?: { [key: string]: any };
    currentTotalPrice: string;
    currentTotalPriceSet: { [key: string]: any };
    currentSubtotalPrice: string;
    currentSubtotalPriceSet: { [key: string]: any };
    currentTotalTax: string;
    currentTotalTaxSet: { [key: string]: any };
    customer: OrderCustomerShopify;
    customerLocale: string;
    discountApplications: { [key: string]: any }[];
    discountCodes: { [key: string]: any }[];
    email?: string;
    estimatedTaxes: boolean;
    financialStatus: OrderShopifyFinancialStatus;
    fulfillments: { [key: string]: any }[];
    fulfillmentStatus?: OrderShopifyFulfillmentStatus;
    id: number;
    landingSite?: string;
    lineItems: LineItemShopify[];
    locationId?: number;
    merchantOfRecordAppId?: number;
    name: string;
    note?: string;
    noteAttributes: { [key: string]: any }[];
    number: number;
    orderNumber: number;
    originalTotalAdditionalFeesSet?: string;
    originalTotalDutiesSet?: { [key: string]: any };
    paymentTerms?: { [key: string]: any };
    paymentGatewayNames: string[];
    phone?: string;
    poNumber?: string;
    presentmentCurrency: string;
    processedAt: string;
    referringSite?: string;
    refunds: { [key: string]: any }[];
    shippingAddress: CustomerAddressShopify;
    shippingLines: ShippingLineShopify[];
    sourceName: string;
    sourceIdentifier?: string;
    sourceUrl?: string;
    subtotalPrice: string;
    subtotalPriceSet: { [key: string]: any };
    tags: string;
    taxLines: OrderShopifyTaxLine[];
    taxesIncluded: boolean;
    test: boolean;
    token: string;
    totalDiscounts: string;
    totalDiscountsSet: { [key: string]: any };
    totalLineItemsPrice: string;
    totalLineItemsPriceSet: { [key: string]: any };
    totalOutstanding: string;
    totalPrice: string;
    totalPriceSet: { [key: string]: any };
    totalShippingPriceSet: OrderShopifyPriceSet;
    totalTax: string;
    totalTaxSet: { [key: string]: any };
    totalTipReceived: string;
    totalWeight: number;
    updatedAt: string;
    userId?: number;
    orderStatusUrl?: string;

    constructor(params: {
        appId: number;
        billingAddress: CustomerAddressShopify;
        browserIp: string;
        buyerAcceptsMarketing: boolean;
        cancelReason?: string;
        cancelledAt?: string;
        cartToken?: string;
        checkoutToken: string;
        clientDetails?: { [key: string]: any };
        closedAt?: string;
        company?: { [key: string]: any };
        confirmationNumber: string;
        createdAt: string;
        currency: string;
        currentTotalAdditionalFeesSet?: string;
        currentTotalDiscounts: string;
        currentTotalDiscountsSet: { [key: string]: any };
        currentTotalDutiesSet?: { [key: string]: any };
        currentTotalPrice: string;
        currentTotalPriceSet: { [key: string]: any };
        currentSubtotalPrice: string;
        currentSubtotalPriceSet: { [key: string]: any };
        currentTotalTax: string;
        currentTotalTaxSet: { [key: string]: any };
        customer: OrderCustomerShopify;
        customerLocale: string;
        discountApplications: { [key: string]: any }[];
        discountCodes: { [key: string]: any }[];
        email?: string;
        estimatedTaxes: boolean;
        financialStatus: OrderShopifyFinancialStatus;
        fulfillments: { [key: string]: any }[];
        fulfillmentStatus?: OrderShopifyFulfillmentStatus;
        id: number;
        landingSite?: string;
        lineItems: LineItemShopify[];
        locationId?: number;
        merchantOfRecordAppId?: number;
        name: string;
        note?: string;
        noteAttributes: { [key: string]: any }[];
        number: number;
        orderNumber: number;
        originalTotalAdditionalFeesSet?: string;
        originalTotalDutiesSet?: { [key: string]: any };
        paymentTerms?: { [key: string]: any };
        paymentGatewayNames: string[];
        phone?: string;
        poNumber?: string;
        presentmentCurrency: string;
        processedAt: string;
        referringSite?: string;
        refunds: { [key: string]: any }[];
        shippingAddress: CustomerAddressShopify;
        shippingLines: ShippingLineShopify[];
        sourceName: string;
        sourceIdentifier?: string;
        sourceUrl?: string;
        subtotalPrice: string;
        subtotalPriceSet: { [key: string]: any };
        tags: string;
        taxLines: OrderShopifyTaxLine[];
        taxesIncluded: boolean;
        test: boolean;
        token: string;
        totalDiscounts: string;
        totalDiscountsSet: { [key: string]: any };
        totalLineItemsPrice: string;
        totalLineItemsPriceSet: { [key: string]: any };
        totalOutstanding: string;
        totalPrice: string;
        totalPriceSet: { [key: string]: any };
        totalShippingPriceSet: OrderShopifyPriceSet;
        totalTax: string;
        totalTaxSet: { [key: string]: any };
        totalTipReceived: string;
        totalWeight: number;
        updatedAt: string;
        userId?: number;
        orderStatusUrl?: string;
    }) {
        this.appId = params.appId;
        this.billingAddress = params.billingAddress;
        this.browserIp = params.browserIp;
        this.buyerAcceptsMarketing = params.buyerAcceptsMarketing;
        this.cancelReason = params.cancelReason;
        this.cancelledAt = params.cancelledAt;
        this.cartToken = params.cartToken;
        this.checkoutToken = params.checkoutToken;
        this.clientDetails = params.clientDetails;
        this.closedAt = params.closedAt;
        this.company = params.company;
        this.confirmationNumber = params.confirmationNumber;
        this.createdAt = params.createdAt;
        this.currency = params.currency;
        this.currentTotalAdditionalFeesSet =
            params.currentTotalAdditionalFeesSet;
        this.currentTotalDiscounts = params.currentTotalDiscounts;
        this.currentTotalDiscountsSet = params.currentTotalDiscountsSet;
        this.currentTotalDutiesSet = params.currentTotalDutiesSet;
        this.currentTotalPrice = params.currentTotalPrice;
        this.currentTotalPriceSet = params.currentTotalPriceSet;
        this.currentSubtotalPrice = params.currentSubtotalPrice;
        this.currentSubtotalPriceSet = params.currentSubtotalPriceSet;
        this.currentTotalTax = params.currentTotalTax;
        this.currentTotalTaxSet = params.currentTotalTaxSet;
        this.customer = params.customer;
        this.customerLocale = params.customerLocale;
        this.discountApplications = params.discountApplications;
        this.discountCodes = params.discountCodes;
        this.email = params.email;
        this.estimatedTaxes = params.estimatedTaxes;
        this.financialStatus = params.financialStatus;
        this.fulfillments = params.fulfillments;
        this.fulfillmentStatus = params.fulfillmentStatus;
        this.id = params.id;
        this.landingSite = params.landingSite;
        this.lineItems = params.lineItems;
        this.locationId = params.locationId;
        this.merchantOfRecordAppId = params.merchantOfRecordAppId;
        this.name = params.name;
        this.note = params.note;
        this.noteAttributes = params.noteAttributes;
        this.number = params.number;
        this.orderNumber = params.orderNumber;
        this.originalTotalAdditionalFeesSet =
            params.originalTotalAdditionalFeesSet;
        this.originalTotalDutiesSet = params.originalTotalDutiesSet;
        this.paymentTerms = params.paymentTerms;
        this.paymentGatewayNames = params.paymentGatewayNames;
        this.phone = params.phone;
        this.poNumber = params.poNumber;
        this.presentmentCurrency = params.presentmentCurrency;
        this.processedAt = params.processedAt;
        this.referringSite = params.referringSite;
        this.refunds = params.refunds;
        this.shippingAddress = params.shippingAddress;
        this.shippingLines = params.shippingLines;
        this.sourceName = params.sourceName;
        this.sourceIdentifier = params.sourceIdentifier;
        this.sourceUrl = params.sourceUrl;
        this.subtotalPrice = params.subtotalPrice;
        this.subtotalPriceSet = params.subtotalPriceSet;
        this.tags = params.tags;
        this.taxLines = params.taxLines;
        this.taxesIncluded = params.taxesIncluded;
        this.test = params.test;
        this.token = params.token;
        this.totalDiscounts = params.totalDiscounts;
        this.totalDiscountsSet = params.totalDiscountsSet;
        this.totalLineItemsPrice = params.totalLineItemsPrice;
        this.totalLineItemsPriceSet = params.totalLineItemsPriceSet;
        this.totalOutstanding = params.totalOutstanding;
        this.totalPrice = params.totalPrice;
        this.totalPriceSet = params.totalPriceSet;
        this.totalShippingPriceSet = params.totalShippingPriceSet;
        this.totalTax = params.totalTax;
        this.totalTaxSet = params.totalTaxSet;
        this.totalTipReceived = params.totalTipReceived;
        this.totalWeight = params.totalWeight;
        this.updatedAt = params.updatedAt;
        this.userId = params.userId;
        this.orderStatusUrl = params.orderStatusUrl;
    }

    static financialStatusFromJson(value: string): OrderShopifyFinancialStatus {
        switch (value) {
            case "pending":
                return OrderShopifyFinancialStatus.Pending;
            case "authorized":
                return OrderShopifyFinancialStatus.Authorized;
            case "partially_paid":
                return OrderShopifyFinancialStatus.PartiallyPaid;
            case "paid":
                return OrderShopifyFinancialStatus.Paid;
            case "partially_refunded":
                return OrderShopifyFinancialStatus.PartiallyRefunded;
            case "refunded":
                return OrderShopifyFinancialStatus.Refunded;
            case "voided":
                return OrderShopifyFinancialStatus.Voided;
            default:
                throw new Error(`Unknown financial status: ${value}`);
        }
    }

    static financialStatusToJson(status: OrderShopifyFinancialStatus): string {
        return status.toString().split(".").pop()!;
    }

    static fulfillmentStatusFromJson(
        value: string | null,
    ): OrderShopifyFulfillmentStatus | null {
        switch (value) {
            case "fulfilled":
                return OrderShopifyFulfillmentStatus.Fulfilled;
            case "partial":
                return OrderShopifyFulfillmentStatus.Partial;
            case "restocked":
                return OrderShopifyFulfillmentStatus.Restocked;
            case null:
                return OrderShopifyFulfillmentStatus.Unfulfilled;
            default:
                throw new Error(`Unknown fulfillment status: ${value}`);
        }
    }

    static fulfillmentStatusToJson(
        status: OrderShopifyFulfillmentStatus | null,
    ): string | null {
        if (status === null) {
            return null;
        }
        return status.toString().split(".").pop()!;
    }
}
