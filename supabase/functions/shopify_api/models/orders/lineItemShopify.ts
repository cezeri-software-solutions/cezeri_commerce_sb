// deno-lint-ignore-file
import {
    OrderShopifyPriceSet,
    OrderShopifyPriceSetJSON,
    OrderShopifyTaxLine,
    OrderShopifyTaxLineJSON,
} from "./orderShopifyTaxLine.ts";

export class LineItemShopify {
    attributedStaffs: Array<{ [key: string]: any }>;
    id: number;
    quantity: number;
    fulfillableQuantity: number;
    fulfillmentService: string;
    fulfillmentStatus?: string;
    grams: number;
    price: string;
    priceSet: OrderShopifyPriceSet;
    productId?: number;
    currentQuantity: number;
    requiresShipping: boolean;
    sku: string;
    title: string;
    variantId?: number;
    variantTitle?: string;
    vendor: string;
    name: string;
    giftCard: boolean;
    properties: Array<{ [key: string]: any }>;
    taxable: boolean;
    taxLines: OrderShopifyTaxLine[];
    tipPaymentGateway?: string;
    tipPaymentMethod?: string;
    totalDiscount: string;
    totalDiscountSet: OrderShopifyPriceSet;
    discountAllocations: Array<{ [key: string]: any }>;
    originLocation?: { [key: string]: any };
    duties: Array<{ [key: string]: any }>;

    constructor(
        attributedStaffs: Array<{ [key: string]: any }>,
        id: number,
        quantity: number,
        fulfillableQuantity: number,
        fulfillmentService: string,
        fulfillmentStatus: string | undefined,
        grams: number,
        price: string,
        priceSet: OrderShopifyPriceSet,
        productId: number | undefined,
        currentQuantity: number,
        requiresShipping: boolean,
        sku: string,
        title: string,
        variantId: number | undefined,
        variantTitle: string | undefined,
        vendor: string,
        name: string,
        giftCard: boolean,
        properties: Array<{ [key: string]: any }>,
        taxable: boolean,
        taxLines: OrderShopifyTaxLine[],
        tipPaymentGateway: string | undefined,
        tipPaymentMethod: string | undefined,
        totalDiscount: string,
        totalDiscountSet: OrderShopifyPriceSet,
        discountAllocations: Array<{ [key: string]: any }>,
        originLocation: { [key: string]: any } | undefined,
        duties: Array<{ [key: string]: any }>,
    ) {
        this.attributedStaffs = attributedStaffs;
        this.id = id;
        this.quantity = quantity;
        this.fulfillableQuantity = fulfillableQuantity;
        this.fulfillmentService = fulfillmentService;
        this.fulfillmentStatus = fulfillmentStatus;
        this.grams = grams;
        this.price = price;
        this.priceSet = priceSet;
        this.productId = productId;
        this.currentQuantity = currentQuantity;
        this.requiresShipping = requiresShipping;
        this.sku = sku;
        this.title = title;
        this.variantId = variantId;
        this.variantTitle = variantTitle;
        this.vendor = vendor;
        this.name = name;
        this.giftCard = giftCard;
        this.properties = properties;
        this.taxable = taxable;
        this.taxLines = taxLines;
        this.tipPaymentGateway = tipPaymentGateway;
        this.tipPaymentMethod = tipPaymentMethod;
        this.totalDiscount = totalDiscount;
        this.totalDiscountSet = totalDiscountSet;
        this.discountAllocations = discountAllocations;
        this.originLocation = originLocation;
        this.duties = duties;
    }

    static fromJson(json: LineItemShopifyJSON): LineItemShopify {
        return new LineItemShopify(
            json.attributed_staffs,
            json.id,
            json.quantity,
            json.fulfillable_quantity,
            json.fulfillment_service,
            json.fulfillment_status,
            json.grams,
            json.price,
            OrderShopifyPriceSet.fromJson(json.price_set),
            json.product_id,
            json.current_quantity,
            json.requires_shipping,
            json.sku,
            json.title,
            json.variant_id,
            json.variant_title,
            json.vendor,
            json.name,
            json.gift_card,
            json.properties,
            json.taxable,
            json.tax_lines.map(OrderShopifyTaxLine.fromJson),
            json.tip_payment_gateway,
            json.tip_payment_method,
            json.total_discount,
            OrderShopifyPriceSet.fromJson(json.total_discount_set),
            json.discount_allocations,
            json.origin_location,
            json.duties,
        );
    }

