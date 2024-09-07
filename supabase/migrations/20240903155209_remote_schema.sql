-- include all function files
\i functions/dashboard/get_sales_per_day_per_marketplace.sql
\i functions/products/compare_and_update_set_product_stock.sql


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."client_rights" AS ENUM (
    'level3',
    'level2',
    'level1'
);


ALTER TYPE "public"."client_rights" OWNER TO "postgres";


CREATE TYPE "public"."client_type" AS ENUM (
    'employee',
    'user',
    'admin'
);


ALTER TYPE "public"."client_type" OWNER TO "postgres";


CREATE TYPE "public"."clientrights" AS ENUM (
    'level3',
    'level2',
    'level1'
);


ALTER TYPE "public"."clientrights" OWNER TO "postgres";


CREATE TYPE "public"."clienttype" AS ENUM (
    'employee',
    'user',
    'admin'
);


ALTER TYPE "public"."clienttype" OWNER TO "postgres";


CREATE TYPE "public"."gender" AS ENUM (
    'empty',
    'male',
    'female'
);


ALTER TYPE "public"."gender" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_and_insert_product_stats_count"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN SELECT "settingsId" FROM d_main_settings LOOP
    INSERT INTO stat_products_count (
      owner_id,
      total_warehouse_stock,
      total_available_stock,
      total_wholesale_price,
      total_net_price,
      total_gross_price,
      total_profit,
      creation_date
    )
    SELECT
      rec."settingsId" AS owner_id,
      SUM("warehouseStock") AS total_warehouse_stock,
      SUM("availableStock") AS total_available_stock,
      SUM("warehouseStock" * "wholesalePrice") AS total_wholesale_price,
      SUM("warehouseStock" * "netPrice") AS total_net_price,
      SUM("warehouseStock" * "grossPrice") AS total_gross_price,
      SUM("warehouseStock" * ("netPrice" - "wholesalePrice")) AS total_profit,
      now() AS creation_date
    FROM
      d_products
    WHERE
      d_products."ownerId" = rec."settingsId"
      AND d_products."isSetArticle" = FALSE 
      AND d_products."isActive" = TRUE;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."calculate_and_insert_product_stats_count"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."d_products" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "ownerId" character varying,
    "articleNumber" character varying,
    "supplierArticleNumber" character varying,
    "supplierNumber" character varying,
    "supplier" character varying,
    "sku" character varying,
    "ean" character varying,
    "name" character varying,
    "listOfName" "jsonb",
    "tax" "jsonb",
    "imageUrls" "jsonb",
    "isActive" boolean,
    "ordered" integer,
    "brandName" character varying,
    "unity" character varying,
    "unitPrice" double precision,
    "width" double precision,
    "height" double precision,
    "depth" double precision,
    "weight" double precision,
    "netPrice" double precision,
    "grossPrice" double precision,
    "wholesalePrice" double precision,
    "recommendedRetailPrice" double precision,
    "haveVariants" boolean,
    "isSetArticle" boolean,
    "isOutlet" boolean,
    "listOfIsPartOfSetIds" "jsonb",
    "listOfProductIdWithQuantity" "jsonb",
    "isSetSelfQuantityManaged" boolean,
    "manufacturerNumber" character varying,
    "manufacturer" character varying,
    "warehouseStock" integer,
    "availableStock" integer,
    "minimumStock" integer,
    "isUnderMinimumStock" boolean,
    "minimumReorderQuantity" integer,
    "packagingUnitOnReorder" integer,
    "description" character varying,
    "listOfDescription" "jsonb",
    "descriptionShort" character varying,
    "listOfDescriptionShort" "jsonb",
    "metaTitle" character varying,
    "listOfMetaTitle" "jsonb",
    "metaDescription" character varying,
    "listOfMetaDescription" "jsonb",
    "listOfProductImages" "jsonb",
    "listOfSetProducts" "jsonb",
    "productMarketplaces" "jsonb",
    "creationDate" timestamp without time zone DEFAULT "now"(),
    "lastEditingDate" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."d_products" OWNER TO "postgres";


