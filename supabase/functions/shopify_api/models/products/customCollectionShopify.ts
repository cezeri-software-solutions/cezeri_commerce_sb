export class CustomCollectionImage {
    attachment?: string;
    src: string;
    alt?: string;
    createdAt: Date;
    width: number;
    height: number;
  
    constructor(
      src: string,
      createdAt: Date,
      width: number,
      height: number,
      attachment?: string,
      alt?: string
    ) {
      this.attachment = attachment;
      this.src = src;
      this.alt = alt;
      this.createdAt = createdAt;
      this.width = width;
      this.height = height;
    }
  
    static fromJson(json: CustomCollectionImageJSON): CustomCollectionImage {
      return new CustomCollectionImage(
        json.src,
        new Date(json.created_at),
        json.width,
        json.height,
        json.attachment,
        json.alt
      );
    }
  
    toJson(): CustomCollectionImageJSON {
      return {
        attachment: this.attachment,
        src: this.src,
        alt: this.alt,
        created_at: this.createdAt.toISOString(),
        width: this.width,
        height: this.height,
      };
    }
  }
  
  export interface CustomCollectionImageJSON {
    attachment?: string;
    src: string;
    alt?: string;
    created_at: string;
    width: number;
    height: number;
  }
  
  export class CustomCollectionShopify {
    bodyHtml: string;
    handle: string;
    image?: CustomCollectionImage;
    id: number;
    published?: boolean;
    publishedAt?: Date;
    publishedScope: string;
    sortOrder: string;
    templateSuffix?: string;
    title: string;
    updatedAt: Date;
  
    constructor(
      bodyHtml: string,
      handle: string,
      id: number,
      publishedScope: string,
      sortOrder: string,
      title: string,
      updatedAt: Date,
      image?: CustomCollectionImage,
      published?: boolean,
      publishedAt?: Date,
      templateSuffix?: string
    ) {
      this.bodyHtml = bodyHtml;
      this.handle = handle;
      this.id = id;
      this.publishedScope = publishedScope;
      this.sortOrder = sortOrder;
      this.title = title;
      this.updatedAt = updatedAt;
      this.image = image;
      this.published = published;
      this.publishedAt = publishedAt;
      this.templateSuffix = templateSuffix;
    }
  
    static fromJson(json: CustomCollectionShopifyJSON): CustomCollectionShopify {
      return new CustomCollectionShopify(
        json.body_html,
        json.handle,
        json.id,
        json.published_scope,
        json.sort_order,
        json.title,
        new Date(json.updated_at),
        json.image ? CustomCollectionImage.fromJson(json.image) : undefined,
        json.published,
        json.published_at ? new Date(json.published_at) : undefined,
        json.template_suffix
      );
    }
  
    toJson(): CustomCollectionShopifyJSON {
      return {
        body_html: this.bodyHtml,
        handle: this.handle,
        id: this.id,
        published_scope: this.publishedScope,
        sort_order: this.sortOrder,
        title: this.title,
        updated_at: this.updatedAt.toISOString(),
        image: this.image ? this.image.toJson() : undefined,
        published: this.published,
        published_at: this.publishedAt?.toISOString(),
        template_suffix: this.templateSuffix,
      };
    }
  }
  
  export interface CustomCollectionShopifyJSON {
    body_html: string;
    handle: string;
    image?: CustomCollectionImageJSON;
    id: number;
    published?: boolean;
    published_at?: string;
    published_scope: string;
    sort_order: string;
    template_suffix?: string;
    title: string;
    updated_at: string;
  }