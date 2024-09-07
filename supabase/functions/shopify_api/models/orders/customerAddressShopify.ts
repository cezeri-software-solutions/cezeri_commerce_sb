export class CustomerAddressShopify {
    address1?: string;
    address2?: string;
    city?: string;
    company?: string;
    country?: string;
    countryCode: string;
    firstName?: string;
    lastName?: string;
    latitude?: number;
    longitude?: number;
    name?: string;
    phone?: string;
    province?: string;
    provinceCode?: string;
    zip?: string;

    constructor(
        address1: string | undefined,
        address2: string | undefined,
        city: string | undefined,
        company: string | undefined,
        country: string | undefined,
        countryCode: string,
        firstName: string | undefined,
        lastName: string | undefined,
        latitude: number | undefined,
        longitude: number | undefined,
        name: string | undefined,
        phone: string | undefined,
        province: string | undefined,
        provinceCode: string | undefined,
        zip: string | undefined,
    ) {
        this.address1 = address1;
        this.address2 = address2;
        this.city = city;
        this.company = company;
        this.country = country;
        this.countryCode = countryCode;
        this.firstName = firstName;
        this.lastName = lastName;
        this.latitude = latitude;
        this.longitude = longitude;
        this.name = name;
        this.phone = phone;
        this.province = province;
        this.provinceCode = provinceCode;
        this.zip = zip;
    }

    static fromJson(json: CustomerAddressShopifyJSON): CustomerAddressShopify {
        return new CustomerAddressShopify(
            json.address1,
            json.address2,
            json.city,
            json.company,
            json.country,
            json.country_code,
            json.first_name,
            json.last_name,
            json.latitude,
            json.longitude,
            json.name,
            json.phone,
            json.province,
            json.province_code,
            json.zip,
        );
    }

    toJson(): CustomerAddressShopifyJSON {
        return {
            address1: this.address1,
            address2: this.address2,
            city: this.city,
            company: this.company,
            country: this.country,
            country_code: this.countryCode,
            first_name: this.firstName,
            last_name: this.lastName,
            latitude: this.latitude,
            longitude: this.longitude,
            name: this.name,
            phone: this.phone,
            province: this.province,
            province_code: this.provinceCode,
            zip: this.zip,
        };
    }

    copyWith({
        address1,
        address2,
        city,
        company,
        country,
        countryCode,
        firstName,
        lastName,
        latitude,
        longitude,
        name,
        phone,
        province,
        provinceCode,
        zip,
    }: Partial<CustomerAddressShopify>): CustomerAddressShopify {
        return new CustomerAddressShopify(
            address1 ?? this.address1,
            address2 ?? this.address2,
            city ?? this.city,
            company ?? this.company,
            country ?? this.country,
            countryCode ?? this.countryCode,
            firstName ?? this.firstName,
            lastName ?? this.lastName,
            latitude ?? this.latitude,
            longitude ?? this.longitude,
            name ?? this.name,
            phone ?? this.phone,
            province ?? this.province,
            provinceCode ?? this.provinceCode,
            zip ?? this.zip,
        );
    }
}

export interface CustomerAddressShopifyJSON {
    address1?: string;
    address2?: string;
    city?: string;
    company?: string;
    country?: string;
    country_code: string;
    first_name?: string;
    last_name?: string;
    latitude?: number;
    longitude?: number;
    name?: string;
    phone?: string;
    province?: string;
    province_code?: string;
    zip?: string;
}
