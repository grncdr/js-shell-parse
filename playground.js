var parse = require('./');

var input = document.getElementById('input');
var output = document.getElementById('output');
var error = document.getElementById('error');

input.addEventListener('change', update);
input.addEventListener('input', update); 

function update() {
  try {
    var value = parse(input.value);
    output.textContent = JSON.stringify(value, null, 2);
    error.textContent = '';
  } catch (e) {
    error.textContent = String(e);
  }
}
