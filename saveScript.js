const example = require('./examples/medicationexample2.json');
const knex = require('knex')({
    client: 'mysql',
    connection: {
        host: 'localhost',
        user: 'root',
        password: 'hawaii',
        database: 'healthict'
    }
});


const insertRow = (tableName, data, transaction) => {
    return knex
        .insert(data)
        .transacting(transaction)
        .into(tableName)
        .then(results => results[0])
}

const getMedicationRow = (medication, codeableConceptId) => {
    const medicationRow = {
        id: medication.id,
        isBrand: medication.isBrand ? 1 : 0,
        manufacturer: medication.manufacturer && medication.manufacturer.reference,
        code: codeableConceptId
    }
    return medicationRow
}

const getCodeableConceptRow = (medication) => {
    knex('')
    const { text } = medication.code;
    return { text }
}

const getCodeableConceptCoding = (medication, codeableConceptId) => {
    if (medication.code && medication.code.coding) {
        return medication.code.coding.map(({ system, code, display }) => {
            return { system, code, display, codeableConceptId };
        })
    }
    return null;
}

const insertProductRow = (medication, transaction) => {
    const { id, product } = medication;
    return { medicationId: id }
}

const insertJson = async (medication) => {
    return knex.transaction(async (trx) => {
        const codeableConceptId = await insertRow('CodeableConcept', getCodeableConceptRow(medication), trx)
        const codingRows = getCodeableConceptCoding(medication, codeableConceptId);
        if (codingRows) await Promise.all(codingRows.map(code => insertRow('CodeableConceptcoding', code, trx)))
        await insertRow('Medication', getMedicationRow(medication, codeableConceptId), trx)
        console.log('Success');
    })
}

(async () => {
    await Promise.all([
        knex('Medication').del(),
        knex('CodeableConceptcoding').del(),
        knex('CodeableConcept').del()
    ])
    try {
        const results = await insertJson(example);
    }
    catch (error) {
        console.log('insertJSON failed')
        console.log(error);
    }
})()
