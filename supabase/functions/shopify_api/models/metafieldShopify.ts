// deno-lint-ignore-file

export enum MetafieldType {
    Unknown = "unknown",
    ProductMetaTitle = "productMetaTitle",
    ProductMetaDescription = "productMetaDescription",
}
export class MetafieldShopify {
    createdAt: Date;
    description?: string;
    id: number;
    key: string;
    namespace: string;
    ownerId: number;
    ownerResource: string;
    updatedAt: Date;
    value: string;
    type: any; // dynamischer Typ für das Feld 'type'
    metafieldType: MetafieldType;

    constructor(
        createdAt: Date,
        description: string | undefined,
        id: number,
        key: string,
        namespace: string,
        ownerId: number,
        ownerResource: string,
        updatedAt: Date,
        value: string,
        type: any,
    ) {
        this.createdAt = createdAt;
        this.description = description;
        this.id = id;
        this.key = key;
        this.namespace = namespace;
        this.ownerId = ownerId;
        this.ownerResource = ownerResource;
        this.updatedAt = updatedAt;
        this.value = value;
        this.type = type;
        this.metafieldType = MetafieldShopify._getMetafieldType(
            key,
            ownerResource,
        );
    }

    static fromJson(json: MetafieldShopifyJSON): MetafieldShopify {
        return new MetafieldShopify(
            new Date(json.created_at),
            json.description,
            json.id,
            json.key,
            json.namespace,
            json.owner_id,
            json.owner_resource,
            new Date(json.updated_at),
            json.value,
            json.type,
        );
    }

    toJson(): MetafieldShopifyJSON {
        return {
            created_at: this.createdAt.toISOString(),
            description: this.description,
            id: this.id,
            key: this.key,
            namespace: this.namespace,
            owner_id: this.ownerId,
            owner_resource: this.ownerResource,
            updated_at: this.updatedAt.toISOString(),
            value: this.value,
            type: this.type,
        };
    }

    static _getMetafieldType(
        key: string,
        ownerResource: string,
    ): MetafieldType {
        if (key === "product") {
            switch (ownerResource) {
                case "title_tag":
                    return MetafieldType.ProductMetaTitle;
                case "description_tag":
                    return MetafieldType.ProductMetaDescription;
                default:
                    return MetafieldType.Unknown;
            }
        }
        return MetafieldType.Unknown;
    }

    copyWith({
        createdAt,
        description,
        id,
        key,
        namespace,
        ownerId,
        ownerResource,
        updatedAt,
        value,
        type,
    }: Partial<MetafieldShopify>): MetafieldShopify {
        return new MetafieldShopify(
            createdAt ?? this.createdAt,
            description ?? this.description,
            id ?? this.id,
            key ?? this.key,
            namespace ?? this.namespace,
            ownerId ?? this.ownerId,
            ownerResource ?? this.ownerResource,
            updatedAt ?? this.updatedAt,
            value ?? this.value,
            type ?? this.type,
        );
    }
}

export interface MetafieldShopifyJSON {
    created_at: string;
    description?: string;
    id: number;
    key: string;
    namespace: string;
    owner_id: number;
    owner_resource: string;
    updated_at: string;
    value: string;
    type: any;
}
