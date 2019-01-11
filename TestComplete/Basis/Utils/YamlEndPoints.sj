//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT FileUtils

function objectToYamlEndPoint() {
  var obj = testDataObject('yamlTest.json');
  var yml = objectToYaml(obj);
  stringToTemp(yml, 'yml.yaml');
}

function yamlToObjectEndPoint() {
  var obj = testDataObject('yamlTest.json');
  var yml = objectToYaml(obj);
  stringToTemp(yml, 'yml.yaml');
  var obj2 = YamlUtils.yamlToObject(yml);
  // this will not work array => object index as property
  checkEqual(obj, obj2);
}