    toJson(): LineItemShopifyJSON {
        return {
            attributed_staffs: this.attributedStaffs,
            id: this.id,
            quantity: this.quantity,
            fulfillable_quantity: this.fulfillableQuantity,
            fulfillment_service: this.fulfillmentService,
            fulfillment_status: this.fulfillmentStatus,
            grams: this.grams,
            price: this.price,
            price_set: this.priceSet.toJson(),
            product_id: this.productId,
            current_quantity: this.currentQuantity,
            requires_shipping: this.requiresShipping,
            sku: this.sku,
            title: this.title,
            variant_id: this.variantId,
            variant_title: this.variantTitle,
            vendor: this.vendor,
            name: this.name,
            gift_card: this.giftCard,
            properties: this.properties,
            taxable: this.taxable,
            tax_lines: this.taxLines.map((taxLine) => taxLine.toJson()),
            tip_payment_gateway: this.tipPaymentGateway,
            tip_payment_method: this.tipPaymentMethod,
            total_discount: this.totalDiscount,
            total_discount_set: this.totalDiscountSet.toJson(),
            discount_allocations: this.discountAllocations,
            origin_location: this.originLocation,
            duties: this.duties,
        };
    }

    copyWith({
        attributedStaffs,
        id,
        quantity,
        fulfillableQuantity,
        fulfillmentService,
        fulfillmentStatus,
        grams,
        price,
        priceSet,
        productId,
        currentQuantity,
        requiresShipping,
        sku,
        title,
        variantId,
        variantTitle,
        vendor,
        name,
        giftCard,
        properties,
        taxable,
        taxLines,
        tipPaymentGateway,
        tipPaymentMethod,
        totalDiscount,
        totalDiscountSet,
        discountAllocations,
        originLocation,
        duties,
    }: Partial<LineItemShopify>): LineItemShopify {
        return new LineItemShopify(
            attributedStaffs ?? this.attributedStaffs,
            id ?? this.id,
            quantity ?? this.quantity,
            fulfillableQuantity ?? this.fulfillableQuantity,
            fulfillmentService ?? this.fulfillmentService,
            fulfillmentStatus ?? this.fulfillmentStatus,
            grams ?? this.grams,
            price ?? this.price,
            priceSet ?? this.priceSet,
            productId ?? this.productId,
            currentQuantity ?? this.currentQuantity,
            requiresShipping ?? this.requiresShipping,
            sku ?? this.sku,
            title ?? this.title,
            variantId ?? this.variantId,
            variantTitle ?? this.variantTitle,
            vendor ?? this.vendor,
            name ?? this.name,
            giftCard ?? this.giftCard,
            properties ?? this.properties,
            taxable ?? this.taxable,
            taxLines ?? this.taxLines,
            tipPaymentGateway ?? this.tipPaymentGateway,
            tipPaymentMethod ?? this.tipPaymentMethod,
            totalDiscount ?? this.totalDiscount,
            totalDiscountSet ?? this.totalDiscountSet,
            discountAllocations ?? this.discountAllocations,
            originLocation ?? this.originLocation,
            duties ?? this.duties,
        );
    }
}

export interface LineItemShopifyJSON {
    attributed_staffs: Array<{ [key: string]: any }>;
    id: number;
    quantity: number;
    fulfillable_quantity: number;
    fulfillment_service: string;
    fulfillment_status?: string;
    grams: number;
    price: string;
    price_set: OrderShopifyPriceSetJSON;
    product_id?: number;
    current_quantity: number;
    requires_shipping: boolean;
    sku: string;
    title: string;
    variant_id?: number;
    variant_title?: string;
    vendor: string;
    name: string;
    gift_card: boolean;
    properties: Array<{ [key: string]: any }>;
    taxable: boolean;
    tax_lines: OrderShopifyTaxLineJSON[];
    tip_payment_gateway?: string;
    tip_payment_method?: string;
    total_discount: string;
    total_discount_set: OrderShopifyPriceSetJSON;
    discount_allocations: Array<{ [key: string]: any }>;
    origin_location?: { [key: string]: any };
    duties: Array<{ [key: string]: any }>;
}
