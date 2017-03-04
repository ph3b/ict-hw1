const example = require('./examples/medicationexample13.json');
const knex = require('knex')({
    client: 'mysql',
    connection: {
        host: 'localhost',
        user: 'root',
        password: 'hawaii',
        database: 'healthict'
    }
});

const insertRow = async (tableName, data, transaction) => {
    if (!data) return null;
    const results = await knex
        .insert(data)
        .transacting(transaction)
        .into(tableName)
    return results[0]
}

const getMedicationRow = (medication, codeId, productId) => {
    const medicationRow = {
        id: medication.id,
        isBrand: medication.isBrand ? 1 : 0,
        manufacturer: medication.manufacturer && medication.manufacturer.reference,
        codeId,
        productId
    }
    return medicationRow
}

const getCodeableConceptRow = (codeableConcept = {}) => {
    const { text } = codeableConcept;
    if (text) return { text }
    return { text: null }
}

const getCodeableConceptCoding = (codeableConcept, codeableConceptId) => {
    if (codeableConcept.coding) {
        return codeableConcept.coding.map(({ system, code, display }) => {
            return { system, code, display, codeableConceptId };
        })
    }
    return null;
}

const getProductRow = (formId) => {
    return { form: formId }
}

const getIngredientRows = (ingredient, productId) => ({
    productId,
    item: ingredient.item.display,
    amount_numerator_value: ingredient.amount.numerator.value,
    amount_numerator_system: ingredient.amount.numerator.system,
    amount_numerator_code: ingredient.amount.numerator.code,
    amount_denominator_value: ingredient.amount.denominator.value,
    amount_denominator_system: ingredient.amount.denominator.system,
    amount_denominator_code: ingredient.amount.denominator.code,
});

const getBatchRow = (batch, productId) => ({
    lotNumber: batch.lotNumber,
    expirationDate: batch.expirationDate,
    productId
})

const getContentRow = (content, packageId) => ({
    packageId,
    item: content.item.display,
    amount_numerator_value: content.amount.numerator.value,
    amount_numerator_system: content.amount.numerator.system,
    amount_numerator_code: content.amount.numerator.code,
    amount_denominator_value: content.amount.denominator.value,
    amount_denominator_system: content.amount.denominator.system,
    amount_denominator_code: content.amount.denominator.code,
})

const insertJson = async (medication) => {
    // Begin transaction
    return knex.transaction(async (trx) => {
        let productId, packageId, codeId;

        // Medication has code
        if (medication.code) {
            codeId = await insertRow('CodeableConcept', getCodeableConceptRow(medication.code), trx)
            const code_codingRows = getCodeableConceptCoding(medication.code, codeId);
            if (code_codingRows) await Promise.all(code_codingRows.map(code => insertRow('CodeableConceptcoding', code, trx)))
        }

        // Medication has a product
        if (medication.product) {
            const formId = await insertRow('CodeableConcept', getCodeableConceptRow(medication.product.form), trx)
            const form_codingRows = getCodeableConceptCoding(medication.product.form, formId)
            if (form_codingRows) await insertRow('CodeableConceptcoding', form_codingRows, trx)
            productId = await insertRow('Medicationproduct', getProductRow(formId), trx);

            // Product has ingredients
            if (medication.product.ingredient) {
                const ingredientRows = medication.product.ingredient.map(i => getIngredientRows(i, productId));
                await insertRow('ProductIngredient', ingredientRows, trx);
            }

            // Product has batch
            if (medication.product.batch) {
                const batchRows = medication.product.batch.map(b => getBatchRow(b, productId));
                await insertRow('ProductBatch', batchRows, trx);
            }
        }

        // Medication has package
        if (medication.package) {
            let containerId

            if (medication.package.container) {
                containerId = await insertRow('CodeableConcept', getCodeableConceptRow(medication.package.container), trx);
                const container_codingRows = getCodeableConceptCoding(medication.package.container, containerId);
                if (container_codingRows) await insertRow('CodeableConceptcoding', container_codingRows, trx);
            }

            const packageId = await insertRow('MedicationPackage', { container: containerId }, trx);

            if (medication.package.content) {
                const contentRows = medication.package.content.map(c => getContentRow(c, packageId));
                await insertRow('PackageContent', contentRows, trx);
            }
        }

        await insertRow('Medication', getMedicationRow(medication, codeId, productId), trx)
        console.log('Success');
    })
}

// Clear database and run script
(async () => {
    try {
        await Promise.all([
            knex('Medication').del(),
            knex('Medicationproduct').del(),
            knex('ProductIngredient').del(),
            knex('MedicationPackage').del(),
            knex('CodeableConceptcoding').del(),
            knex('CodeableConcept').del(),
            knex('ProductBatch').del(),
            knex('PackageContent').del()
        ])
        const results = await insertJson(example);
    }
    catch (error) {
        console.log('insertJSON failed')
        console.log(error);
    }
})()
