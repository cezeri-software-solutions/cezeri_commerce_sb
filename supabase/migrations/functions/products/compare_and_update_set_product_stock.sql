CREATE
OR REPLACE FUNCTION "public"."compare_and_update_set_product_stock"(
    "owner_id_input" "text",
    "product_id_input" "text"
) RETURNS "public"."d_products" LANGUAGE "plpgsql" AS $ $ DECLARE set_product d_products % ROWTYPE;

listOfSetPartProducts jsonb [];

available_quantity_set_article INT;

difference INT;

updated_set_product d_products % ROWTYPE;

BEGIN -- Set-Artikel abrufen
SELECT
    * INTO set_product
FROM
    d_products
WHERE
    "ownerId" = owner_id_input
    AND id = product_id_input;

-- Prüfen, ob der Artikel ein Set-Artikel ist (listOfProductIdWithQuantity darf nicht leer sein und isSetArticle muss true sein)
IF set_product."isSetArticle" = false
OR jsonb_array_length(set_product."listOfProductIdWithQuantity") = 0 THEN RAISE EXCEPTION 'Der Artikel ist kein Set-Artikel oder die Liste der Set-Teilprodukte ist leer';

END IF;

-- Liste der Set-Teil-Produkte abrufen
listOfSetPartProducts := ARRAY(
    SELECT
        jsonb_array_elements(set_product."listOfProductIdWithQuantity")
);

-- Verfügbarkeit des Set-Artikels berechnen
available_quantity_set_article := (
    SELECT
        MIN(
            (
                sp."availableStock" / (part_product ->> 'quantity') :: INT
            )
        )
    FROM
        jsonb_array_elements(set_product."listOfProductIdWithQuantity") AS part_product,
        d_products sp
    WHERE
        sp.id = (part_product ->> 'productId') :: TEXT
        AND sp."ownerId" = owner_id_input
);

-- Unterschied zwischen warehouseStock und availableStock des Set-Artikels
difference := set_product."warehouseStock" - set_product."availableStock";

-- Set-Artikel mit neuen Werten aktualisieren
UPDATE
    d_products
SET
    "availableStock" = available_quantity_set_article,
    "warehouseStock" = available_quantity_set_article + difference,
    "isUnderMinimumStock" = available_quantity_set_article <= "minimumStock"
WHERE
    "ownerId" = owner_id_input
    AND id = product_id_input RETURNING * INTO updated_set_product;

RETURN updated_set_product;

END;

$ $;