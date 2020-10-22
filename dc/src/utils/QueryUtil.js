export default function createQuery(rules, expression) {
  let cnt = 1;
  let clause = "";
  let where = "";
  let exp = expression;

  if (exp) {
    exp = exp.toUpperCase();

    for (let i = 1; i <= rules.length; i += 1) {
      exp = exp.replace(new RegExp(`${i}`, "g"), `\`${i}\``);
    }
  }

  rules.forEach(row => {
    const fieldType = row.fieldType.toUpperCase();

    const isString =
      fieldType === "STRING" ||
      fieldType === "EMAIL" ||
      fieldType === "URL" ||
      fieldType === "COMBOBOX" ||
      fieldType === "PICKLIST" ||
      fieldType === "PHONE" ||
      fieldType === "TEXTAREA";

    const isNumber =
      fieldType === "INT" ||
      fieldType === "INTEGER" ||
      fieldType === "DOUBLE" ||
      fieldType === "DECIMAL" ||
      fieldType === "CURRENCY";
    const isBoolean = fieldType === "BOOLEAN";
    const isReference = fieldType === "ID" || fieldType === "REFERENCE";
    const isDate = fieldType === "DATE";
    const isDateTime = fieldType === "DATETIME";

    if (isString) clause = `${row.property} = '${row.value}'`;
    else if (isNumber) {
      if (row.value !== "") clause = `${row.property} = ${row.value}`;
      // For null or !null condition this may be empty
      else clause = `${row.property} = ${0}`;
    } else if (isBoolean) {
      if (row.value !== "") clause = `${row.property} = ${row.value}`;
      // For null or !null condition this may be empty
      else clause = `${row.property} = false`;
    } else if (isDate) {
      clause = `${row.property} = 2011-01-01`;
    } else if (isDateTime) {
      clause = `${row.property} = 2011-01-01T00:00:00Z`;
    } else if (isReference) {
      /** Escape all the reference fields because user can enter any string for creating a rule
       * and it should work */

      clause = "CreatedDate = 2011-01-01T00:00:00Z";
    }

    const regExp = new RegExp(`\`${cnt}\``, "g");

    if (exp != null && exp !== "") exp = exp.replace(regExp, ` ${clause}`);
    else where += `${clause} AND `;

    cnt += 1;
  });

  if (exp == null) {
    exp = where;
    exp = exp.substring(0, exp.length - 4); // Get rid of last AND
  }

  return `${exp} Limit 1`;
}
