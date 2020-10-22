export default function createQueryParam(url, payload) {
  let quertParam = `${url}?`;
  payload.map(item => {
    const { key: pName, value: pValue } = item;
    if (Array.isArray(pValue)) {
      quertParam += `${pName}=${pValue.join()}&`;
    } else {
      quertParam += `${pName}=${pValue}&`;
    }
    return undefined;
  });
  return quertParam;
}