ALTER FUNCTION "public"."compare_and_update_set_product_stock"("owner_id_input" "text", "product_id_input" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_main_settings"("main_settings_json" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_id UUID := main_settings_json->>'id'; -- Generiere eine UUID im Client, oder entferne diese Zeile, falls die ID automatisch generiert werden soll.
  tax_element JSONB;
BEGIN  
  -- Insert new main settings
  INSERT INTO public.main_settings (
    id, logo_url, offer_praefix, appointment_praefix, delivery_note_praefix, invoice_praefix, credit_praefix, 
    currency, sms_message, offer_document_text, appointment_document_text, delivery_note_document_text, 
    invoice_document_text, credit_document_text, next_offer_number, next_appointment_number, 
    next_delivery_note_number, next_invoice_number, next_branch_number, next_customer_number, 
    next_supplier_number, next_reorder_number, term_of_payment, count_employees, count_branches, 
    limitation_number_of_employees, limitation_number_of_branches, is_small_business, is_main_settings
  ) VALUES (
    v_id, main_settings_json->>'logo_url', main_settings_json->>'offer_praefix', 
    main_settings_json->>'appointment_praefix', main_settings_json->>'delivery_note_praefix', 
    main_settings_json->>'invoice_praefix', main_settings_json->>'credit_praefix', main_settings_json->>'currency', 
    main_settings_json->>'sms_message', main_settings_json->>'offer_document_text', 
    main_settings_json->>'appointment_document_text', main_settings_json->>'delivery_note_document_text', 
    main_settings_json->>'invoice_document_text', main_settings_json->>'credit_document_text', 
    (main_settings_json->>'next_offer_number')::INT, (main_settings_json->>'next_appointment_number')::INT, 
    (main_settings_json->>'next_delivery_note_number')::INT, (main_settings_json->>'next_invoice_number')::INT, 
    (main_settings_json->>'next_branch_number')::INT, (main_settings_json->>'next_customer_number')::INT, 
    (main_settings_json->>'next_supplier_number')::INT, (main_settings_json->>'next_reorder_number')::INT, 
    (main_settings_json->>'term_of_payment')::INT, (main_settings_json->>'count_employees')::INT, 
    (main_settings_json->>'count_branches')::INT, (main_settings_json->>'limitation_number_of_employees')::INT, 
    (main_settings_json->>'limitation_number_of_branches')::INT, (main_settings_json->>'is_small_business')::BOOLEAN, 
    (main_settings_json->>'is_main_settings')::BOOLEAN
  );

  -- Loop through each tax element in the JSON array 'taxes'
  FOR tax_element IN SELECT * FROM jsonb_array_elements(main_settings_json->'taxes')
  LOOP
    -- Insert new tax information
    INSERT INTO public.taxes (id, tax_name, tax_rate, country_id, reference_id, is_default)
    VALUES (
      tax_element->>'id',
      tax_element->>'tax_name',
      (tax_element->>'tax_rate')::INT,
      (tax_element->'country')->>'id',
      v_id,
      (tax_element->>'is_default')::BOOLEAN
    );
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."create_main_settings"("main_settings_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_main_settings"("main_settings_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Zuerst die zugehörigen Steuerelemente (taxes) löschen
    DELETE FROM public.taxes
    WHERE reference_id = main_settings_id;

    -- Anschließend die Haupt-Einstellungen löschen
    DELETE FROM public.main_settings
    WHERE id = main_settings_id;
END;
$$;


ALTER FUNCTION "public"."delete_main_settings"("main_settings_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_appointments" (
    "id" "text" NOT NULL,
    "receiptId" "text",
    "offerId" integer,
    "offerNumberAsString" "text",
    "appointmentId" integer,
    "appointmentNumberAsString" "text",
    "deliveryNoteId" integer,
    "deliveryNoteNumberAsString" "text",
    "listOfDeliveryNoteIds" "jsonb",
    "invoiceId" integer,
    "invoiceNumberAsString" "text",
    "creditId" integer,
    "creditNumberAsString" "text",
    "marketplaceId" "text",
    "receiptMarketplaceId" bigint,
    "receiptMarketplaceReference" "text",
    "paymentMethod" "jsonb",
    "commentInternal" "text",
    "commentGlobal" "text",
    "currency" "text",
    "receiptDocumentText" "text",
    "uidNumber" "text",
    "searchField" "text",
    "customerId" "text",
    "receiptCustomer" "jsonb",
    "addressInvoice" "jsonb",
    "addressDelivery" "jsonb",
    "receiptTyp" "text",
    "offerStatus" "text",
    "appointmentStatus" "text",
    "paymentStatus" "text",
    "tax" "jsonb",
    "isSmallBusiness" boolean,
    "isPicked" boolean,
    "termOfPayment" integer,
    "weight" double precision,
    "totalGross" double precision,
    "totalNet" double precision,
    "totalTax" double precision,
    "subTotalNet" double precision,
    "subTotalTax" double precision,
    "subTotalGross" double precision,
    "totalPaidGross" double precision,
    "totalPaidNet" double precision,
    "totalPaidTax" double precision,
    "totalShippingGross" double precision,
    "totalShippingNet" double precision,
    "totalShippingTax" double precision,
    "totalWrappingGross" double precision,
    "totalWrappingNet" double precision,
    "totalWrappingTax" double precision,
    "discountGross" double precision,
    "discountNet" double precision,
    "discountTax" double precision,
    "discountPercent" double precision,
    "discountPercentAmountGross" double precision,
    "discountPercentAmountNet" double precision,
    "discountPercentAmountTax" double precision,
    "posDiscountPercentAmountGross" double precision,
    "posDiscountPercentAmountNet" double precision,
    "posDiscountPercentAmountTax" double precision,
    "additionalAmountNet" double precision,
    "additionalAmountTax" double precision,
    "additionalAmountGross" double precision,
    "profit" double precision,
    "profitExclShipping" double precision,
    "profitExclWrapping" double precision,
    "profitExclShippingAndWrapping" double precision,
    "bankDetails" "jsonb",
    "listOfPayments" "jsonb",
    "listOfReceiptProduct" "jsonb",
    "listOfParcelTracking" "jsonb",
    "receiptCarrier" "jsonb",
    "receiptMarketplace" "jsonb",
    "creationDateMarektplace" timestamp with time zone,
    "packagingBox" "jsonb",
    "creationDate" timestamp without time zone,
    "creationDateInt" bigint,
    "lastEditingDate" timestamp without time zone,
    "ownerId" "text",
    "isDeliveryBlocked" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."d_appointments" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_receipts_between_dates"("owner_id" "text", "receipt_type" "text", "start_date" "date", "end_date" "date") RETURNS SETOF "public"."d_appointments"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF receipt_type = 'offer' THEN
        RETURN QUERY
        SELECT *
        FROM d_offers
        WHERE 
            "ownerId" = owner_id AND
            "creationDate" >= start_date AND
            "creationDate" < end_date
        ORDER BY "offerId" asc;
    ELSIF receipt_type = 'appointment' THEN
        RETURN QUERY
        SELECT *
        FROM d_appointments
        WHERE 
            "ownerId" = owner_id AND
            "creationDate" >= start_date AND
            "creationDate" < end_date
         ORDER BY "appointmentId" asc;
    ELSIF receipt_type = 'deliveryNote' THEN
        RETURN QUERY
        SELECT *
        FROM d_delivery_notes
        WHERE 
            "ownerId" = owner_id AND
            "creationDate" >= start_date AND
            "creationDate" < end_date
         ORDER BY "deliveryNoteId" asc;
    ELSIF receipt_type = 'invoice' OR receipt_type = 'credit' THEN
        RETURN QUERY
        SELECT *
        FROM d_invoices
        WHERE 
            "ownerId" = owner_id AND
            "creationDate" >= start_date AND
            "creationDate" < end_date
         ORDER BY "invoiceId" asc;
    ELSE
        RETURN QUERY
        SELECT NULL::your_table_name
        WHERE FALSE;
    END IF;
END;
$$;


ALTER FUNCTION "public"."get_all_receipts_between_dates"("owner_id" "text", "receipt_type" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_receipts_by_customer_id"("owner_id" "text", "customer_id" "text") RETURNS SETOF "public"."d_appointments"
    LANGUAGE "plpgsql"
    AS $$
begin
  return query
  select * from d_offers
  where d_offers."customerId" = customer_id and d_offers."ownerId" = owner_id
  union
  select * from d_appointments
  where d_appointments."customerId" = customer_id and d_appointments."ownerId" = owner_id
  union
  select * from d_delivery_notes
  where d_delivery_notes."customerId" = customer_id and d_delivery_notes."ownerId" = owner_id
  union
  select * from d_invoices
  where d_invoices."customerId" = customer_id and d_invoices."ownerId" = owner_id;
end;
$$;


ALTER FUNCTION "public"."get_all_receipts_by_customer_id"("owner_id" "text", "customer_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_app_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("product_id" "text", "month" timestamp without time zone, "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        product_data.product_id,
        p_end_date::TIMESTAMP AS month,
        SUM(product_data.total_quantity)::INTEGER AS total_quantity,
        SUM(product_data.total_revenue) AS total_revenue
    FROM (
        SELECT
            jsonb_array_elements(da."listOfReceiptProduct") AS product
        FROM
            d_appointments da
        WHERE
            da."ownerId" = p_owner_id
            AND da."appointmentStatus" IN ('open', 'partiallyCompleted')
            AND da."creationDate" BETWEEN p_start_date AND p_end_date
    ) AS appointments,
    LATERAL (
        SELECT
            product->>'productId' AS product_id,
            ((product->>'quantity')::INTEGER - (product->>'shippedQuantity')::INTEGER) AS total_quantity,
            ((product->>'unitPriceNet')::DOUBLE PRECISION * ((product->>'quantity')::INTEGER - (product->>'shippedQuantity')::INTEGER)) AS total_revenue
        WHERE
            (product->>'isFromDatabase')::BOOLEAN = true
    ) AS product_data
    GROUP BY
        product_data.product_id;
END;
$$;


ALTER FUNCTION "public"."get_app_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_app_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("product_id" "text", "month" timestamp without time zone, "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        product_data.product_id,
        p_end_date::TIMESTAMP AS month,
        SUM(product_data.total_quantity)::INTEGER AS total_quantity,
        SUM(product_data.total_revenue) AS total_revenue
    FROM (
        SELECT
            jsonb_array_elements(da."listOfReceiptProduct") AS product
        FROM
            d_appointments da
        WHERE
            da."ownerId" = p_owner_id
            AND da."appointmentStatus" IN ('open', 'partiallyCompleted')
            AND da."creationDate" BETWEEN p_start_date AND p_end_date
    ) AS appointments,
    LATERAL (
        SELECT
            product->>'productId' AS product_id,
            ((product->>'quantity')::INTEGER - (product->>'shippedQuantity')::INTEGER) AS total_quantity,
            ((product->>'unitPriceNet')::DOUBLE PRECISION * ((product->>'quantity')::INTEGER - (product->>'shippedQuantity')::INTEGER)) AS total_revenue
        WHERE
            product->>'productId' = ANY(p_product_ids)
            AND (product->>'isFromDatabase')::BOOLEAN = true
    ) AS product_data
    GROUP BY
        product_data.product_id;
END;
$$;


ALTER FUNCTION "public"."get_app_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_customers" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "customerNumber" integer,
    "customerMarketplace" "jsonb",
    "company" "text",
    "firstName" "text",
    "lastName" "text",
    "email" "text",
    "gender" "text",
    "birthday" "text",
    "phone" "text",
    "phoneMobile" "text",
    "listOfAddress" "jsonb",
    "customerInvoiceType" "text",
    "uidNumber" "text",
    "taxNumber" "text",
    "tax" "jsonb",
    "creationDate" timestamp with time zone DEFAULT "now"(),
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "name" "text" DEFAULT ''::"text",
    "ownerId" "text" DEFAULT ''::"text"
);


ALTER TABLE "public"."d_customers" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_customers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) RETURNS SETOF "public"."d_customers"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    start_index INT;
    end_index INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate start and end indices for pagination
    start_index := (current_page - 1) * items_per_page;
    end_index := start_index + items_per_page - 1;

    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_customers
    WHERE "ownerId" = owner_id
    AND (
        lower("customerNumber"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("firstName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("lastName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(company) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(email) LIKE '%' || array_to_string(st, '%') || '%'
    )
    ORDER BY "customerNumber" desc
    OFFSET start_index LIMIT items_per_page;
END;
$$;


ALTER FUNCTION "public"."get_customers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_customers_count_by_search_text"("owner_id" "text", "search_text" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    result_count INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_customers
    WHERE "ownerId" = owner_id
    AND (
        lower("customerNumber"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("firstName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("lastName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(company) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(email) LIKE '%' || array_to_string(st, '%') || '%'
    );

    RETURN result_count;
END;
$$;


ALTER FUNCTION "public"."get_customers_count_by_search_text"("owner_id" "text", "search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_d_products_count"("owner_id" "text", "only_active" boolean) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF only_active THEN
    RETURN (
      SELECT COUNT(*)
      FROM d_products
      WHERE "ownerId" = owner_id AND "isActive" = true
    );
  ELSE
    RETURN (
      SELECT COUNT(*)
      FROM d_products
      WHERE "ownerId" = owner_id
    );
  END IF;
END;
$$;


ALTER FUNCTION "public"."get_d_products_count"("owner_id" "text", "only_active" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_d_products_count_by_search_text"("owner_id" "text", "search_text" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    result_count INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_products
    WHERE "ownerId" = owner_id
    AND (
        lower(name) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(ean) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(supplier) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("articleNumber") LIKE '%' || array_to_string(st, '%') || '%'
    );

    RETURN result_count;
END;
$$;


ALTER FUNCTION "public"."get_d_products_count_by_search_text"("owner_id" "text", "search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_d_receipts_count"("owner_id" "text", "receipt_type" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF receipt_type = 'offer' THEN
    RETURN (
      SELECT COUNT(*)
      FROM d_offers
      WHERE "ownerId" = owner_id
    );
  ELSEIF receipt_type = 'appointment' THEN
    RETURN (
      SELECT COUNT(*)
      FROM d_appointments
      WHERE "ownerId" = owner_id
    );
   ELSEIF receipt_type = 'deliveryNote' THEN
    RETURN (
      SELECT COUNT(*)
      FROM d_delivery_notes
      WHERE "ownerId" = owner_id
    );
   ELSEIF receipt_type = 'invoice' OR receipt_type = 'credit' THEN
    RETURN (
      SELECT COUNT(*)
      FROM d_invoices
      WHERE "ownerId" = owner_id
    );
  END IF;
END;
$$;


ALTER FUNCTION "public"."get_d_receipts_count"("owner_id" "text", "receipt_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    result_count INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    IF receipt_type = 'offer' THEN
    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_offers
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );
    END IF;

    IF receipt_type = 'appointment' THEN
    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );
    END IF;

    IF receipt_type = 'deliveryNote' THEN
    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );
    END IF;

    IF receipt_type = 'invoice' OR receipt_type = 'credit' THEN
    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );
    END IF;
    RETURN result_count;
END;
$$;


ALTER FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    result_count INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    IF receipt_type = 'offer' AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_offers
    WHERE "ownerId" = owner_id AND "offerStatus" = 'open'
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    ELSIF receipt_type = 'offer' AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_offers
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    END IF;

    IF receipt_type = 'appointment' AND tab_index = '0' THEN

    SELECT COUNT(*) INTO result_count FROM d_appointments
    WHERE "ownerId" = owner_id AND ("appointmentStatus" = 'open' OR "appointmentStatus" = 'partiallyCompleted')
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    ELSIF receipt_type = 'appointment' AND tab_index = '1' THEN

    SELECT COUNT(*) INTO result_count FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    END IF;

    IF receipt_type = 'deliveryNote' AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_delivery_notes
    WHERE "ownerId" = owner_id AND "invoiceId" = 0
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    ELSIF receipt_type = 'deliveryNote' AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_delivery_notes
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    END IF;

    IF (receipt_type = 'invoice' OR receipt_type = 'credit') AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_invoices
    WHERE "ownerId" = owner_id AND ("paymentStatus" = 'open' OR "paymentStatus" = 'partiallyPaid')
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    ELSIF (receipt_type = 'invoice' OR receipt_type = 'credit') AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    SELECT COUNT(*) INTO result_count FROM d_invoices
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    );

    END IF;
    RETURN result_count;
END;
$$;


ALTER FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_product_sales_and_stock_diff"("owner_id" "text", "start_date" "date", "end_date" "date") RETURNS TABLE("id" "text", "name" "text", "articlenumber" "text", "warehousestock" integer, "availablestock" integer, "stock_difference" integer, "sales_quantity" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH sales_data AS (
        SELECT
            product_id,
            total_quantity
        FROM
            get_app_products_sales_data_between_dates(owner_id, start_date, end_date)
    ),
    product_differences AS (
        SELECT
            p.id,
            p."warehouseStock" - p."availableStock" AS stock_difference
        FROM
            d_products p
    )
    SELECT
        p.id::TEXT,
        p.name::TEXT,
        p."articleNumber"::TEXT,
        p."warehouseStock",
        p."availableStock",
        pd.stock_difference,
        sd.total_quantity AS sales_quantity
    FROM
        product_differences pd
    LEFT JOIN
        sales_data sd
    ON
        pd.id = sd.product_id
    JOIN
        d_products p
    ON
        pd.id = p.id
    WHERE
        pd.stock_difference <> COALESCE(sd.total_quantity, 0)
    OR
        (pd.stock_difference <> 0 AND sd.product_id IS NULL)
    ORDER BY
        p.name;
END;
$$;


ALTER FUNCTION "public"."get_product_sales_and_stock_diff"("owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_products_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) RETURNS SETOF "public"."d_products"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    start_index INT;
    end_index INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate start and end indices for pagination
    start_index := (current_page - 1) * items_per_page;
    end_index := start_index + items_per_page - 1;

    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_products
    WHERE "ownerId" = owner_id
    AND (
        lower(name) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(ean) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(supplier) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("articleNumber") LIKE '%' || array_to_string(st, '%') || '%'
    )
    ORDER BY name
    OFFSET start_index LIMIT items_per_page;
END;
$$;


ALTER FUNCTION "public"."get_products_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("product_id" "text", "month" timestamp without time zone, "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        sp.product_id,
        p_end_date::TIMESTAMP AS month,  -- Using end date as the timestamp value
        SUM(sp.quantity)::INTEGER AS total_quantity,
        SUM(sp.total_price_net) AS total_revenue
    FROM
        stat_products sp
    WHERE
        sp.owner_id = p_owner_id
        AND sp.creation_date BETWEEN p_start_date AND p_end_date
    GROUP BY
        sp.product_id;
END;
$$;


ALTER FUNCTION "public"."get_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_products_sales_data_between_dates"("p_product_id" "text", "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("product_id" "text", "month" "text", "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        sp.product_id,
        'ALL' AS month,  -- Placeholder, since month is not relevant
        SUM(sp.quantity)::INTEGER AS total_quantity,
        SUM(sp.total_price_net) AS total_revenue
    FROM
        stat_products sp
    WHERE
        sp.product_id = p_product_id
        AND sp.owner_id = p_owner_id
        AND sp.creation_date BETWEEN p_start_date AND p_end_date
    GROUP BY
        sp.product_id;
END;
$$;


ALTER FUNCTION "public"."get_products_sales_data_between_dates"("p_product_id" "text", "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") RETURNS TABLE("product_id" "text", "month" timestamp without time zone, "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        sp.product_id,
        p_end_date::TIMESTAMP AS month,  -- Using end date as the timestamp value
        SUM(sp.quantity)::INTEGER AS total_quantity,
        SUM(sp.total_price_net) AS total_revenue
    FROM
        stat_products sp
    WHERE
        sp.product_id = ANY(p_product_ids)
        AND sp.owner_id = p_owner_id
        AND sp.creation_date BETWEEN p_start_date AND p_end_date
    GROUP BY
        sp.product_id;
END;
$$;


ALTER FUNCTION "public"."get_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_products_sales_data_of_last_13_months"("p_product_id" "text", "p_owner_id" "text") RETURNS TABLE("product_id" "text", "month" "text", "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH sales_data AS (
        SELECT
            sp.product_id,
            DATE_TRUNC('month', sp.creation_date) AS month,
            SUM(sp.quantity)::INTEGER AS total_quantity,
            SUM(sp.total_price_net) AS total_revenue
        FROM
            stat_products sp
        WHERE
            sp.product_id = p_product_id
            AND sp.owner_id = p_owner_id
            AND sp.creation_date >= (CURRENT_DATE - INTERVAL '13 months')
        GROUP BY
            sp.product_id, month
    ),
    all_months AS (
        SELECT
            generate_series(
                DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months',
                DATE_TRUNC('month', CURRENT_DATE),
                '1 month'
            ) AS month
    )
    SELECT
        COALESCE(sd.product_id, p_product_id) AS product_id,
        TO_CHAR(am.month, 'YYYYMM') AS month,
        COALESCE(sd.total_quantity, 0) AS total_quantity,
        COALESCE(sd.total_revenue, 0) AS total_revenue
    FROM
        all_months am
    LEFT JOIN
        sales_data sd ON am.month = sd.month
    ORDER BY
        am.month;
END;
$$;


ALTER FUNCTION "public"."get_products_sales_data_of_last_13_months"("p_product_id" "text", "p_owner_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) RETURNS SETOF "public"."d_appointments"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    start_index INT;
    end_index INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate start and end indices for pagination
    start_index := (current_page - 1) * items_per_page;
    end_index := start_index + items_per_page - 1;

    IF receipt_type = 'offer' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_offers
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;
    END IF;

    IF receipt_type = 'appointment' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;
    END IF;

    IF receipt_type = 'deliveryNote' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_delivery_notes
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;
    END IF;

    IF receipt_type = 'invoice' OR receipt_type = 'credit' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;
    END IF;
END;
$$;


ALTER FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) RETURNS SETOF "public"."d_appointments"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    start_index INT;
    end_index INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate start and end indices for pagination
    start_index := (current_page - 1) * items_per_page;
    end_index := start_index + items_per_page - 1;

    IF receipt_type = 'offer' AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_offers
    WHERE "ownerId" = owner_id AND "offerStatus" = 'open'
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    ELSIF receipt_type = 'offer' AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_offers
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    END IF;

    IF receipt_type = 'appointment' AND tab_index = '0' THEN

    RETURN QUERY
    SELECT * FROM d_appointments
    WHERE "ownerId" = owner_id AND ("appointmentStatus" = 'open' OR "appointmentStatus" = 'partiallyCompleted')
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "isDeliveryBlocked" asc, "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    ELSIF receipt_type = 'appointment' AND tab_index = '1' THEN

    RETURN QUERY
    SELECT * FROM d_appointments
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    END IF;

    IF receipt_type = 'deliveryNote' AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_delivery_notes
    WHERE "ownerId" = owner_id AND "invoiceId" = 0
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    ELSIF receipt_type = 'deliveryNote' AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_delivery_notes
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    END IF;

    IF (receipt_type = 'invoice' OR receipt_type = 'credit') AND tab_index = '0' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_invoices
    WHERE "ownerId" = owner_id AND ("paymentStatus" = 'open' OR "paymentStatus" = 'partiallyPaid')
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    ELSIF (receipt_type = 'invoice' OR receipt_type = 'credit') AND tab_index = '1' THEN
    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_invoices
    WHERE "ownerId" = owner_id
    AND (
        lower("offerNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("appointmentNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("deliveryNoteNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("invoiceNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("creditNumberAsString") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceId"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptMarketplaceReference") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'company') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("receiptCustomer"->>'id'::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressInvoice"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'companyName') LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("addressDelivery"->>'name') LIKE '%' || array_to_string(st, '%') || '%' OR
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements("listOfReceiptProduct") as p
            WHERE lower(p->>'name') LIKE '%' || array_to_string(st, '%') || '%'
            OR lower(p->>'articleNumber') LIKE '%' || array_to_string(st, '%') || '%'
        )
    )
    ORDER BY "creationDate" desc
    OFFSET start_index LIMIT items_per_page;

    END IF;
END;
$$;


ALTER FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_receipts_with_same_receipt_id"("owner_id" "text", "receipt_id" "text") RETURNS SETOF "public"."d_appointments"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    
    SELECT *
    FROM d_offers
    WHERE "ownerId" = owner_id AND "receiptId" = receipt_id
    
    UNION ALL
    
    SELECT *
    FROM d_appointments
    WHERE "ownerId" = owner_id AND "receiptId" = receipt_id
    
    UNION ALL
    
    SELECT *
    FROM d_delivery_notes
    WHERE "ownerId" = owner_id AND "receiptId" = receipt_id
    
    UNION ALL
    
    SELECT *
    FROM d_invoices
    WHERE "ownerId" = owner_id AND "receiptId" = receipt_id;
    
END;
$$;


ALTER FUNCTION "public"."get_receipts_with_same_receipt_id"("owner_id" "text", "receipt_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_data"("p_product_id" "text", "p_owner_id" "text") RETURNS TABLE("product_id" "text", "month" "text", "total_quantity" integer, "total_revenue" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH sales_data AS (
        SELECT
            sp.product_id,
            DATE_TRUNC('month', sp.creation_date) AS month,
            SUM(sp.quantity) AS total_quantity,
            SUM(sp.total_price_net) AS total_revenue
        FROM
            stat_products sp
        WHERE
            sp.product_id = p_product_id
            AND sp.owner_id = p_owner_id
            AND sp.creation_date >= (CURRENT_DATE - INTERVAL '13 months')
        GROUP BY
            sp.product_id, month
    ),
    all_months AS (
        SELECT
            generate_series(
                DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months',
                DATE_TRUNC('month', CURRENT_DATE),
                '1 month'
            ) AS month
    )
    SELECT
        COALESCE(sd.product_id, p_product_id) AS product_id,
        TO_CHAR(am.month, 'YYYYMM') AS month,
        COALESCE(sd.total_quantity, 0) AS total_quantity,
        COALESCE(sd.total_revenue, 0) AS total_revenue
    FROM
        all_months am
    LEFT JOIN
        sales_data sd ON am.month = sd.month
    ORDER BY
        am.month;
END;
$$;


ALTER FUNCTION "public"."get_sales_data"("p_product_id" "text", "p_owner_id" "text") OWNER TO "postgres";


ALTER FUNCTION "public"."get_sales_per_day_per_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_volume_invoices_by_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") RETURNS TABLE("total_net_sum" double precision, "count" integer, "count_percent" double precision, "name" "text", "net_grouped_sum" double precision, "net_grouped_sum_percent" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN QUERY
  WITH calculated_invoices AS (
    SELECT
      inv."receiptTyp",
      inv."totalNet",
      CASE WHEN inv."receiptTyp" = 'credit' THEN inv."totalNet" * -1 ELSE inv."totalNet" END AS adjusted_net,
      inv."marketplaceId"
    FROM d_invoices inv
    WHERE inv."creationDate" >= start_date
      AND inv."creationDate" < end_date
      AND inv."ownerId" = owner_id
  ),
  total_counts AS (
    -- Berechnung der Gesamtsumme über alle Marktplätze hinweg
    SELECT
      COALESCE(SUM(adjusted_net), 0) AS total_sum
    FROM calculated_invoices
  )
  SELECT
    total_counts.total_sum AS total_net_sum,  -- Gesamtsumme über alle Marktplätze
    COUNT(*)::INTEGER AS count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM calculated_invoices))::DOUBLE PRECISION AS count_percent,
    COALESCE(mkt."name", 'Unknown') AS marketplace,
    SUM(adjusted_net) AS net_grouped_sum,
    (SUM(adjusted_net) * 100.0 / total_counts.total_sum)::DOUBLE PRECISION AS net_grouped_sum_percent
  FROM calculated_invoices ci
  LEFT JOIN d_marketplaces mkt ON ci."marketplaceId" = mkt."id"
  CROSS JOIN total_counts  -- Fügt die Gesamtsumme zu jedem Ergebnis hinzu
  GROUP BY marketplace, total_counts.total_sum;
END;
$$;


ALTER FUNCTION "public"."get_sales_volume_invoices_by_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_volume_invoices_by_marketplace_and_country"("owner_id" "text", "start_date" "date", "end_date" "date") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSONB := '[]'::JSONB;
    marketplace_record RECORD;
    overall_total_net_sum DOUBLE PRECISION;
BEGIN
    -- Berechnung der Gesamtsumme über alle Marktplätze und Länder hinweg
    SELECT SUM(CASE WHEN inv."receiptTyp" = 'credit' THEN inv."totalNet" * -1 ELSE inv."totalNet" END)
    INTO overall_total_net_sum
    FROM d_invoices inv
    WHERE inv."creationDate" >= start_date
      AND inv."creationDate" < end_date
      AND inv."ownerId" = owner_id;

    FOR marketplace_record IN
        WITH aggregated_data AS (
            SELECT
                inv."marketplaceId",
                COALESCE(mkt."name", 'Unknown') AS marketplace,
                inv."addressDelivery"->'country'->>'name' AS name,
                COUNT(*) AS count,
                SUM(CASE WHEN inv."receiptTyp" = 'credit' THEN inv."totalNet" * -1 ELSE inv."totalNet" END) AS net_grouped_sum
            FROM d_invoices inv
            LEFT JOIN d_marketplaces mkt ON inv."marketplaceId" = mkt."id"
            WHERE inv."creationDate" >= start_date
              AND inv."creationDate" < end_date
              AND inv."ownerId" = owner_id
            GROUP BY inv."marketplaceId", mkt."name", inv."addressDelivery"->'country'->>'name'
        ),
        total_marketplace AS (
            SELECT
                marketplace,
                SUM(count) AS total_count,
                SUM(net_grouped_sum) AS total_sum
            FROM aggregated_data
            GROUP BY marketplace
        )
        SELECT
            ad.marketplace,
            jsonb_agg(
                jsonb_build_object(
                    'name', ad.name,
                    'count', ad.count,
                    'count_percent', (ad.count * 100.0 / tm.total_count)::DOUBLE PRECISION,
                    'net_grouped_sum', ad.net_grouped_sum,
                    'total_net_sum', overall_total_net_sum,
                    'net_grouped_sum_percent', (ad.net_grouped_sum * 100.0 / tm.total_sum)::DOUBLE PRECISION
                )
            ) AS countries
        FROM aggregated_data ad
        JOIN total_marketplace tm ON ad.marketplace = tm.marketplace
        GROUP BY ad.marketplace, tm.total_count, tm.total_sum
    LOOP
        result := result || jsonb_build_object(
            'marketplace', marketplace_record.marketplace,
            'countries', marketplace_record.countries
        );
    END LOOP;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_sales_volume_invoices_by_marketplace_and_country"("owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_volume_invoices_grouped_by_country"("owner_id" "text", "start_date" "date", "end_date" "date") RETURNS TABLE("total_net_sum" double precision, "count" integer, "count_percent" double precision, "name" "text", "net_grouped_sum" double precision, "net_grouped_sum_percent" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN QUERY
  WITH calculated_invoices AS (
    SELECT
      inv."receiptTyp",
      inv."totalNet",
      CASE WHEN inv."receiptTyp" = 'credit' THEN inv."totalNet" * -1 ELSE inv."totalNet" END AS adjusted_net,
      inv."addressDelivery"->'country'->>'name' AS country_name
    FROM d_invoices inv
    WHERE inv."creationDate" >= start_date
      AND inv."creationDate" < end_date
      AND inv."ownerId" = owner_id
  ),
  total_counts AS (
    -- Berechnung der Gesamtsumme und Gesamtanzahl über alle Länder hinweg
    SELECT
      COUNT(*)::INTEGER AS total_count,  -- Hier wird die Konvertierung zu INTEGER vorgenommen
      COALESCE(SUM(adjusted_net), 0) AS total_sum
    FROM calculated_invoices
  ),
  grouped_data AS (
    -- Gruppierung der Daten nach Land
    SELECT
      country_name,
      COUNT(*)::INTEGER AS count,  -- Hier wird die Konvertierung zu INTEGER vorgenommen
      SUM(adjusted_net) AS net_grouped_sum
    FROM calculated_invoices
    GROUP BY country_name
  )
  SELECT
    total_counts.total_sum AS total_net_sum,  -- Gesamtsumme über alle Länder
    grouped_data.count,
    (grouped_data.count * 100.0 / total_counts.total_count)::DOUBLE PRECISION AS count_percent,
    grouped_data.country_name AS name,
    grouped_data.net_grouped_sum,
    (grouped_data.net_grouped_sum * 100.0 / total_counts.total_sum)::DOUBLE PRECISION AS net_grouped_sum_percent
  FROM grouped_data, total_counts;
END;
$$;


ALTER FUNCTION "public"."get_sales_volume_invoices_grouped_by_country"("owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_stat_products_by_brand"("start_date" "date", "end_date" "date", "owner_id" "text") RETURNS TABLE("brand_name" "text", "total_price_net" double precision, "total_profit" double precision, "total_quantity" integer)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        brand_name,
        SUM(total_price_net) AS total_net_sales,
        SUM(profit) AS total_profit,
        SUM(quantity) AS total_quantity
    FROM
        public.stat_products
    WHERE
        creation_date >= start_date
        AND creation_date <= end_date
        AND owner_id = owner_id
    GROUP BY
        brand_name;
END;
$$;


ALTER FUNCTION "public"."get_stat_products_by_brand"("start_date" "date", "end_date" "date", "owner_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_stat_products_by_brand"("p_owner_id" "text", "start_date" "date", "end_date" "date") RETURNS TABLE("brand_name" "text", "total_net_sales" double precision, "total_profit" double precision, "total_quantity" integer, "total_profit_percent" double precision)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        sp.brand_name::TEXT,
        SUM(sp.total_price_net) AS total_net_sales,
        SUM(sp.profit) AS total_profit,
        SUM(sp.quantity)::INTEGER AS total_quantity,
        CASE 
            WHEN SUM(sp.total_price_net) = 0 THEN 0
            ELSE (SUM(sp.profit) / SUM(sp.total_price_net)) * 100
        END AS total_profit_percent
    FROM
        stat_products sp
    WHERE
        sp.creation_date >= start_date
        AND sp.creation_date <= end_date
        AND sp.owner_id = p_owner_id
    GROUP BY
        sp.brand_name
    ORDER BY
        total_net_sales DESC;
END;
$$;


ALTER FUNCTION "public"."get_stat_products_by_brand"("p_owner_id" "text", "start_date" "date", "end_date" "date") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_suppliers" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "supplierNumber" integer,
    "company" "text",
    "firstName" "text",
    "lastName" "text",
    "street" "text",
    "street2" "text",
    "postcode" "text",
    "city" "text",
    "country" "jsonb",
    "email" "text",
    "homepage" "text",
    "phone" "text",
    "phoneMobile" "text",
    "uidNumber" "text",
    "taxNumber" "text",
    "tax" "jsonb",
    "creationDate" timestamp with time zone DEFAULT "now"(),
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "ownerId" "text"
);


ALTER TABLE "public"."d_suppliers" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_suppliers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) RETURNS SETOF "public"."d_suppliers"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    start_index INT;
    end_index INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate start and end indices for pagination
    start_index := (current_page - 1) * items_per_page;
    end_index := start_index + items_per_page - 1;

    -- Return the filtered and paginated result
    RETURN QUERY
    SELECT * FROM d_suppliers
    WHERE "ownerId" = owner_id
    AND (
        lower("supplierNumber"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("firstName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("lastName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(company) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(email) LIKE '%' || array_to_string(st, '%') || '%'
    )
    ORDER BY "supplierNumber" desc
    OFFSET start_index LIMIT items_per_page;
END;
$$;


ALTER FUNCTION "public"."get_suppliers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_suppliers_count_by_search_text"("owner_id" "text", "search_text" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    st TEXT[];
    result_count INT;
BEGIN
    -- Split the search text into words
    st := string_to_array(lower(search_text), ' ');

    -- Calculate the count of the filtered result
    SELECT COUNT(*) INTO result_count
    FROM d_suppliers
    WHERE "ownerId" = owner_id
    AND (
        lower("supplierNumber"::TEXT) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("firstName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower("lastName") LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(company) LIKE '%' || array_to_string(st, '%') || '%' OR
        lower(email) LIKE '%' || array_to_string(st, '%') || '%'
    );

    RETURN result_count;
END;
$$;


ALTER FUNCTION "public"."get_suppliers_count_by_search_text"("owner_id" "text", "search_text" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_client_clients"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Einfügen eines leeren Clients
  INSERT INTO public.clients (
    id,
    owner_id,
    email,
    gender,
    company_name,
    first_name,
    last_name,
    tel1,
    tel2,
    street,
    post_code,
    city,
    country,
    client_type,
    client_rights
  ) VALUES (
    NEW.id,
    '', -- Angenommen, owner_id sollte die Benutzer-ID sein
    '',
    'empty', -- Angenommen, das ist der Standardwert für gender
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    'employee',  -- Standardwert für client_type
    'level3'     -- Standardwert für client_rights
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_client_clients"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_client_main_settings"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN

  -- Einfügen der Standard-Haupteinstellungen
  INSERT INTO public.main_settings (
    id,
    logo_url,
    offer_praefix,
    appointment_praefix,
    delivery_note_praefix,
    invoice_praefix,
    credit_praefix,
    currency,
    sms_message,
    offer_document_text,
    appointment_document_text,
    delivery_note_document_text,
    invoice_document_text,
    credit_document_text,
    next_offer_number,
    next_appointment_number,
    next_delivery_note_number,
    next_invoice_number,
    next_branch_number,
    next_customer_number,
    next_supplier_number,
    next_reorder_number,
    term_of_payment,
    count_employees,
    count_branches,
    limitation_number_of_employees,
    limitation_number_of_branches,
    is_small_business,
    is_main_settings
  ) VALUES (
    NEW.id,
    '',
    'AG-',
    'AT-',
    'LS-',
    'RE-',
    'RK-',
    '€',
    '',
    '',
    '',
    '',
    '',
    '',
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    14,
    0,
    0,
    0,
    0,
    false,
    true
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_client_main_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_appointment_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE d_main_settings
  SET "nextAppointmentNumber" = "nextAppointmentNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_appointment_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_customer_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE "d_main_settings"
  SET "nextCustomerNumber" = "nextCustomerNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_customer_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_deliver_note_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE d_main_settings
  SET "nextDeliveryNoteNumber" = "nextDeliveryNoteNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_deliver_note_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_invoice_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE d_main_settings
  SET "nextInvoiceNumber" = "nextInvoiceNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_invoice_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_offer_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE "d_main_settings"
  SET "nextOfferNumber" = "nextOfferNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_offer_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_next_supplier_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE "d_main_settings"
  SET "nextSupplierNumber" = "nextSupplierNumber" + 1
  WHERE "settingsId" = NEW."ownerId";
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."increment_next_supplier_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_stat_products_on_insert_invoice"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    receiptProduct JSONB;
    brandName TEXT;
BEGIN
    -- Loop through each receipt product in the new invoice
    FOR receiptProduct IN SELECT jsonb_array_elements(NEW."listOfReceiptProduct")
    LOOP
        -- Check if the product is from the database
        IF (receiptProduct->>'isFromDatabase')::BOOLEAN = true THEN
            -- Get the brand name from d_products table
            SELECT dp."brandName" INTO brandName
            FROM public.d_products dp
            WHERE dp.id = receiptProduct->>'productId';

            -- Insert the product into stat_products
            INSERT INTO stat_products (
                product_id,
                receipt_id,
                product_name,
                product_ean,
                quantity,
                tax,
                unit_price_net,
                total_price_net,
                profit,
                owner_id,
                creation_date,
                last_editing_date,
                brand_name
            ) VALUES (
                receiptProduct->>'productId',
                NEW.id,
                receiptProduct->>'name',
                receiptProduct->>'ean',
                (receiptProduct->>'quantity')::INTEGER,
                (receiptProduct->'tax'->>'taxRate')::INTEGER,
                (receiptProduct->>'unitPriceNet')::DOUBLE PRECISION,
                (receiptProduct->>'unitPriceNet')::DOUBLE PRECISION * (receiptProduct->>'quantity')::INTEGER,
                (receiptProduct->>'profit')::DOUBLE PRECISION,
                NEW."ownerId",  -- Set owner_id from the invoice
                NEW."creationDate",
                NEW."lastEditingDate",
                brandName
            );
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."insert_stat_products_on_insert_invoice"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."populate_stat_dashboards"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "stat_dashboards" ("month", "credit_volume", "creation_date", "last_editing_date")
  SELECT
    to_char("creationDate", 'YYYY-MM') AS month,
    SUM("totalNet") AS credit_volume,
    now() AS creation_date,
    now() AS last_editing_date
  FROM "d_invoices" AS inv
  WHERE inv."receiptTyp" = 'credit'
  GROUP BY to_char("creationDate", 'YYYY-MM')
  ON CONFLICT ("month")
  DO UPDATE SET
    "credit_volume" = EXCLUDED."credit_volume",
    "last_editing_date" = EXCLUDED."last_editing_date";
END;
$$;


ALTER FUNCTION "public"."populate_stat_dashboards"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."read_main_settings"("main_settings_id" "uuid") RETURNS TABLE("main_settings" "jsonb", "taxes" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        to_jsonb(main_settings) - 'id' AS main_settings,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', t.id,
                    'tax_name', t.tax_name,
                    'tax_rate', t.tax_rate,
                    'is_default', t.is_default,
                    'country', (
                        SELECT to_jsonb(c) - 'id'
                        FROM public.countries c
                        WHERE c.id = t.country_id
                    )
                )
            )
            FROM public.taxes t
            WHERE t.reference_id = main_settings_id
        ) AS taxes
    FROM public.main_settings
    WHERE id = main_settings_id;
END;
$$;


ALTER FUNCTION "public"."read_main_settings"("main_settings_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_delete_appointment"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(OLD."creationDate", 'YYYY-MM')
      AND owner_id = OLD."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET appointment_volume = appointment_volume - OLD."totalNet",
        last_editing_date = now()
    WHERE month = to_char(OLD."creationDate", 'YYYY-MM')
      AND owner_id = OLD."ownerId";
  END IF;
  RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_delete_appointment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_delete_offer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(OLD."creationDate", 'YYYY-MM')
      AND owner_id = OLD."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET offer_volume = offer_volume - OLD."totalNet",
        last_editing_date = now()
    WHERE month = to_char(OLD."creationDate", 'YYYY-MM')
      AND owner_id = OLD."ownerId";
  END IF;
  RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_delete_offer"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_insert_appointment"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET appointment_volume = appointment_volume + NEW."totalNet",
        last_editing_date = now()
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId";
  ELSE
    -- Erstellen eines neuen Eintrags
    INSERT INTO public.stat_dashboards (
      month, offer_volume, appointment_volume, invoice_volume, credit_volume,
      creation_date, last_editing_date, owner_id
    ) VALUES (
      to_char(NEW."creationDate", 'YYYY-MM'), 0, NEW."totalNet", 0, 0,
      now(), now(), NEW."ownerId"
    );
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_insert_appointment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_insert_invoice"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW."receiptTyp" = 'invoice' THEN
    -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
    IF EXISTS (
      SELECT 1 FROM public.stat_dashboards
      WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
        AND owner_id = NEW."ownerId"
    ) THEN
      -- Aktualisieren des bestehenden Eintrags
      UPDATE public.stat_dashboards
      SET invoice_volume = invoice_volume + NEW."totalNet",
          last_editing_date = now()
      WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
        AND owner_id = NEW."ownerId";
    ELSE
      -- Erstellen eines neuen Eintrags
      INSERT INTO public.stat_dashboards (
        month, offer_volume, appointment_volume, invoice_volume, credit_volume,
        creation_date, last_editing_date, owner_id
      ) VALUES (
        to_char(NEW."creationDate", 'YYYY-MM'), 0, 0, NEW."totalNet", 0,
        now(), now(), NEW."ownerId"
      );
    END IF;
  ELSIF NEW."receiptTyp" = 'credit' THEN
    -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
    IF EXISTS (
      SELECT 1 FROM public.stat_dashboards
      WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
        AND owner_id = NEW."ownerId"
    ) THEN
      -- Aktualisieren des bestehenden Eintrags
      UPDATE public.stat_dashboards
      SET credit_volume = credit_volume + NEW."totalNet",
          last_editing_date = now()
      WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
        AND owner_id = NEW."ownerId";
    ELSE
      -- Erstellen eines neuen Eintrags
      INSERT INTO public.stat_dashboards (
        month, offer_volume, appointment_volume, invoice_volume, credit_volume,
        creation_date, last_editing_date, owner_id
      ) VALUES (
        to_char(NEW."creationDate", 'YYYY-MM'), 0, 0, 0, NEW."totalNet",
        now(), now(), NEW."ownerId"
      );
    END IF;

    -- Reduzieren des invoice_volume für die passende Invoice
    UPDATE public.stat_dashboards
    SET invoice_volume = invoice_volume - NEW."totalNet",
        last_editing_date = now()
    WHERE month = (SELECT to_char("creationDate", 'YYYY-MM') 
                   FROM public.d_invoices 
                   WHERE "receiptId" = NEW."receiptId" 
                     AND "receiptTyp" = 'invoice')
      AND owner_id = NEW."ownerId";
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_insert_invoice"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_insert_offer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den aktuellen Monat und den owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET offer_volume = offer_volume + NEW."totalNet",
        last_editing_date = now()
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId";
  ELSE
    -- Erstellen eines neuen Eintrags
    INSERT INTO public.stat_dashboards (
      month, offer_volume, appointment_volume, invoice_volume, credit_volume,
      creation_date, last_editing_date, owner_id
    ) VALUES (
      to_char(NEW."creationDate", 'YYYY-MM'), NEW."totalNet", 0, 0, 0,
      now(), now(), NEW."ownerId"
    );
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_insert_offer"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_update_appointment"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den neuen Monat und den neuen owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET appointment_volume = appointment_volume + (NEW."totalNet" - OLD."totalNet"),
        last_editing_date = now()
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId";
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_update_appointment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."stat_dashboards_on_update_offer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Prüfen, ob ein Eintrag für den neuen Monat und den neuen owner_id existiert
  IF EXISTS (
    SELECT 1 FROM public.stat_dashboards
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId"
  ) THEN
    -- Aktualisieren des bestehenden Eintrags
    UPDATE public.stat_dashboards
    SET offer_volume = offer_volume + (NEW."totalNet" - OLD."totalNet"),
        last_editing_date = now()
    WHERE month = to_char(NEW."creationDate", 'YYYY-MM')
      AND owner_id = NEW."ownerId";
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."stat_dashboards_on_update_offer"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_last_editing_date"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    new."lastEditingDate" := now();
    return new;
end;
$$;


ALTER FUNCTION "public"."update_last_editing_date"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_main_settings"("main_settings_json" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_id UUID := main_settings_json->>'id';
  tax_element JSONB;
BEGIN  
  UPDATE public.main_settings
  SET 
    logo_url = (main_settings_json->>'logo_url')::VARCHAR,
    offer_praefix = (main_settings_json->>'offer_praefix')::VARCHAR,
    appointment_praefix = (main_settings_json->>'appointment_praefix')::VARCHAR,
    delivery_note_praefix = (main_settings_json->>'delivery_note_praefix')::VARCHAR,
    invoice_praefix = (main_settings_json->>'invoice_praefix')::VARCHAR,
    credit_praefix = (main_settings_json->>'credit_praefix')::VARCHAR,
    currency = (main_settings_json->>'currency')::VARCHAR,
    sms_message = (main_settings_json->>'sms_message')::VARCHAR,
    offer_document_text = (main_settings_json->>'offer_document_text')::VARCHAR,
    appointment_document_text = (main_settings_json->>'appointment_document_text')::VARCHAR,
    delivery_note_document_text = (main_settings_json->>'delivery_note_document_text')::VARCHAR,
    invoice_document_text = (main_settings_json->>'invoice_document_text')::VARCHAR,
    credit_document_text = (main_settings_json->>'credit_document_text')::VARCHAR,
    next_offer_number = (main_settings_json->>'next_offer_number')::INT,
    next_appointment_number = (main_settings_json->>'next_appointment_number')::INT,
    next_delivery_note_number = (main_settings_json->>'next_delivery_note_number')::INT,
    next_invoice_number = (main_settings_json->>'next_invoice_number')::INT,
    next_branch_number = (main_settings_json->>'next_branch_number')::INT,
    next_customer_number = (main_settings_json->>'next_customer_number')::INT,
    next_supplier_number = (main_settings_json->>'next_supplier_number')::INT,
    next_reorder_number = (main_settings_json->>'next_reorder_number')::INT,
    term_of_payment = (main_settings_json->>'term_of_payment')::INT,
    count_employees = (main_settings_json->>'count_employees')::INT,
    count_branches = (main_settings_json->>'count_branches')::INT,
    limitation_number_of_employees = (main_settings_json->>'limitation_number_of_employees')::INT,
    limitation_number_of_branches = (main_settings_json->>'limitation_number_of_branches')::INT,
    is_small_business = (main_settings_json->>'is_small_business')::BOOLEAN,
    is_main_settings = (main_settings_json->>'is_main_settings')::BOOLEAN
  WHERE id = v_id;

FOR tax_element IN SELECT * FROM jsonb_array_elements(main_settings_json->'taxes')
    LOOP
        IF EXISTS (SELECT 1 FROM public.taxes WHERE id = tax_element->>'id') THEN
            -- Update existing tax information
            UPDATE public.taxes
            SET 
                tax_name = tax_element->>'tax_name',
                tax_rate = (tax_element->>'tax_rate')::INT,
                country_id = (tax_element->'country')->>'id',
                is_default = (tax_element->>'is_default')::BOOLEAN
            WHERE id = tax_element->>'id';
        ELSE
            -- Insert new tax information
            INSERT INTO public.taxes (id, tax_name, tax_rate, country_id, reference_id, is_default)
            VALUES (
                tax_element->>'id',
                tax_element->>'tax_name',
                (tax_element->>'tax_rate')::INT,
                (tax_element->'country')->>'id',
                main_settings_json->>'id',
                (tax_element->>'is_default')::BOOLEAN
            );
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."update_main_settings"("main_settings_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_product_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer, "update_only_available_quantity_input" boolean) RETURNS SETOF "public"."d_products"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result d_products%ROWTYPE;
    updated_product d_products%ROWTYPE;
    part_of_set_id TEXT;
    set_product d_products%ROWTYPE;
    updated_products d_products[] := '{}';
    product_data JSONB;
    set_part_product_id TEXT;
    set_part_product_quantity INT;
BEGIN
    IF update_only_available_quantity_input THEN
        -- Nur availableStock inkrementieren
        UPDATE d_products
        SET "availableStock" = "availableStock" + quantity_input,
            "isUnderMinimumStock" = ("availableStock" + quantity_input) <= "minimumStock"
        WHERE "ownerId" = owner_id_input
        AND id = product_id_input
        RETURNING * INTO result;
    ELSE
        -- Sowohl warehouseStock als auch availableStock inkrementieren
        UPDATE d_products
        SET "availableStock" = "availableStock" + quantity_input,
            "warehouseStock" = "warehouseStock" + quantity_input,
            "isUnderMinimumStock" = ("availableStock" + quantity_input) <= "minimumStock"
        WHERE "ownerId" = owner_id_input
        AND id = product_id_input
        RETURNING * INTO result;
    END IF;

    -- Den ursprünglichen Artikel zu den geänderten Artikeln hinzufügen
    updated_products := updated_products || ARRAY[result];

    -- Prüfen, ob listOfIsPartOfSetIds nicht leer ist
    IF jsonb_array_length(result."listOfIsPartOfSetIds") > 0 AND result."availableStock" >=0  THEN
        FOR part_of_set_id IN
            SELECT jsonb_array_elements_text(result."listOfIsPartOfSetIds")
        LOOP
            -- Set-Artikel abrufen
            SELECT * INTO set_product
            FROM d_products
            WHERE "ownerId" = owner_id_input
            AND id = part_of_set_id;
            -- compare_and_update_set_product_stock für den Set-Artikel ausführen
            PERFORM compare_and_update_set_product_stock(owner_id_input, part_of_set_id);
            
            -- Den aktualisierten Set-Artikel abrufen
            SELECT * INTO updated_product
            FROM d_products
            WHERE "ownerId" = owner_id_input
            AND id = part_of_set_id;
            -- Nur zu den geänderten hinzufügen, wenn auch wirklich ein Update am Set-Artikel stattgefunden hat
            IF set_product."availableStock" != updated_product."availableStock" THEN
                -- Den aktualisierten Set-Artikel zu den geänderten Artikeln hinzufügen
                updated_products := updated_products || ARRAY[updated_product];
            END IF;
        END LOOP;
    END IF;

    -- Prüfen, ob der ursprüngliche Artikel (result) ein Set-Artikel ist
    IF result."isSetArticle" IS TRUE AND jsonb_array_length(result."listOfProductIdWithQuantity") > 0 THEN
        FOR product_data IN
            SELECT value FROM jsonb_array_elements(result."listOfProductIdWithQuantity")
        LOOP
            -- Extrahiere die `productId` und `quantity` aus dem JSONB-Element
            set_part_product_id := product_data->>'productId';
            set_part_product_quantity := (product_data->>'quantity')::INT * quantity_input;

            -- Direkter Aufruf von update_product_stock und Zugriff auf den Rückgabewert
            DECLARE
                updated_product d_products%ROWTYPE;
            BEGIN
                FOR updated_product IN
                    SELECT * FROM update_product_stock(
                        owner_id_input, 
                        set_part_product_id, 
                        set_part_product_quantity, 
                        false
                    )
                LOOP
                    updated_products := updated_products || ARRAY[updated_product];
                END LOOP;
            END;
        END LOOP;
    END IF;

    -- Alle geänderten Artikel zurückgeben
    RETURN QUERY SELECT * FROM unnest(updated_products);

END;
$$;


ALTER FUNCTION "public"."update_product_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer, "update_only_available_quantity_input" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_product_warehouse_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Lagerbestand (warehouseStock) des Produkts aktualisieren
    UPDATE d_products
    SET "warehouseStock" = "warehouseStock" + quantity_input
    WHERE "ownerId" = owner_id_input
    AND id = product_id_input;

    -- Du kannst zusätzliche Logik hier hinzufügen, wenn nötig

END;
$$;


ALTER FUNCTION "public"."update_product_warehouse_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer) OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."clients" (
    "id" "uuid" NOT NULL,
    "owner_id" character varying NOT NULL,
    "email" character varying NOT NULL,
    "gender" character varying NOT NULL,
    "company_name" character varying,
    "first_name" character varying,
    "last_name" character varying,
    "tel1" character varying,
    "tel2" character varying,
    "street" character varying,
    "post_code" character varying,
    "city" character varying,
    "country" character varying,
    "client_type" character varying NOT NULL,
    "client_rights" character varying NOT NULL,
    "creation_date" timestamp with time zone DEFAULT "now"(),
    "last_editing_date" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."clients" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."countries" (
    "id" character varying(255) NOT NULL,
    "iso_code" character varying(10) NOT NULL,
    "name" character varying(255) NOT NULL,
    "name_english" character varying(255) NOT NULL,
    "dial_code" character varying(50)
);


ALTER TABLE "public"."countries" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_delivery_notes" (
    "id" "text" NOT NULL,
    "receiptId" "text",
    "offerId" integer,
    "offerNumberAsString" "text",
    "appointmentId" integer,
    "appointmentNumberAsString" "text",
    "deliveryNoteId" integer,
    "deliveryNoteNumberAsString" "text",
    "listOfDeliveryNoteIds" "jsonb",
    "invoiceId" integer,
    "invoiceNumberAsString" "text",
    "creditId" integer,
    "creditNumberAsString" "text",
    "marketplaceId" "text",
    "receiptMarketplaceId" bigint,
    "receiptMarketplaceReference" "text",
    "paymentMethod" "jsonb",
    "commentInternal" "text",
    "commentGlobal" "text",
    "currency" "text",
    "receiptDocumentText" "text",
    "uidNumber" "text",
    "searchField" "text",
    "customerId" "text",
    "receiptCustomer" "jsonb",
    "addressInvoice" "jsonb",
    "addressDelivery" "jsonb",
    "receiptTyp" "text",
    "offerStatus" "text",
    "appointmentStatus" "text",
    "paymentStatus" "text",
    "tax" "jsonb",
    "isSmallBusiness" boolean,
    "isPicked" boolean,
    "termOfPayment" integer,
    "weight" double precision,
    "totalGross" double precision,
    "totalNet" double precision,
    "totalTax" double precision,
    "subTotalNet" double precision,
    "subTotalTax" double precision,
    "subTotalGross" double precision,
    "totalPaidGross" double precision,
    "totalPaidNet" double precision,
    "totalPaidTax" double precision,
    "totalShippingGross" double precision,
    "totalShippingNet" double precision,
    "totalShippingTax" double precision,
    "totalWrappingGross" double precision,
    "totalWrappingNet" double precision,
    "totalWrappingTax" double precision,
    "discountGross" double precision,
    "discountNet" double precision,
    "discountTax" double precision,
    "discountPercent" double precision,
    "discountPercentAmountGross" double precision,
    "discountPercentAmountNet" double precision,
    "discountPercentAmountTax" double precision,
    "posDiscountPercentAmountGross" double precision,
    "posDiscountPercentAmountNet" double precision,
    "posDiscountPercentAmountTax" double precision,
    "additionalAmountNet" double precision,
    "additionalAmountTax" double precision,
    "additionalAmountGross" double precision,
    "profit" double precision,
    "profitExclShipping" double precision,
    "profitExclWrapping" double precision,
    "profitExclShippingAndWrapping" double precision,
    "bankDetails" "jsonb",
    "listOfPayments" "jsonb",
    "listOfReceiptProduct" "jsonb",
    "listOfParcelTracking" "jsonb",
    "receiptCarrier" "jsonb",
    "receiptMarketplace" "jsonb",
    "creationDateMarektplace" timestamp with time zone,
    "packagingBox" "jsonb",
    "creationDate" timestamp without time zone,
    "creationDateInt" bigint,
    "lastEditingDate" timestamp without time zone,
    "ownerId" "text",
    "isDeliveryBlocked" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."d_delivery_notes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_invoices" (
    "id" "text" NOT NULL,
    "receiptId" "text",
    "offerId" integer,
    "offerNumberAsString" "text",
    "appointmentId" integer,
    "appointmentNumberAsString" "text",
    "deliveryNoteId" integer,
    "deliveryNoteNumberAsString" "text",
    "listOfDeliveryNoteIds" "jsonb",
    "invoiceId" integer,
    "invoiceNumberAsString" "text",
    "creditId" integer,
    "creditNumberAsString" "text",
    "marketplaceId" "text",
    "receiptMarketplaceId" bigint,
    "receiptMarketplaceReference" "text",
    "paymentMethod" "jsonb",
    "commentInternal" "text",
    "commentGlobal" "text",
    "currency" "text",
    "receiptDocumentText" "text",
    "uidNumber" "text",
    "searchField" "text",
    "customerId" "text",
    "receiptCustomer" "jsonb",
    "addressInvoice" "jsonb",
    "addressDelivery" "jsonb",
    "receiptTyp" "text",
    "offerStatus" "text",
    "appointmentStatus" "text",
    "paymentStatus" "text",
    "tax" "jsonb",
    "isSmallBusiness" boolean,
    "isPicked" boolean,
    "termOfPayment" integer,
    "weight" double precision,
    "totalGross" double precision,
    "totalNet" double precision,
    "totalTax" double precision,
    "subTotalNet" double precision,
    "subTotalTax" double precision,
    "subTotalGross" double precision,
    "totalPaidGross" double precision,
    "totalPaidNet" double precision,
    "totalPaidTax" double precision,
    "totalShippingGross" double precision,
    "totalShippingNet" double precision,
    "totalShippingTax" double precision,
    "totalWrappingGross" double precision,
    "totalWrappingNet" double precision,
    "totalWrappingTax" double precision,
    "discountGross" double precision,
    "discountNet" double precision,
    "discountTax" double precision,
    "discountPercent" double precision,
    "discountPercentAmountGross" double precision,
    "discountPercentAmountNet" double precision,
    "discountPercentAmountTax" double precision,
    "posDiscountPercentAmountGross" double precision,
    "posDiscountPercentAmountNet" double precision,
    "posDiscountPercentAmountTax" double precision,
    "additionalAmountNet" double precision,
    "additionalAmountTax" double precision,
    "additionalAmountGross" double precision,
    "profit" double precision,
    "profitExclShipping" double precision,
    "profitExclWrapping" double precision,
    "profitExclShippingAndWrapping" double precision,
    "bankDetails" "jsonb",
    "listOfPayments" "jsonb",
    "listOfReceiptProduct" "jsonb",
    "listOfParcelTracking" "jsonb",
    "receiptCarrier" "jsonb",
    "receiptMarketplace" "jsonb",
    "creationDateMarektplace" timestamp with time zone,
    "packagingBox" "jsonb",
    "creationDate" timestamp without time zone,
    "creationDateInt" bigint,
    "lastEditingDate" timestamp without time zone,
    "ownerId" "text",
    "isDeliveryBlocked" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."d_invoices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_main_settings" (
    "settingsId" "text" NOT NULL,
    "logoUrl" character varying,
    "offerPraefix" character varying,
    "appointmentPraefix" character varying,
    "deliveryNotePraefix" character varying,
    "invoicePraefix" character varying,
    "creditPraefix" character varying,
    "currency" character varying,
    "smsMessage" character varying,
    "offerDocumentText" character varying,
    "appointmentDocumentText" character varying,
    "deliveryNoteDocumentText" character varying,
    "invoiceDocumentText" character varying,
    "creditDocumentText" character varying,
    "taxes" "jsonb",
    "nextOfferNumber" integer,
    "nextAppointmentNumber" integer,
    "nextDeliveryNoteNumber" integer,
    "nextInvoiceNumber" integer,
    "nextBranchNumber" integer,
    "nextCustomerNumber" integer,
    "nextSupplierNumber" integer,
    "nextReorderNumber" integer,
    "termOfPayment" integer,
    "countEmployees" integer,
    "countBranches" integer,
    "limitationNumberOfEmployees" integer,
    "limitationNumberOfBranches" integer,
    "isSmallBusiness" boolean,
    "isMainSettings" boolean,
    "printerMain" "jsonb",
    "printerLabel" "jsonb",
    "listOfCarriers" "jsonb",
    "paymentMethods" "jsonb",
    "listOfPackagingBoxes" "jsonb",
    "bankDetails" "jsonb",
    "openingTimes" "jsonb",
    "creationDate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "lastEditingDate" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."d_main_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_marketplaces" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text",
    "shortName" "text",
    "logoUrl" "text",
    "isActive" boolean,
    "marketplaceType" "text",
    "address" "jsonb",
    "marketplaceSettings" "jsonb",
    "bankDetails" "jsonb",
    "isPresta8" boolean,
    "endpointUrl" "text",
    "url" "text",
    "shopSuffix" "text",
    "fullUrl" "text",
    "key" "text",
    "orderStatusIdList" "jsonb",
    "orderStatusOnSuccessImport" integer,
    "orderStatusOnSuccessShipping" integer,
    "warehouseForProductImport" "text",
    "createMissingProductOnOrderImport" boolean,
    "paymentMethods" "jsonb",
    "storeName" "text",
    "adminAccessToken" "text",
    "storefrontAccessToken" "text",
    "createnDate" timestamp with time zone DEFAULT "now"(),
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "ownerId" "text",
    "defaultCustomerId" "text"
);


ALTER TABLE "public"."d_marketplaces" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_offers" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "receiptId" "text",
    "offerId" integer,
    "offerNumberAsString" "text",
    "appointmentId" integer,
    "appointmentNumberAsString" "text",
    "deliveryNoteId" integer,
    "deliveryNoteNumberAsString" "text",
    "listOfDeliveryNoteIds" "jsonb",
    "invoiceId" integer,
    "invoiceNumberAsString" "text",
    "creditId" integer,
    "creditNumberAsString" "text",
    "marketplaceId" "text",
    "receiptMarketplaceId" bigint,
    "receiptMarketplaceReference" "text",
    "paymentMethod" "jsonb",
    "commentInternal" "text",
    "commentGlobal" "text",
    "currency" "text",
    "receiptDocumentText" "text",
    "uidNumber" "text",
    "searchField" "text",
    "customerId" "text",
    "receiptCustomer" "jsonb",
    "addressInvoice" "jsonb",
    "addressDelivery" "jsonb",
    "receiptTyp" "text",
    "offerStatus" "text",
    "appointmentStatus" "text",
    "paymentStatus" "text",
    "tax" "jsonb",
    "isSmallBusiness" boolean,
    "isPicked" boolean,
    "termOfPayment" integer,
    "weight" double precision,
    "totalGross" double precision,
    "totalNet" double precision,
    "totalTax" double precision,
    "subTotalNet" double precision,
    "subTotalTax" double precision,
    "subTotalGross" double precision,
    "totalPaidGross" double precision,
    "totalPaidNet" double precision,
    "totalPaidTax" double precision,
    "totalShippingGross" double precision,
    "totalShippingNet" double precision,
    "totalShippingTax" double precision,
    "totalWrappingGross" double precision,
    "totalWrappingNet" double precision,
    "totalWrappingTax" double precision,
    "discountGross" double precision,
    "discountNet" double precision,
    "discountTax" double precision,
    "discountPercent" double precision,
    "discountPercentAmountGross" double precision,
    "discountPercentAmountNet" double precision,
    "discountPercentAmountTax" double precision,
    "posDiscountPercentAmountGross" double precision,
    "posDiscountPercentAmountNet" double precision,
    "posDiscountPercentAmountTax" double precision,
    "additionalAmountNet" double precision,
    "additionalAmountTax" double precision,
    "additionalAmountGross" double precision,
    "profit" double precision,
    "profitExclShipping" double precision,
    "profitExclWrapping" double precision,
    "profitExclShippingAndWrapping" double precision,
    "bankDetails" "jsonb",
    "listOfPayments" "jsonb",
    "listOfReceiptProduct" "jsonb",
    "listOfParcelTracking" "jsonb",
    "receiptCarrier" "jsonb",
    "receiptMarketplace" "jsonb",
    "creationDateMarektplace" timestamp with time zone,
    "packagingBox" "jsonb",
    "creationDate" timestamp without time zone,
    "creationDateInt" bigint,
    "lastEditingDate" timestamp without time zone,
    "ownerId" "text" DEFAULT ''::"text",
    "isDeliveryBlocked" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."d_offers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_picklists" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "listOfPicklistAppointments" "jsonb",
    "listOfPicklistProducts" "jsonb",
    "creationDate" timestamp with time zone DEFAULT "now"(),
    "creationDateInt" bigint,
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "ownerId" "text"
);


ALTER TABLE "public"."d_picklists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_reorders" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "reorderNumber" integer,
    "reorderNumberInternal" "text",
    "closedManually" boolean,
    "reorderStatus" "text",
    "reorderSupplier" "jsonb",
    "listOfReorderProducts" "jsonb",
    "tax" "jsonb",
    "currency" "text",
    "shippingPriceNet" double precision,
    "additionalAmountNet" double precision,
    "discountAmountNet" double precision,
    "discountPercent" double precision,
    "creationDate" timestamp with time zone DEFAULT "now"(),
    "deliveryDate" timestamp with time zone,
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "ownerId" "text"
);


ALTER TABLE "public"."d_reorders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_stat_dashboards" (
    "statDashboardId" "text",
    "dateTime" timestamp with time zone DEFAULT "now"(),
    "incomingOrders" double precision,
    "salesVolume" double precision,
    "offerVolume" double precision,
    "ownerId" "text"
);


ALTER TABLE "public"."d_stat_dashboards" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."d_stat_products" (
    "statProductId" "text",
    "name" "text",
    "articleNumber" "text",
    "ean" "text",
    "incomingOrders" double precision,
    "salesVolume" double precision,
    "offerVolume" double precision,
    "profit" double precision,
    "numberOfItemsSold" integer,
    "listOfStatProductDetail" "jsonb",
    "ownerId" "text",
    "lastEditingDate" timestamp with time zone DEFAULT "now"(),
    "creationDate" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."d_stat_products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."main_settings" (
    "id" "uuid" NOT NULL,
    "logo_url" character varying,
    "offer_praefix" character varying,
    "appointment_praefix" character varying,
    "delivery_note_praefix" character varying,
    "invoice_praefix" character varying,
    "credit_praefix" character varying,
    "currency" character varying,
    "sms_message" character varying,
    "offer_document_text" character varying,
    "appointment_document_text" character varying,
    "delivery_note_document_text" character varying,
    "invoice_document_text" character varying,
    "credit_document_text" character varying,
    "taxes" "jsonb",
    "next_offer_number" integer,
    "next_appointment_number" integer,
    "next_delivery_note_number" integer,
    "next_invoice_number" integer,
    "next_branch_number" integer,
    "next_customer_number" integer,
    "next_supplier_number" integer,
    "next_reorder_number" integer,
    "term_of_payment" integer,
    "count_employees" integer,
    "count_branches" integer,
    "limitation_number_of_employees" integer,
    "limitation_number_of_branches" integer,
    "is_small_business" boolean,
    "is_main_settings" boolean,
    "printer_main" "jsonb",
    "printer_label" "jsonb",
    "list_of_carriers" "jsonb",
    "payment_methods" "jsonb",
    "list_of_packaging_boxes" "jsonb",
    "bank_details" "jsonb",
    "opening_times" "jsonb",
    "creation_date" timestamp with time zone DEFAULT "now"(),
    "last_editing_date" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."main_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" character varying NOT NULL,
    "article_number" character varying,
    "supplier_article_number" character varying,
    "supplier_number" character varying,
    "supplier" character varying,
    "sku" character varying,
    "ean" character varying DEFAULT ''::character varying,
    "name" character varying,
    "list_of_name" "jsonb",
    "tax" "jsonb",
    "is_active" boolean,
    "ordered" integer,
    "brand_name" character varying,
    "unity" character varying DEFAULT ''::character varying,
    "unit_price" double precision,
    "width" double precision,
    "height" double precision,
    "depth" double precision,
    "weight" double precision,
    "net_price" double precision,
    "gross_price" double precision,
    "wholesale_price" double precision,
    "recommended_retail_price" double precision,
    "have_variants" boolean,
    "is_set_article" boolean,
    "is_outlet" boolean,
    "list_of_is_part_of_set_ids" "jsonb",
    "list_of_product_id_with_quantity" "jsonb",
    "is_set_self_quantity_managed" boolean,
    "manufacturer_number" character varying,
    "manufacturer" character varying,
    "warehouse_stock" integer,
    "available_stock" integer,
    "minimum_stock" integer,
    "is_under_minimum_stock" boolean,
    "minimum_reorder_quantity" integer,
    "packaging_unit_on_reorder" integer,
    "description" character varying,
    "list_of_description" "jsonb",
    "description_short" character varying,
    "list_of_description_short" "jsonb",
    "meta_title" character varying DEFAULT ''::character varying,
    "list_of_meta_title" "jsonb",
    "meta_description" character varying,
    "list_of_meta_description" "jsonb",
    "list_of_product_images" "jsonb",
    "list_of_set_products" "jsonb",
    "product_marketplaces" "jsonb",
    "creation_date" timestamp with time zone DEFAULT "now"(),
    "last_editing_date" timestamp with time zone DEFAULT "now"(),
    "owner_id" character varying,
    "image_urls" "text"[]
);


ALTER TABLE "public"."products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "updated_at" timestamp with time zone,
    "username" "text",
    "full_name" "text",
    "avatar_url" "text",
    "website" "text",
    CONSTRAINT "username_length" CHECK (("char_length"("username") >= 3))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stat_dashboards" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "offer_volume" double precision,
    "appointment_volume" double precision,
    "invoice_volume" double precision,
    "credit_volume" double precision,
    "creation_date" timestamp without time zone DEFAULT "now"(),
    "last_editing_date" timestamp without time zone DEFAULT "now"(),
    "month" "text" DEFAULT ''::"text",
    "owner_id" "text" DEFAULT ''::"text"
);


ALTER TABLE "public"."stat_dashboards" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stat_products" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "product_id" "text",
    "receipt_id" "text",
    "product_name" "text",
    "product_ean" "text",
    "quantity" integer,
    "tax" integer,
    "unit_price_net" double precision,
    "total_price_net" double precision,
    "profit" double precision,
    "creation_date" timestamp without time zone DEFAULT "now"(),
    "last_editing_date" timestamp without time zone DEFAULT "now"(),
    "owner_id" "text",
    "brand_name" "text" DEFAULT ''::"text"
);


ALTER TABLE "public"."stat_products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stat_products_count" (
    "id" "text" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "total_warehouse_stock" integer,
    "total_available_stock" integer,
    "total_wholesale_price" double precision,
    "total_net_price" double precision,
    "total_gross_price" double precision,
    "total_profit" double precision,
    "creation_date" timestamp without time zone DEFAULT "now"(),
    "owner_id" "text" DEFAULT ''::"text"
);


ALTER TABLE "public"."stat_products_count" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."taxes" (
    "id" character varying NOT NULL,
    "tax_name" character varying NOT NULL,
    "tax_rate" integer NOT NULL,
    "country_id" character varying NOT NULL,
    "reference_id" character varying,
    "is_default" boolean NOT NULL
);


ALTER TABLE "public"."taxes" OWNER TO "postgres";


ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_appointments"
    ADD CONSTRAINT "d_appointments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_customers"
    ADD CONSTRAINT "d_customers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_delivery_notes"
    ADD CONSTRAINT "d_delivery_notes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_invoices"
    ADD CONSTRAINT "d_invoices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_main_settings"
    ADD CONSTRAINT "d_main_settings_pkey" PRIMARY KEY ("settingsId");



ALTER TABLE ONLY "public"."d_marketplaces"
    ADD CONSTRAINT "d_marketplaces_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_offers"
    ADD CONSTRAINT "d_offers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_picklists"
    ADD CONSTRAINT "d_picklists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_products"
    ADD CONSTRAINT "d_products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_reorders"
    ADD CONSTRAINT "d_reorders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."d_suppliers"
    ADD CONSTRAINT "d_suppliers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."main_settings"
    ADD CONSTRAINT "main_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."stat_dashboards"
    ADD CONSTRAINT "stat_dashboards_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stat_products_count"
    ADD CONSTRAINT "stat_products_count_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."stat_products"
    ADD CONSTRAINT "stat_products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."taxes"
    ADD CONSTRAINT "taxes_pkey" PRIMARY KEY ("id");



CREATE UNIQUE INDEX "idx_unique_month" ON "public"."stat_dashboards" USING "btree" ("month");



CREATE OR REPLACE TRIGGER "after_insert_invoice_insert_stat_products" AFTER INSERT ON "public"."d_invoices" FOR EACH ROW EXECUTE FUNCTION "public"."insert_stat_products_on_insert_invoice"();



CREATE OR REPLACE TRIGGER "set_last_editing_date" BEFORE UPDATE ON "public"."clients" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();



CREATE OR REPLACE TRIGGER "set_last_editing_date" BEFORE UPDATE ON "public"."d_main_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();

ALTER TABLE "public"."d_main_settings" DISABLE TRIGGER "set_last_editing_date";



CREATE OR REPLACE TRIGGER "set_last_editing_date" BEFORE UPDATE ON "public"."d_stat_dashboards" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();



CREATE OR REPLACE TRIGGER "set_last_editing_date" BEFORE UPDATE ON "public"."main_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();



CREATE OR REPLACE TRIGGER "set_last_editing_date" BEFORE UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_delete_appointment" AFTER DELETE ON "public"."d_appointments" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_delete_appointment"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_delete_offer" AFTER DELETE ON "public"."d_offers" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_delete_offer"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_insert_appointment" AFTER INSERT ON "public"."d_appointments" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_insert_appointment"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_insert_invoice" AFTER INSERT ON "public"."d_invoices" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_insert_invoice"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_insert_offer" AFTER INSERT ON "public"."d_offers" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_insert_offer"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_update_appointment" AFTER UPDATE ON "public"."d_appointments" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_update_appointment"();



CREATE OR REPLACE TRIGGER "trg_stat_dashboards_on_update_offer" AFTER UPDATE ON "public"."d_offers" FOR EACH ROW EXECUTE FUNCTION "public"."stat_dashboards_on_update_offer"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_appointment_number" AFTER INSERT ON "public"."d_appointments" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_appointment_number"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_customer_number" AFTER INSERT ON "public"."d_customers" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_customer_number"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_deliver_note_number" AFTER INSERT ON "public"."d_delivery_notes" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_deliver_note_number"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_invoice_number" AFTER INSERT ON "public"."d_invoices" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_invoice_number"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_offer_number" AFTER INSERT ON "public"."d_offers" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_offer_number"();



CREATE OR REPLACE TRIGGER "trigger_increment_next_supplier_number" AFTER INSERT ON "public"."d_suppliers" FOR EACH ROW EXECUTE FUNCTION "public"."increment_next_supplier_number"();



CREATE OR REPLACE TRIGGER "update_last_editing_date_trigger" BEFORE UPDATE ON "public"."d_products" FOR EACH ROW EXECUTE FUNCTION "public"."update_last_editing_date"();



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."main_settings"
    ADD CONSTRAINT "main_settings_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."taxes"
    ADD CONSTRAINT "taxes_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "public"."countries"("id");



CREATE POLICY "Public profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Users can insert their own profile." ON "public"."profiles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





















































































































































































































GRANT ALL ON FUNCTION "public"."calculate_and_insert_product_stats_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_and_insert_product_stats_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_and_insert_product_stats_count"() TO "service_role";



GRANT ALL ON TABLE "public"."d_products" TO "anon";
GRANT ALL ON TABLE "public"."d_products" TO "authenticated";
GRANT ALL ON TABLE "public"."d_products" TO "service_role";



GRANT ALL ON FUNCTION "public"."compare_and_update_set_product_stock"("owner_id_input" "text", "product_id_input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."compare_and_update_set_product_stock"("owner_id_input" "text", "product_id_input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."compare_and_update_set_product_stock"("owner_id_input" "text", "product_id_input" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_main_settings"("main_settings_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_main_settings"("main_settings_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_main_settings"("main_settings_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_main_settings"("main_settings_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_main_settings"("main_settings_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_main_settings"("main_settings_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."d_appointments" TO "anon";
GRANT ALL ON TABLE "public"."d_appointments" TO "authenticated";
GRANT ALL ON TABLE "public"."d_appointments" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_receipts_between_dates"("owner_id" "text", "receipt_type" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_receipts_between_dates"("owner_id" "text", "receipt_type" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_receipts_between_dates"("owner_id" "text", "receipt_type" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_receipts_by_customer_id"("owner_id" "text", "customer_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_receipts_by_customer_id"("owner_id" "text", "customer_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_receipts_by_customer_id"("owner_id" "text", "customer_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_app_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON TABLE "public"."d_customers" TO "anon";
GRANT ALL ON TABLE "public"."d_customers" TO "authenticated";
GRANT ALL ON TABLE "public"."d_customers" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_customers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_customers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_customers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_customers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_customers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_customers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_d_products_count"("owner_id" "text", "only_active" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."get_d_products_count"("owner_id" "text", "only_active" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_d_products_count"("owner_id" "text", "only_active" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_d_products_count_by_search_text"("owner_id" "text", "search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_d_products_count_by_search_text"("owner_id" "text", "search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_d_products_count_by_search_text"("owner_id" "text", "search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_d_receipts_count"("owner_id" "text", "receipt_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count"("owner_id" "text", "receipt_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count"("owner_id" "text", "receipt_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_d_receipts_count_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_product_sales_and_stock_diff"("owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_product_sales_and_stock_diff"("owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_product_sales_and_stock_diff"("owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_products_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_products_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_products_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_product_id" "text", "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_product_id" "text", "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_between_dates"("p_product_id" "text", "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_by_product_ids_between_dates"("p_product_ids" "text"[], "p_owner_id" "text", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_products_sales_data_of_last_13_months"("p_product_id" "text", "p_owner_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_of_last_13_months"("p_product_id" "text", "p_owner_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_products_sales_data_of_last_13_months"("p_product_id" "text", "p_owner_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_receipts_by_search_text"("owner_id" "text", "receipt_type" "text", "tab_index" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_receipts_with_same_receipt_id"("owner_id" "text", "receipt_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_receipts_with_same_receipt_id"("owner_id" "text", "receipt_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_receipts_with_same_receipt_id"("owner_id" "text", "receipt_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_data"("p_product_id" "text", "p_owner_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_data"("p_product_id" "text", "p_owner_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_data"("p_product_id" "text", "p_owner_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_per_day_per_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_per_day_per_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_per_day_per_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace_and_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace_and_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_by_marketplace_and_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_grouped_by_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_grouped_by_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_volume_invoices_grouped_by_country"("owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("start_date" "date", "end_date" "date", "owner_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("start_date" "date", "end_date" "date", "owner_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("start_date" "date", "end_date" "date", "owner_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("p_owner_id" "text", "start_date" "date", "end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("p_owner_id" "text", "start_date" "date", "end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_stat_products_by_brand"("p_owner_id" "text", "start_date" "date", "end_date" "date") TO "service_role";



GRANT ALL ON TABLE "public"."d_suppliers" TO "anon";
GRANT ALL ON TABLE "public"."d_suppliers" TO "authenticated";
GRANT ALL ON TABLE "public"."d_suppliers" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_suppliers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_suppliers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_suppliers_by_search_text"("owner_id" "text", "search_text" "text", "current_page" integer, "items_per_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_suppliers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_suppliers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_suppliers_count_by_search_text"("owner_id" "text", "search_text" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_client_clients"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_client_clients"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_client_clients"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_client_main_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_client_main_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_client_main_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_appointment_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_appointment_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_appointment_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_customer_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_customer_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_customer_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_deliver_note_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_deliver_note_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_deliver_note_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_invoice_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_invoice_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_invoice_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_offer_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_offer_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_offer_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."increment_next_supplier_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."increment_next_supplier_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_next_supplier_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_stat_products_on_insert_invoice"() TO "anon";
GRANT ALL ON FUNCTION "public"."insert_stat_products_on_insert_invoice"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_stat_products_on_insert_invoice"() TO "service_role";



GRANT ALL ON FUNCTION "public"."populate_stat_dashboards"() TO "anon";
GRANT ALL ON FUNCTION "public"."populate_stat_dashboards"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."populate_stat_dashboards"() TO "service_role";



GRANT ALL ON FUNCTION "public"."read_main_settings"("main_settings_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."read_main_settings"("main_settings_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."read_main_settings"("main_settings_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_appointment"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_appointment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_appointment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_offer"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_offer"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_delete_offer"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_appointment"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_appointment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_appointment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_invoice"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_invoice"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_invoice"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_offer"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_offer"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_insert_offer"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_appointment"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_appointment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_appointment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_offer"() TO "anon";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_offer"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."stat_dashboards_on_update_offer"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_last_editing_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_last_editing_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_last_editing_date"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_main_settings"("main_settings_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_main_settings"("main_settings_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_main_settings"("main_settings_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_product_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer, "update_only_available_quantity_input" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."update_product_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer, "update_only_available_quantity_input" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_product_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer, "update_only_available_quantity_input" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_product_warehouse_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."update_product_warehouse_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_product_warehouse_stock"("owner_id_input" "text", "product_id_input" "text", "quantity_input" integer) TO "service_role";



























GRANT ALL ON TABLE "public"."clients" TO "anon";
GRANT ALL ON TABLE "public"."clients" TO "authenticated";
GRANT ALL ON TABLE "public"."clients" TO "service_role";



GRANT ALL ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticated";
GRANT ALL ON TABLE "public"."countries" TO "service_role";



GRANT ALL ON TABLE "public"."d_delivery_notes" TO "anon";
GRANT ALL ON TABLE "public"."d_delivery_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."d_delivery_notes" TO "service_role";



GRANT ALL ON TABLE "public"."d_invoices" TO "anon";
GRANT ALL ON TABLE "public"."d_invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."d_invoices" TO "service_role";



GRANT ALL ON TABLE "public"."d_main_settings" TO "anon";
GRANT ALL ON TABLE "public"."d_main_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."d_main_settings" TO "service_role";



GRANT ALL ON TABLE "public"."d_marketplaces" TO "anon";
GRANT ALL ON TABLE "public"."d_marketplaces" TO "authenticated";
GRANT ALL ON TABLE "public"."d_marketplaces" TO "service_role";



GRANT ALL ON TABLE "public"."d_offers" TO "anon";
GRANT ALL ON TABLE "public"."d_offers" TO "authenticated";
GRANT ALL ON TABLE "public"."d_offers" TO "service_role";



GRANT ALL ON TABLE "public"."d_picklists" TO "anon";
GRANT ALL ON TABLE "public"."d_picklists" TO "authenticated";
GRANT ALL ON TABLE "public"."d_picklists" TO "service_role";



GRANT ALL ON TABLE "public"."d_reorders" TO "anon";
GRANT ALL ON TABLE "public"."d_reorders" TO "authenticated";
GRANT ALL ON TABLE "public"."d_reorders" TO "service_role";



GRANT ALL ON TABLE "public"."d_stat_dashboards" TO "anon";
GRANT ALL ON TABLE "public"."d_stat_dashboards" TO "authenticated";
GRANT ALL ON TABLE "public"."d_stat_dashboards" TO "service_role";



GRANT ALL ON TABLE "public"."d_stat_products" TO "anon";
GRANT ALL ON TABLE "public"."d_stat_products" TO "authenticated";
GRANT ALL ON TABLE "public"."d_stat_products" TO "service_role";



GRANT ALL ON TABLE "public"."main_settings" TO "anon";
GRANT ALL ON TABLE "public"."main_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."main_settings" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."stat_dashboards" TO "anon";
GRANT ALL ON TABLE "public"."stat_dashboards" TO "authenticated";
GRANT ALL ON TABLE "public"."stat_dashboards" TO "service_role";



GRANT ALL ON TABLE "public"."stat_products" TO "anon";
GRANT ALL ON TABLE "public"."stat_products" TO "authenticated";
GRANT ALL ON TABLE "public"."stat_products" TO "service_role";



GRANT ALL ON TABLE "public"."stat_products_count" TO "anon";
GRANT ALL ON TABLE "public"."stat_products_count" TO "authenticated";
GRANT ALL ON TABLE "public"."stat_products_count" TO "service_role";



GRANT ALL ON TABLE "public"."taxes" TO "anon";
GRANT ALL ON TABLE "public"."taxes" TO "authenticated";
GRANT ALL ON TABLE "public"."taxes" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
