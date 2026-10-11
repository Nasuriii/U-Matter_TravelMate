import {test} from 'node:test';
import assert from 'node:assert/strict';
import {csvCell} from '../src/report-csv.ts';
test('CSV export escapes text and blocks formula prefixes after whitespace',()=>{
 assert.equal(csvCell('A "nice" cafe'),'"A ""nice"" cafe"');
 for(const value of ['=SUM(A1:A2)','  =1+1','\t@SUM(A1)','\r+cmd','-1+2'])assert.equal(csvCell(value),'"\''+value+'"');
 assert.equal(csvCell(42),'"42"');
});
