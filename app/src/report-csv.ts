/** Quote CSV values and neutralize spreadsheet formulas, including leading control/space characters. */
export function csvCell(value:unknown):string {
  const text=String(value??'');
  return '"'+(/^[\s\u0000-\u001f]*[=+@-]/.test(text)?"'"+text:text).replaceAll('"','""')+'"';
}
