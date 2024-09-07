//* Diese Klasse representiert exakt das Format, wie ein Artikel aus Shopify geladen wird.
//* Viele Attribute wie Bestand, Preis... usw. sind in anderen Klassen

import { ProductImageShopify } from "./productImageShopify.ts";

export enum ProductShopifyStatus {
    Active = "active",
    Archived = "archived",
    Draft = "draft",
  }
  
  export class ProductRawShopify {
    bodyHtml?: string;
    createdAt?: Date;
    handle?: string;
    id: number;
    images: ProductImageShopify[];
    options: ProductOptionShopify[];
    productType: string;
    publishedAt?: Date;
    publishedScope: string;
    status: ProductShopifyStatus;
    tags: string;
    templateSuffix?: string;
    title: string;
    updatedAt?: Date;
    variants: ProductVariantShopify[];
    vendor: string;
  
    constructor(
      bodyHtml: string | undefined,
      createdAt: Date | undefined,
      handle: string | undefined,
      id: number,
      images: ProductImageShopify[],
      options: ProductOptionShopify[],
      productType: string,
      publishedAt: Date | undefined,
      publishedScope: string,
      status: ProductShopifyStatus,
      tags: string,
      templateSuffix: string | undefined,
      title: string,
      updatedAt: Date | undefined,
      variants: ProductVariantShopify[],
      vendor: string
    ) {
      this.bodyHtml = bodyHtml;
      this.createdAt = createdAt;
      this.handle = handle;
      this.id = id;
      this.images = images;
      this.options = options;
      this.productType = productType;
      this.publishedAt = publishedAt;
      this.publishedScope = publishedScope;
      this.status = status;
      this.tags = tags;
      this.templateSuffix = templateSuffix;
      this.title = title;
      this.updatedAt = updatedAt;
      this.variants = variants;
      this.vendor = vendor;
    }
  
    static fromJson(json: ProductRawShopifyJSON): ProductRawShopify {
      return new ProductRawShopify(
        json.body_html,
        json.created_at ? new Date(json.created_at) : undefined,
        json.handle,
        json.id,
        json.images.map(ProductImageShopify.fromJson),
        json.options.map(ProductOptionShopify.fromJson),
        json.product_type,
        json.published_at ? new Date(json.published_at) : undefined,
        json.published_scope,
        ProductRawShopify._statusFromJson(json.status),
        json.tags,
        json.template_suffix,
        json.title,
        json.updated_at ? new Date(json.updated_at) : undefined,
        json.variants.map(ProductVariantShopify.fromJson),
        json.vendor
      );
    }
  
    toJson(): ProductRawShopifyJSON {
      return {
        body_html: this.bodyHtml,
        created_at: this.createdAt?.toISOString(),
        handle: this.handle,
        id: this.id,
        images: this.images.map((image) => image.toJson()),
        options: this.options.map((option) => option.toJson()),
        product_type: this.productType,
        published_at: this.publishedAt?.toISOString(),
        published_scope: this.publishedScope,
        status: ProductRawShopify._statusToJson(this.status),
        tags: this.tags,
        template_suffix: this.templateSuffix,
        title: this.title,
        updated_at: this.updatedAt?.toISOString(),
        variants: this.variants.map((variant) => variant.toJson()),
        vendor: this.vendor,
      };
    }
  
    static _statusFromJson(value: string): ProductShopifyStatus {
      switch (value) {
        case "active":
          return ProductShopifyStatus.Active;
        case "archived":
          return ProductShopifyStatus.Archived;
        case "draft":
          return ProductShopifyStatus.Draft;
        default:
          throw new Error(`Unknown product status: ${value}`);
      }
    }
  
    static _statusToJson(status: ProductShopifyStatus): string {
      return status.toString().split(".").pop()!;
    }
  
    copyWith({
      bodyHtml,
      createdAt,
      handle,
      id,
      images,
      options,
      productType,
      publishedAt,
      publishedScope,
      status,
      tags,
      templateSuffix,
      title,
      updatedAt,
      variants,
      vendor,
    }: Partial<ProductRawShopify>): ProductRawShopify {
      return new ProductRawShopify(
        bodyHtml ?? this.bodyHtml,
        createdAt ?? this.createdAt,
        handle ?? this.handle,
        id ?? this.id,
        images ?? this.images,
        options ?? this.options,
        productType ?? this.productType,
        publishedAt ?? this.publishedAt,
        publishedScope ?? this.publishedScope,
        status ?? this.status,
        tags ?? this.tags,
        templateSuffix ?? this.templateSuffix,
        title ?? this.title,
        updatedAt ?? this.updatedAt,
        variants ?? this.variants,
        vendor ?? this.vendor
      );
    }
  }
  
  export class ProductOptionShopify {
    id: number;
    productId: number;
    name: string;
    position: number;
    values?: string[];
  
    constructor(
      id: number,
      productId: number,
      name: string,
      position: number,
      values?: string[]
    ) {
      this.id = id;
      this.productId = productId;
      this.name = name;
      this.position = position;
      this.values = values;
    }
  
    static fromJson(json: ProductOptionShopifyJSON): ProductOptionShopify {
      return new ProductOptionShopify(
        json.id,
        json.product_id,
        json.name,
        json.position,
        json.values
      );
    }
  
    toJson(): ProductOptionShopifyJSON {
      return {
        id: this.id,
        product_id: this.productId,
        name: this.name,
        position: this.position,
        values: this.values,
      };
    }
  }
  
  export interface ProductRawShopifyJSON {
    body_html?: string;
    created_at?: string;
    handle?: string;
    id: number;
    images: ProductImageShopifyJSON[];
    options: ProductOptionShopifyJSON[];
    product_type: string;
    published_at?: string;
    published_scope: string;
    status: string;
    tags: string;
    template_suffix?: string;
    title: string;
    updated_at?: string;
    variants: ProductVariantShopifyJSON[];
    vendor: string;
  }
  
  export interface ProductOptionShopifyJSON {
    id: number;
    product_id: number;
    name: string;
    position: number;
    values?: string[];
  }