function fillStr(str, fillChar, len){
  var result = '',
      initialLength = str.length;
  
  if (initialLength < len) {
    do {
      result = result + fillChar;
    } while (result.length + initialLength < len);
  }
  return result;
}