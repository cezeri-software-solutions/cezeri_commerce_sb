export class ProductVariantShopify {
    barcode?: string;
    compareAtPrice?: string;
    createdAt: Date;
    fulfillmentService: string;
    grams: number;
    id: number;
    imageId?: number;
    inventoryItemId: number;
    inventoryManagement: string;
    inventoryPolicy: string;
    inventoryQuantity: number;
    price: string;
    productId: number;
    sku: string;
    taxable: boolean;
    taxCode?: string;
    title: string;
    updatedAt: Date;
    weight: number;
    weightUnit: string;

    constructor(
        barcode: string | undefined,
        compareAtPrice: string | undefined,
        createdAt: Date,
        fulfillmentService: string,
        grams: number,
        id: number,
        imageId: number | undefined,
        inventoryItemId: number,
        inventoryManagement: string,
        inventoryPolicy: string,
        inventoryQuantity: number,
        price: string,
        productId: number,
        sku: string,
        taxable: boolean,
        taxCode: string | undefined,
        title: string,
        updatedAt: Date,
        weight: number,
        weightUnit: string,
    ) {
        this.barcode = barcode;
        this.compareAtPrice = compareAtPrice;
        this.createdAt = createdAt;
        this.fulfillmentService = fulfillmentService;
        this.grams = grams;
        this.id = id;
        this.imageId = imageId;
        this.inventoryItemId = inventoryItemId;
        this.inventoryManagement = inventoryManagement;
        this.inventoryPolicy = inventoryPolicy;
        this.inventoryQuantity = inventoryQuantity;
        this.price = price;
        this.productId = productId;
        this.sku = sku;
        this.taxable = taxable;
        this.taxCode = taxCode;
        this.title = title;
        this.updatedAt = updatedAt;
        this.weight = weight;
        this.weightUnit = weightUnit;
    }

    static fromJson(json: ProductVariantShopifyJSON): ProductVariantShopify {
        return new ProductVariantShopify(
            json.barcode,
            json.compare_at_price,
            new Date(json.created_at),
            json.fulfillment_service,
            json.grams,
            json.id,
            json.image_id,
            json.inventory_item_id,
            json.inventory_management,
            json.inventory_policy,
            json.inventory_quantity,
            json.price,
            json.product_id,
            json.sku,
            json.taxable,
            json.tax_code,
            json.title,
            new Date(json.updated_at),
            json.weight,
            json.weight_unit,
        );
    }

    toJson(): ProductVariantShopifyJSON {
        return {
            barcode: this.barcode,
            compare_at_price: this.compareAtPrice,
            created_at: this.createdAt.toISOString(),
            fulfillment_service: this.fulfillmentService,
            grams: this.grams,
            id: this.id,
            image_id: this.imageId,
            inventory_item_id: this.inventoryItemId,
            inventory_management: this.inventoryManagement,
            inventory_policy: this.inventoryPolicy,
            inventory_quantity: this.inventoryQuantity,
            price: this.price,
            product_id: this.productId,
            sku: this.sku,
            taxable: this.taxable,
            tax_code: this.taxCode,
            title: this.title,
            updated_at: this.updatedAt.toISOString(),
            weight: this.weight,
            weight_unit: this.weightUnit,
        };
    }

    copyWith({
        barcode,
        compareAtPrice,
        createdAt,
        fulfillmentService,
        grams,
        id,
        imageId,
        inventoryItemId,
        inventoryManagement,
        inventoryPolicy,
        inventoryQuantity,
        price,
        productId,
        sku,
        taxable,
        taxCode,
        title,
        updatedAt,
        weight,
        weightUnit,
    }: Partial<ProductVariantShopify>): ProductVariantShopify {
        return new ProductVariantShopify(
            barcode ?? this.barcode,
            compareAtPrice ?? this.compareAtPrice,
            createdAt ?? this.createdAt,
            fulfillmentService ?? this.fulfillmentService,
            grams ?? this.grams,
            id ?? this.id,
            imageId ?? this.imageId,
            inventoryItemId ?? this.inventoryItemId,
            inventoryManagement ?? this.inventoryManagement,
            inventoryPolicy ?? this.inventoryPolicy,
            inventoryQuantity ?? this.inventoryQuantity,
            price ?? this.price,
            productId ?? this.productId,
            sku ?? this.sku,
            taxable ?? this.taxable,
            taxCode ?? this.taxCode,
            title ?? this.title,
            updatedAt ?? this.updatedAt,
            weight ?? this.weight,
            weightUnit ?? this.weightUnit,
        );
    }
}

export interface ProductVariantShopifyJSON {
    barcode?: string;
    compare_at_price?: string;
    created_at: string;
    fulfillment_service: string;
    grams: number;
    id: number;
    image_id?: number;
    inventory_item_id: number;
    inventory_management: string;
    inventory_policy: string;
    inventory_quantity: number;
    price: string;
    product_id: number;
    sku: string;
    taxable: boolean;
    tax_code?: string;
    title: string;
    updated_at: string;
    weight: number;
    weight_unit: string;
}
