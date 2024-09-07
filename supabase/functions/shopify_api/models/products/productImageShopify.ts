export class ProductImageShopify {
    createdAt: Date;
    id: number;
    position: number;
    productId: number;
    variantIds: number[];
    src: string;
    width: number;
    height: number;
    updatedAt: Date;

    constructor(
        createdAt: Date,
        id: number,
        position: number,
        productId: number,
        variantIds: number[],
        src: string,
        width: number,
        height: number,
        updatedAt: Date,
    ) {
        this.createdAt = createdAt;
        this.id = id;
        this.position = position;
        this.productId = productId;
        this.variantIds = variantIds;
        this.src = src;
        this.width = width;
        this.height = height;
        this.updatedAt = updatedAt;
    }

    static fromJson(json: ProductImageShopifyJSON): ProductImageShopify {
        return new ProductImageShopify(
            new Date(json.created_at),
            json.id,
            json.position,
            json.product_id,
            json.variant_ids,
            json.src,
            json.width,
            json.height,
            new Date(json.updated_at),
        );
    }

    toJson(): ProductImageShopifyJSON {
        return {
            created_at: this.createdAt.toISOString(),
            id: this.id,
            position: this.position,
            product_id: this.productId,
            variant_ids: this.variantIds,
            src: this.src,
            width: this.width,
            height: this.height,
            updated_at: this.updatedAt.toISOString(),
        };
    }

    copyWith({
        createdAt,
        id,
        position,
        productId,
        variantIds,
        src,
        width,
        height,
        updatedAt,
    }: Partial<ProductImageShopify>): ProductImageShopify {
        return new ProductImageShopify(
            createdAt ?? this.createdAt,
            id ?? this.id,
            position ?? this.position,
            productId ?? this.productId,
            variantIds ?? this.variantIds,
            src ?? this.src,
            width ?? this.width,
            height ?? this.height,
            updatedAt ?? this.updatedAt,
        );
    }
}

export interface ProductImageShopifyJSON {
    created_at: string;
    id: number;
    position: number;
    product_id: number;
    variant_ids: number[];
    src: string;
    width: number;
    height: number;
    updated_at: string;
}
