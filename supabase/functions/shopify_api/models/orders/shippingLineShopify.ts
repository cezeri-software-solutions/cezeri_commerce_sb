// deno-lint-ignore-file
import {
    OrderShopifyPriceSet,
    OrderShopifyTaxLine,
} from "./orderShopifyTaxLine.ts";

export class ShippingLineShopify {
    id: number;
    carrierIdentifier?: string;
    code: string;
    discountedPrice: string;
    discountedPriceSet: OrderShopifyPriceSet;
    phone?: string;
    price: string;
    priceSet: OrderShopifyPriceSet;
    requestedFulfillmentServiceId?: string;
    source: string;
    title: string;
    taxLines: OrderShopifyTaxLine[];
    discountAllocations: { [key: string]: any }[];

    constructor(
        id: number,
        carrierIdentifier: string | undefined,
        code: string,
        discountedPrice: string,
        discountedPriceSet: OrderShopifyPriceSet,
        phone: string | undefined,
        price: string,
        priceSet: OrderShopifyPriceSet,
        requestedFulfillmentServiceId: string | undefined,
        source: string,
        title: string,
        taxLines: OrderShopifyTaxLine[],
        discountAllocations: { [key: string]: any }[],
    ) {
        this.id = id;
        this.carrierIdentifier = carrierIdentifier;
        this.code = code;
        this.discountedPrice = discountedPrice;
        this.discountedPriceSet = discountedPriceSet;
        this.phone = phone;
        this.price = price;
        this.priceSet = priceSet;
        this.requestedFulfillmentServiceId = requestedFulfillmentServiceId;
        this.source = source;
        this.title = title;
        this.taxLines = taxLines;
        this.discountAllocations = discountAllocations;
    }

    static fromJson(json: { [key: string]: any }): ShippingLineShopify {
        return new ShippingLineShopify(
            json["id"],
            json["carrier_identifier"],
            json["code"],
            json["discounted_price"],
            json["discounted_price_set"],
            json["phone"],
            json["price"],
            json["price_set"],
            json["requested_fulfillment_service_id"],
            json["source"],
            json["title"],
            json["tax_lines"].map((taxLine: any) =>
                OrderShopifyTaxLine.fromJson(taxLine)
            ),
            json["discount_allocations"],
        );
    }

    toJson(): { [key: string]: any } {
        return {
            id: this.id,
            carrier_identifier: this.carrierIdentifier,
            code: this.code,
            discounted_price: this.discountedPrice,
            discounted_price_set: this.discountedPriceSet.toJson(),
            phone: this.phone,
            price: this.price,
            price_set: this.priceSet.toJson(),
            requested_fulfillment_service_id:
                this.requestedFulfillmentServiceId,
            source: this.source,
            title: this.title,
            tax_lines: this.taxLines.map((taxLine) => taxLine.toJson()),
            discount_allocations: this.discountAllocations,
        };
    }
}
