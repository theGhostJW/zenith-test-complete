//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT FileUtils
//USEUNIT StringUtils
//USEUNIT WebUtils
//USEUNIT _
//USEUNIT EndPointLauncherUtils

jw =
function mapRecordsEndPoint() {
  var targ, result;
  
  function recIdTenToTen(record, arr){
    return record.id === 10 ? {wasTen: true} : record;
  }
  
  targ = fileToTable("FileToTable.txt");
  result = mapRecords(targ, recIdTenToTen);
  toTemp(result, 'tableRecords');
  
  targ = fileToTables("FileToTablesWithDoubleSpaces.txt", 0);
  result = mapRecords(targ, recIdTenToTen);
  toTemp(result, 'tablesRecords');
  
  targ = fileToTable("fileToTableGrouped.txt");
  result = mapRecords(targ, recIdTenToTen);
  toTemp(result, 'tableRecordsGrouped');
  
  targ = fileToTables("fileToTablesGrouped.txt");
  result = mapRecords(targ, recIdTenToTen);
  toTemp(result, 'tablesRecordsGrouped');
 
  targ = fileToTables("fileToTablesGrouped.txt");
  result = mapRecords(targ, {rec1: _.constant('R1'), rec2: recIdTenToTen});
  toTemp(result, 'tablesRecordsGroupedWithFunctionMap');
}


function mapFieldsEndPoint() {
  var targ = fileToTable("FileToTable.txt");
  
  function yeaBoo(val, key, obj){
    return obj.id === 10 ? 10 : _.isBoolean(val) ? val ? 'Yea' : 'Boo' : val;
  }
  
  var result = mapFields(targ, yeaBoo);
  toTemp(result, 'tableFields');
  
  targ = fileToTables("FileToTablesWithDoubleSpaces.txt", 0);;
  result = mapFields(targ, yeaBoo);
  toTemp(result, 'tablesFields');
  
  targ = fileToTable("fileToTableGrouped.txt");
  result = mapFields(targ, yeaBoo);
  toTemp(result, 'tableFieldsGrouped');
  
  targ = fileToTables("fileToTablesGrouped.txt");
  result = mapFields(targ, yeaBoo);
  toTemp(result, 'tablesFieldsGrouped');
}

function sumEndPoint() {
  var targ, result;
  targ = [];
  result = sum(targ);
  checkEqual(0, result);

  targ = [1, 2, 3, 4, 5, 6];
  result = sum(targ);
  checkEqual(21, result);

  targ = [1, undefined, 3, 4, null, 6];
  result = sum(targ);
  checkEqual(14, result);

  targ = {
          num1: 4,
          num2: 5,
          num3: null,
          num4: undefined,
          num6: 80
        };
  result = sum(targ);
  checkEqual(89, result);
}

function stringConvertableToNumberUnitTest() {
  check(stringConvertableToNumber('0'));
  check(stringConvertableToNumber('1'));
  check(stringConvertableToNumber('1.1110'));
  check(stringConvertableToNumber('0.1110'));
  
  checkFalse(stringConvertableToNumber('a1.1110'));
  checkFalse(stringConvertableToNumber('01.1110'));
  checkFalse(stringConvertableToNumber('.1110'));
  checkFalse(stringConvertableToNumber(null));
  checkFalse(stringConvertableToNumber(''));
}

function fillArrayUnitTest(){
  checkEqual([], fillArray(0, 'a'));
  checkEqual([0, 0, 0, 0], fillArray(4, 0));
}

function setPartsEndPoint(){
  var result = setParts([1,2,3,4], [2,4,6,8]);
  checkEqual([[1, 3], [2, 4], [6, 8]], result);
}

function hostNameIsEndPoint() {
  var result = hostNameIs('myMachine');
  checkFalse(result);
  
  result = hostNameIs('lamdahoflt2');
  check(result);
}

function flattenObjEndPoint() {
  /* === null should return null === */
  var targ = null,
      result = flattenObj(targ);
  checkEqual(null, result);
  
  /* === simple object return itself === */
  targ = {a: 'hi'};
  result = flattenObj(targ);
  checkEqual(targ, result);
  
  /* === nested object should return simple values === */
  targ = {
          a: 'hi',
          b: {
            c: 'there',
            d: 1,
            e: {
                f: 2,
                g: null
            }
          }
  };
  result = flattenObj(targ);
  
  checkEqual(
              {
                a: 'hi',
                c: 'there',
                d: 1,
                f: 2,
                g: null
              }, result);
              
   
  /* === deeply nested values should override shallow values where allowDuplicateKeyOverwrites - true  === */           
  targ = {
          a: 'hi',
          b: {
            c: 'there',
            d: 1,
            e: {
                f: 2,
                g: null,
                d: 2,
                a: 'ehi'
            }
          }
  };
  result = flattenObj(targ, true);
  
  checkEqual(
              {
                a: 'ehi',
                c: 'there',
                d: 2,
                f: 2,
                g: null
              }, result);
              
   /* === deeply nested duplicate keys should cause exception where allowDuplicateKeyOverwrites - false (the default)  === */ 
  expectDefect('Defect expected');
  targ = {
          a: 'hi',
          b: {
            c: 'there',
            d: 1,
            e: {
                f: 2,
                g: null,
                d: 2,
                a: 'ehi'
            }
          }
  };
  result = flattenObj(targ);
  

}

function valueTrackerEndPoint() {
  function prefixdRandomName(namePrefix){
    return namePrefix + createGuidTruncated();
  }

  var trk = valueTracker('names map', prefixdRandomName),
      newName = trk.setter,
      name = trk.getter,
      getOrNew = trk.getOrNew; 

  var nm1 = newName('tst1', 'newwww'),
      readBack = name('tst1');

  var nm2 = getOrNew('tst2', 'newwww2'),
      nm3 = getOrNew('tst2', 'newwww2');
  check(hasValue(nm2));
  checkEqual(nm2, nm3);

  expectDefect('should blow');
  var nm2 = newName('tst1', 'new1');
}

function reorderPropsUnitTest() {
  var obj = {
              aa: {
                    a: 'a',
                    b: 'b'
              },
              b: 'bbbb',
              c: 'c',
              zzz: 'zz'
            };

  var result = reorderProps(obj, 'zzz', 'b');

  var expected = {
                  zzz: 'zz',
                  b: 'bbbb',
                  aa: {
                        a: 'a',
                        b: 'b'
                  },
                  c: 'c'
  };

  checkEqual(objectToJson(expected), objectToJson(result), 'reorderPropsed object should be as expected');
}

function setInObjectUnitTest(){
  var eg = { 
             store: {
                    book: { 
                              category: "fiction",
                              author: "J. R. R. Tolkien",
                              title: "The Lord of the Rings",
                              isbn: "0-395-19395-8",
                              price: 22.99
                          },
                    books: [ 
                            { 
                              category: "reference",
                              author: "Nigel Rees",
                              title: "Sayings of the Century",
                              price: 8.95
                            }
                          ],
                bicycle: {
                  category: "fun",
                  color: "red",
                  gears: 12,
                  price: 19.95
                }
              },
            home: {
                  color: "green",
                  category: "homi",
                  stuff: {
                            category: "stuff cat",
                            toys: "fiction",
                            author: "Me",
                            other : {
                                    moreInfo: 'Hi there'
                            }
                          }            
            }
          };
          
  var expected = {
                  store: {
                    book: {
                      category: "new non fiction",
                      author: "J. R. R. Tolkien",
                      title: "The Lord of the Rings",
                      isbn: "0-395-19395-8",
                      price: 22.99
                    },
                    books: [
                      {
                        category: "reference",
                        author: "Nigel Rees",
                        title: "Sayings of the Century",
                        price: 8.95
                      }
                    ],
                    bicycle: {
                      category: "fun",
                      color: "red",
                      gears: 12,
                      price: 19.95
                    }
                  },
                  home: {
                    color: "green",
                    category: "new Home",
                    stuff: {
                      category: "stuff cat",
                      toys: "new Toys",
                      author: "Me",
                      other: {
                        moreInfo: "Hi there"
                      }
                    }
                  }
                }
          
  setInObj(eg, 'toys', 'new Toys');
  setInObj(eg, 'category', 'new Home');
  setInObj(eg, 'st*', 'category', 'new non fiction');
  setInObj(eg, 'color', 'green');
  checkEqual(expected, eg);
  
  expectDefect('Should throw exception')
  setInObj(eg, 'st*', 'toys', 'will not work');
}

function seekInObj_AllUnitTest() {
  pushLogFolder('seekInObj');
  seekInObjUnitTest();
  seekInObj_DefectUnitTest();
  seekInObj_UsingObjectSelectorsUnitTest();
  seekInObjUnitTest_arrays();
  popLogFolder();
  
  pushLogFolder('seekInObjAll');
  seekAllInObjEndPoint();
  popLogFolder();
}

function seekAllInObjEndPoint(){
  var targ = {
              blah1: 1,
                child: {
                  blah: 2,
                  grandChild: {
                    blah: [1, 2, 3],
                    blahh2: 'Gary'
                  }
                }
              };
  
  var result = seekAllInObj(targ, 'blah*');
  checkEqual([1, 2, [1, 2, 3], 'Gary'], result);
  
  result = seekAllInObj(targ, 'blah*', true);
  check(_.isArray(result), 'should be array');
  check(_.isArray(result) && result.length === 4, 'should be array of 4 items');
  
  result = seekAllInObj(targ, 'child', 'blah*');
  checkEqual([2, [1, 2, 3], 'Gary'], result);
  
  result = seekAllInObj(targ, 'noProp');
  checkEqual([], result, 'property not in target');
  
  targ = {
            blah1: 1,
              child: {
                blah: 2,
                grandChild: {
                  blah: [1, {
                              blah: 'array Blahh', 
                              p2: {
                                    blahhP2: 999
                                    }}, 3],
                  blahh2: 'Gary'
                }
              }
            };
  
  result = seekAllInObj(targ, 'grandChild', 'blah', [1], 'blah*');
  checkEqual(['array Blahh', 999], result, 'within an array');          
}

function seekInObj_DefectUnitTest() {
  var targ = {
              blah1: 1,
                child: {
                  blah: 2
                }
              };
  
  var result = seekInObj(targ, 'blah');
  checkEqual(2, result);
}

function seekInObjUnitTest_arrays(){

  /*******  Simple Array Only Cases *******/
  
  var targ = {
              blah1: 1,
                child: {
                  blah: [{book: {title: 'Wild Swans'}}]
                }
              };
  
  var expected = {
                  parent: targ.child.blah,
                  value: {book: {title: 'Wild Swans'}},
                  key: 0,
                  address: "child.blah." + ARRAY_QUERY_ITEM_LABEL()
                };
                
  var result = seekInObj(targ, 'blah', [0], true);
  checkEqual(expected, result, 'array 0 detailed');
  
  result = seekInObj(targ, 'blah', [0]);
  checkEqual({book: {title: 'Wild Swans'}}, result, 'array 0 result only');
  
  result = seekInObj(targ, 'blahg', [0], true);
  checkEqual(undefined, result, 'value not present');
  
  result = seekInObj(targ, 'blah', [1], true);
  checkEqual(undefined, result, 'index out of bounds');
  
  //*** array only ***//
  
  targ = [1, 2, 3, 4, 5];
  expected = {
                  parent: [1, 2, 3, 4, 5],
                  value: 3,
                  key: 2,
                  address: ARRAY_QUERY_ITEM_LABEL()
                };
  result = seekInObj(targ, [2], true);
  checkEqual(expected, result, 'index out of bounds');
  
  //*** empty array ***//
  
  result = seekInObj([], [2], true);
  checkEqual(undefined, result, 'index out of bounds');
  
  //*** nested properties ***//
  
  targ = {
              blah1: 1,
                child: {
                  blah: [{book: {title: 'Wild Swans'}}]
                }
              };
   
  expected = {
                parent: {
                  title: 'Wild Swans'
                },
                value: 'Wild Swans',
                key: 'title',
                address: "child.blah." + ARRAY_QUERY_ITEM_LABEL() + '.book.title'
              };
  
  result = seekInObj(targ, 'blah', [0], 'title', true);
  checkEqual(expected, result, 'nested unsder array');
  
  //*** nested properties multiple arrays ***//
  
  targ = {
              blah1: 1,
                child: {
                  blah: [
                          {
                            book: {
                                  title: 'Wild Swans',
                                  editions: [1,2,3,4]
                                }
                            }
                  ]
                }
              };
   
  expected = {
                parent: [1,2,3,4],
                value: 4,
                key: 3,
                address: "child.blah." + ARRAY_QUERY_ITEM_LABEL() + '.book.editions.' + ARRAY_QUERY_ITEM_LABEL() 
              };
  
  result = seekInObj(targ, 'blah', [0], 'editions', [3], true);
  checkEqual(expected, result, 'multi nested array');
  
  //*** nested properties using HOFS ***//

  
  targ = {
              blah1: 1,
                child: {
                  blah: [
                          {
                            book: {
                                  title: 'Wild Swans',
                                  editions: [1,2,3,4]
                                }
                            }
                  ]
                }
              };
  
  expected = {
              parent: [1,2,3,4],
              value: 2,
              key: 1,
              address: "child.blah." + ARRAY_QUERY_ITEM_LABEL() + '.book.editions.' + ARRAY_QUERY_ITEM_LABEL() 
            };
            
  function hasSwansTitle(val){
    return hasText(val.book.title, 'swans');
  }
  
  function isTwo(val){
    return val === 2;
  }
  result = seekInObj(targ, 'blah', [hasSwansTitle], 'editions', [isTwo], true);
  checkEqual(expected, result, 'multi nested array');
  
  //*** null property ***//
  targ = {
    prop: null
  };
  result = seekInObj(targ, 'prop');
  checkEqual(null, result, 'null prop');
  
  
}


function seekInObjUnitTest(){
  var eg = { 
             store: {
                    book: { 
                              category: "fiction",
                              author: "J. R. R. Tolkien",
                              title: "The Lord of the Rings",
                              isbn: "0-395-19395-8",
                              price: 22.99
                          },
                    books: [ 
                            { 
                              category: "reference",
                              author: "Nigel Rees",
                              title: "Sayings of the Century",
                              price: 8.95
                            },
                            { 
                              category: "fiction",
                              author: "Evelyn Waugh",
                              title: "Sword of Honour",
                              price: 12.99
                            }
                          ],
                bicycle: {
                  category: "fun",
                  color: "red",
                  gears: 12,
                  price: 19.95
                }
              },
            home: {
                  color: "green",
                  category: "homi",
                  stuff: {
                            category: "stuff cat",
                            toys: "fiction",
                            author: "Me",
                            other : {
                                    moreInfo: 'Hi there'
                            }
                          }            
            }
          };

  var expected = {
                  parent: {
                    category: "fun",
                    color: "red",
                    gears: 12,
                    price: 19.95
                  },
                  value: 12,
                  key: "gears",
                  address: "store.bicycle.gears"
                };
  var actual = seekInObj(eg, 'gears', true);
  checkEqual(expected, actual);
  
  actual = seekInObj(eg, 'gears', false);
  checkEqual(12, actual);
  
  actual = seekInObj(eg, 'category', false);
  checkEqual("homi", actual);
  
  expected =  {
                parent: {
                  color: "green",
                  category: "homi",
                  stuff: {
                    category: "stuff cat",
                    toys: "fiction",
                    author: "Me",
                    other: {
                      moreInfo: "Hi there"
                    }
                  }
                },
                value: "homi",
                key: "category",
                address: "home.category"
              };
              
  actual = seekInObj(eg, 'category', true);
  checkEqual(expected, actual);
  
  expected =  {
                parent: {
                  category: "stuff cat",
                  toys: "fiction",
                  author: "Me",
                  other: {
                    moreInfo: "Hi there"
                  }
                },
                value: "stuff cat",
                key: "category",
                address: "home.stuff.category"
              };
  
  actual = seekInObj(eg, 'stuff', 'cat*', true);
  checkEqual(expected, actual);
  
  // returnFullInfo should defualt to false
  actual = seekInObj(eg, 'stuff', 'cat*');
  checkEqual("stuff cat", actual);
  
  actual = seekInObj(eg, 'nonProperty');
  checkEqual(undefined, actual);
}

function seekInObj_UsingObjectSelectorsUnitTest(){
  var eg = { 
             store: {
                    book: { 
                              category: "fiction",
                              author: "J. R. R. Tolkien",
                              title: "The Lord of the Rings",
                              isbn: "0-395-19395-8",
                              price: 22.99
                          },
                    books: [ 
                            { 
                              category: "reference",
                              author: "Nigel Rees",
                              title: "Sayings of the Century",
                              price: 8.95
                            },
                            { 
                              category: "fiction",
                              author: "Evelyn Waugh",
                              title: "Sword of Honour",
                              price: 12.99
                            }
                          ],
                bicycle: {
                  category: "fun",
                  color: "red",
                  gears: 12,
                  price: 19.95
                }
              },
            home: {
                  color: "green",
                  category: "homi",
                  stuff: {
                            category: "stuff cat",
                            toys: "fiction",
                            author: "Me",
                            other : {
                                    moreInfo: 'Hi there'
                            }
                          }            
            }
          };

  var expected = {
                  parent: eg.store,
                  value: eg.store.book,
                  key: "book",
                  address: "store.book"
                };
  var actual = seekInObj(eg, {author: '*Tol*'}, true);
  checkEqual(expected, actual);
  
  expected = {
                parent: eg.home,
                value: eg.home.stuff,
                key: "stuff",
                address: "home.stuff"
              };
  actual = seekInObj(eg, {color: "g*"}, {author: "Me"}, true);
  checkEqual(expected, actual);
  
  actual = seekInObj(eg, {author: "M*"}, true);
  checkEqual(expected, actual);
  
  actual = seekInObj(eg, {author: "M*"}, 'moreInfo');
  checkEqual('Hi there', actual);
  
  actual = seekInObj(eg, {noWhereProp: "M*"}, 'moreInfo', true);
  checkEqual(undefined, actual);
  
  function areToys(val, key){
    return sameText('toys', key);
  }
  
  expected = {
                parent: eg.home.stuff,
                value: eg.home.stuff.toys,
                key: "toys",
                address: "home.stuff.toys"
              };
  actual = seekInObj(eg, areToys, true);
  checkEqual(expected, actual);
  
  actual = seekInObj(eg, areToys);
  checkEqual('fiction', actual);
}

function defaultDeepUnitTest(){
  var obj, defs, expected, actual;
  
  function hi(){
    return 'hi';
  }

  log('=== Plain Function Copied ===');
  defs = hi;
  obj = undefined; 
  actual = defaultDeep(obj, defs);
  expected = 'hi';

  checkEqual(expected, actual());

  log('=== Functions are Pointer Copied ===');

  obj = {
    hiFunc: undefined
  }

  defs = {
    hiFunc: hi
  }

  actual = defaultDeep(obj, defs);
  expected = 'hi';
  checkEqual(expected, actual.hiFunc());

  log('=== Ensure Original Object not Mutated When Clone is Mutated ===');
  obj = {};
  defs = {
          child: [{
                  arr: ['initial']
          }]
  };

  var defsCopy = {
          child: [{
                  arr: ['initial']
          }]
  };

  actual = defaultDeep(obj, defs, true);
  actual.child[0].arr = "Arrrrggghh";  

  checkEqual(defsCopy, defs, 'mutating a copy should not affect origional');

  log('=== Simple Object ===');
  obj = {
          p1: null,
          p2: undefined
        },
            
  defs = {
          p1: 1,
          p2: 2,
          p3: 3
         },
             
  expected = {
          p1: null,
          p2: 2,
          p3: 3
         },
  actual = defaultDeep(obj, defs, true);
  
  checkEqual(expected, actual);
 
  log('=== Nested Object ===');
  obj = {                                    
        p1: null,                          
        p2: undefined,
        child : {                                    
                  p1: null,                          
                  p2: undefined
                }                     
      },                                   
                                           
  defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: {
                    p1: 3,                             
                    p2: 4,                             
                    p3: 5                              
                 }
          },                                  
                                           
  expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: {
                        p1: null,                             
                        p2: 4,                             
                        p3: 5                              
                     }
              },
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);

  log('=== Nested Object with Array ===');
  obj = {                                    
        p1: null,                          
        p2: undefined,
        child : [
                  {                                    
                    p1: null,                          
                    p2: undefined
                  },
                  {
                                           
                    p2: 55,
                    p3: undefined
                  }
                ]
                                    
      },                                   
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            [
                              {
                                p1: 1,                             
                                p2: 2,                             
                                p3: 3                              
                               }, 
                               {
                                  p1: 3,                             
                                  p2: 4,                             
                                  p3: 5                              
                               },
                               {}
                             ], 
                             {
                                p1: null,                             
                                p2: 9,                             
                                p3: 8                              
                             })
          },                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child:  [
                        {                                    
                          p1: null,                             
                          p2: 9,                             
                          p3: 8 
                        },
                        {
                          p1: null,                             
                          p2: 55,                             
                          p3: 8
                        }
                        ]
              },
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);
  
  log('=== Missing Nested Object ===');
  obj = {                                    
        p1: null,                          
        p2: undefined              
      },                                   
                                           
  defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: {
                    p1: 3,                             
                    p2: 4,                             
                    p3: 5                              
                 }
          },                                  
                                           
  expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
               child: {
                    p1: 3,                             
                    p2: 4,                             
                    p3: 5                              
                 }
              },
                                                
  actual = defaultDeep(obj, defs);
  checkEqual(expected, actual);
  
  log('=== Nested Array ~ With Default ~ Should default object properties ===');
  obj = {                                    
        p1: null,                          
        p2: undefined,
        child: [{
          p0: 0
        }
        ]
      },                                   
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            [{defaltProp: 1}], 
                            {
                                p1: null,                             
                                p2: 9,                             
                                p3: 8                              
                            })
          },                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: [{
                    p0: 0,
                    p1: null,                             
                    p2: 9,                             
                    p3: 8 
                  }]
              },
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);

  log('=== Nested Array ~ undefined ~ Should default object properties and array ===');
  obj = {                                    
        p1: null,                          
        p2: undefined
      },                                   
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            [{
                              defaltProp: 1,
                              p2: 7
                            }, {}], 
                            {
                                p1: null,                             
                                p2: 9,                             
                                p3: 8                              
                            })
          },                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: [{
                        defaltProp: 1, 
                        p1: null,                             
                        p2: 7,                             
                        p3: 8
                      },  
                      {
                          p1: null,                             
                          p2: 9,                             
                          p3: 8                              
                      }]
              },
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);

  log('=== Nested Array ~ No Default ~ Should NOT default ===');
  obj = {                                    
        p1: null,                          
        p2: undefined
                                    
      };                                  
                                           
  defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            undefined, 
                            {
                                p1: null,                             
                                p2: 9,                             
                                p3: 8                              
                            })
          };                                  
                                           
    expected = { 
              child: undefined,                                   
              p1: null,                             
              p2: 2,                             
              p3: 3
              };
              
              
  log('=== Default is AarryDef / Target has Object ~ Should Do Nothing ===');
  obj = {                                    
        p1: null,                          
        p2: undefined,
        child: {
                    p1: undefined,                             
                    p2: 2222                            
               }
                                    
      };                                  
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs([{
                    p1: 3,                             
                    p2: 4,                             
                    p3: 5                              
                 }], {}) 
          };                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: {
                    p1: undefined,                             
                    p2: 2222                            
               }
              };
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);
  
  log('=== Default is Array / Target has Object ~ Should Do Nothing ===');
  obj = {                                    
        p1: null,                          
        p2: undefined,
        child: {
                    p1: undefined,                             
                    p2: 2222                            
               }
                                    
      };                                  
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: [{
                    p1: 3,                             
                    p2: 4,                             
                    p3: 5                              
                 }]
          };                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: {
                    p1: undefined,                             
                    p2: 2222                            
               }
              };
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);
  
  log('=== Array Only ~ Should default ===');
  obj = {                                    
        p1: null,                          
        p2: undefined
                                    
      },                                   
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            [{theDefault: '1'}], 
                             undefined)
          },                                  
                                           
    expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: [{theDefault: '1'}]
              },
                                                
  actual = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);
  
  log('=== Array Defaults Should Create New Array ===');
  obj = {                                    
        p1: null,                          
        p2: undefined
                                    
      },                                   
                                           
    defs = {                                   
          p1: 1,                             
          p2: 2,                             
          p3: 3,
          child: arrayDefs(
                            [{theDefault: 1}], 
                             undefined)
          },                                  
                                           
  expected = {                                   
              p1: null,                             
              p2: 2,                             
              p3: 3,
              child: [{theDefault: 1}]
              },
                                                
  actual = defaultDeep(obj, defs, true);
  var actual2 = defaultDeep(obj, defs, true);
  checkEqual(expected, actual);
  checkEqual(expected, actual2);
  
  //
  actual.child[0].theDefault = -9999;
  checkEqual(actual2.child[0].theDefault, 1, 'Mutating one defaulted array should not affect the other');
  
  log('=== Multiple Defaults ===');
  
  var targ, d1, d2, d3;
  targ = {
          a: 'a',
          b: undefined
         };
  d1 = {
        a: 'a1',
        b: 'b1',
        c: 'c1'
       };
  d2 = {
        a: 'a2',
        c: 'c2',
        d: 'd2',
        f: null
       };
  d3 = {
        d: 'd3',
        e: 'e3',
        f: 'f3'
       };
  
  expected = {
        a: 'a',
        b: 'b1',
        c: 'c1',
        d: 'd2',
        e: 'e3',
        f: null
       };

  actual = defaultDeep(targ, d1, d2, d3, true);
  checkEqual(expected, actual);      
}

function eachObjectRecursiveEndPoint() {

  var accum = {};
  function addProp(value, key, baseObj, baseAddress){
    
    log(appendDelim(def(baseAddress, ''), '.', key));
    
    function nextkey(curIdx){
      var truekey = curIdx === 0 ? key : key + curIdx;
      return isUndefined(accum[truekey]) ? truekey : nextkey(curIdx + 1);
    }
    
    if (!_.isObject(value) || _.isArray(value)){
      accum[nextkey(0)] = value;
    }
    
    return accum;
  }
  
  var obj = {
      name: 'Che',
      last: 'Guevara',
      dob: '14-06-1928',
          children: {
            aleida: {
                      dob: 'November 24, 1960', 
                      residence: 'Havana, Cuba'
                    },
            ernesto: {
                      dob: '1965',
                      pets: ['spot', 'polly']
                     }
          }
    };
    
    var obj2 = cloneDeep(obj);
    var expected = {
              name: 'Che',
              last: 'Guevara',
              dob: '14-06-1928',
              dob1: 'November 24, 1960', 
              residence: 'Havana, Cuba',
              dob2: '1965',
              pets: ['spot', 'polly'] 
    };
    
    eachObjectRecursive(obj, addProp);
    var actual = accum;
    checkEqual(expected, actual);
    checkEqual(obj, obj2, 'initial obj unchanged');
}

function reduceObjectRecursiveEndPoint() {

  function addProp(accum, value, key, baseObj, baseAddress){
    
    function nextkey(curIdx){
      var truekey = curIdx === 0 ? key : key + curIdx;
      return isUndefined(accum[truekey]) ? truekey : nextkey(curIdx + 1);
    }
    
    if (!_.isObject(value) || _.isArray(value)){
      accum[nextkey(0)] = value;
    }
    
    return accum;
  }
  
  var obj = {
      name: 'Che',
      last: 'Guevara',
      dob: '14-06-1928',
          children: {
            aleida: {
                      dob: 'November 24, 1960', 
                      residence: 'Havana, Cuba'
                    },
            ernesto: {
                      dob: '1965' 
                     }
          }
    };
    
    var obj2 = cloneDeep(obj);
    var expected = {
              name: 'Che',
              last: 'Guevara',
              dob: '14-06-1928',
              dob1: 'November 24, 1960', 
              residence: 'Havana, Cuba',
              dob2: '1965' 
    };
    
    var actual = reduceObjectRecursive(obj, addProp, {});
    checkEqual(expected, actual);
    checkEqual(obj, obj2, 'initial obj unchanged');
}

function mapObjectRecursiveEndPoint(){
  var obj = {
              name: 'Che',
              last: 'Guevara',
              dob: '14-06-1928'
            };
            
  var expected = {
                  name: null,
                  last: null,
                  dob: null
                };
          
  function bolivia(val, key){
    return null;  
  }
  
  var result = mapObjectRecursive(obj, bolivia);
  checkEqual(expected, result);
  
  obj = {
              name: 'Che',
              last: 'Guevara',
              dob: '14-06-1928',
                  children: {
                    aleida: {
                              dob: 'November 24, 1960', 
                              residence: 'Havana, Cuba'
                            },
                    ernesto: {
                              dob: '1965' 
                             }
                  }
            };
            
  expected = {
                  name: null,
                  last: null,
                  dob: null,
                  children: {
                              aleida: {
                                        dob: null, 
                                        residence: null
                                      },
                              ernesto: {
                                        dob: null
                                       }
                  }
                };
          
  
  result = mapObjectRecursive(obj, bolivia);
  checkEqual(expected, result);
  
  expected = {
                  name: null,
                  last: null,
                  dob: null,
                  children: {
                              aleida: {
                                        dob: 'children.aleida', 
                                        residence: 'children.aleida'
                                      },
                              ernesto: {
                                        dob: 'children.ernesto'
                                       }
                  }
                };
          
  function logNameOrNull(value, key, obj, parentAddress){
    return hasValue(parentAddress) ? parentAddress: null            
  }
  
  result = mapObjectRecursive(obj, logNameOrNull);
  checkEqual(expected, result);
    
  obj.testFunction = identity;
        
  function identity(value){
    return value;         
  }
  
  result = mapObjectRecursive(obj, identity);
  checkEqual(obj, result);
}

function logLinkEndPoint() {
  logLink('https://www.google.com.au/');
  logLink('main message', 'https://www.google.com.au/');
  logLink('main message', 'extra text', 'https://www.google.com.au/');
  logLink('main message', 'extra text', 'https://www.google.com.au/', logAttributes(true, true));
}


function cloneDeepUnitTest() {
  var target = {
                john: {
                
                        pets: {
                                stompa: 'rabbit',
                                spot: 'dog'
                              }
                       },
                 betty: {
                          pets: {
                                  sooty: 'guinea pig'
                                }
                       }
               };
               
  var result = cloneDeep(target);
  checkEqual(target, result);
  
  result.john.pets.stompa = 'bear';
  checkFalse(areEqual(target, result), 'mutating one object doesnot change the other');
  
  target = [];
  result = cloneDeep(target);
  checkEqual([], result);
  
  target = [1, 'hi', 5];
  result = cloneDeep(target);
  checkEqual([1, 'hi', 5], result);
  
  target = null;
  result = cloneDeep(target);
  checkEqual(null, result);
  
    
  target = 55;
  result = cloneDeep(target);
  checkEqual(55, result);
}

function objectToReadable_speed_endPoint(){
  var obj = fromTestData('johnsBigObject.json');
  
  var stopWatch = HISUtils.StopWatch;
  stopWatch.Start();
  var str = objectToReadable(obj);  
  stopWatch.Stop();
  log('obj to readable: ' + stopWatch.ToString());
  toTempString(str, 'johns_big_object.txt');
  
  var testArray = [
                    'item 1',
                    'item 2',
                    'item 3'
                  ];
                  
  toTempReadable(testArray)
}


function objectToReadableEndPoint() {
  var obj, result;
  
  function aFunction(p1, p2){
    return null;
  }
  
  obj = {
    name: 'maggie',
    last: 'Cheung',
    "function": aFunction,
    theDate: aqDateTime.SetDateTimeElements(2015, 1, 1, 15, 10, 55)
  };
  result = objectToReadable(obj, '     ');
  toTempString(result, 'dateTimeAsreadable.txt');
  return;
  
  obj = 'hello';
  result = objectToReadable(obj);
  toTempString(result, 'readable0.txt');
  
  obj = fromTestData('readableTest1.json');
  result = objectToReadable(obj);
  toTempString(result, 'readable1.txt');
  
  obj = fromTestData('readableTest2.json');
  result = objectToReadable(obj);
  toTempString(result, 'readable2.txt');
  
  obj = fromTestData('readableTest2.json');
  obj[0]['application state'].message = 'here is a message' + newLine() + '\tHeading' +  newLine() 
                                      +  '\t\tIndentated Message about stuff' +  newLine()
                                      + '\tHeading2' +  newLine() 
                                      +  '\t\tIndentated Message about stuff 2'; 
                                      
  result = objectToReadable(obj);
  toTempString(result, 'readableWithMultiString.txt');
}

function forceArrayUnitTest(){
  var result;
  var result = forceArray(null);
  checkEqual([null], result);
  
  result = forceArray(1);
  checkEqual([1], result);
  
  result = forceArray([1,'Hi']);
  checkEqual([1,'Hi'], result);
  
  result = forceArray(1,'Hi');
  checkEqual([1,'Hi'], result);
  
  result = forceArray([1],'Hi');
  checkEqual([1,'Hi'], result);
  
  result = forceArray([1],'Hi', [4, 5, 6, null], null, [['a']]);
  checkEqual([1,'Hi', 4, 5, 6, null, null, ['a']], result);
}

function hasPropertyEndPoint(){
  var obj = {};
  var result = hasProperty(obj, 'Name');
  
  var table = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  var result = hasProperty(table, 'RowCount');
}

function isRunnningInInteractiveModeEndPoint() {
  var result = isRunnningInInteractiveMode();
}

function chunkUnitTest() {
  var src = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  var result = chunk(src, 3);
  checkEqual([[0, 1, 2],[3, 4, 5], [6, 7, 8], [9]], result);
}


function seekParentEndPoint(){
   /* assumes you are here: http://support.smartbear.com/samples/testcomplete10/weborders/ */
   var child = seekByIdStr('ctl00_MainContent_username');
   var result = seekParent(null, {ObjectType: 'Form'});
   checkFalse(result.Exists, 'null child');
   
   result = seekParent(child, {ObjectType: 'Form'});
   check(result.Exists, 'child exists');
   
   var newResult = seekParent(result, {ObjectType: 'Form'});
   check(result.FullName === newResult.FullName, 'result equals child');
   
   result = seekParent(child, {ObjectType: 'FormbadType'});
   checkFalse(result.Exists, 'criteria not met');
}

function seekParenthEndPoint(){
  /* assumes you are here: http://support.smartbear.com/samples/testcomplete10/weborders/ */
  var child = seekByIdStr('ctl00_MainContent_username');
  var result = seekParenth(null, {ObjectType: 'Form'});
  checkFalse(result.Exists, 'null child');
   
  result = seekParenth(child, {ObjectType: 'Form'});
  check(result.Exists, 'child exists');
   
  var newResult = seekParenth(result, {ObjectType: 'Form'});
  check(result.FullName === newResult.FullName, 'result equals child');
   
  result = seekParenth(child, {ObjectType: 'FormbadType'});
  checkFalse(result.Exists, 'criteria not met');
}

function objectToJsonEndPoint() {
  function ignoreMe(p1, p2){
   // 
  }
  
  var person = {
    first: 'John',
    last: 'Doe',
    aFunction: ignoreMe,
    pets: ['spot', 'Bunnikins'],
    dob: getDate(1985, 11, 26)
  }
  
  var json = objectToJson(person);
  var newPerson = jsonToObject(json),
      newPersonJson = objectToJson(newPerson);
  // function not serialised
  checkEqual(json, newPersonJson);
}


function jsonToObjectEndPoint() {
  var person = {
    first: 'John',
    last: 'Doe',
    pets: ['spot', 'Bunnikins']
  }
  
  var json = objectToJson(person);
  var newPerson = jsonToObject(json);
  checkEqual(person, newPerson);
}


function waitRetryUnitTest() {
  var testFile = tempFile('myTestFile.txt');
  
  function isComplete(){
    return aqFileSystem.Exists(testFile);
  }
  
  function retry(){
    retryCount ++;
    if (retryCount > 5){
      stringToFile('dsfdf', testFile);
    }
  }
    
  /* the file will not be created within the retry period */
  aqFileSystem.DeleteFile(testFile);
  var retryCount = 0; 
  var result = waitRetry(isComplete, retry, 4000, 1000, 'Waiting for file - timeout expected');
  checkFalse(result, "A timeout is expected before test file is created");
  
  /* the file will be created within the retry period */
  aqFileSystem.DeleteFile(testFile);
  retryCount = 0; 
  result = waitRetry(isComplete, retry, 10000, 1000, 'Waiting for file - expect success');
  check(result, "The test file should be created within the time out");
}

function expectDefectUnitTest(){
  /* this error would be ignored by the log file parser */
  expectDefect(1234);
  logError('An expected error');
  endDefect();
  
  /* the log file parser would log an error because although the error is preceded by expectDefect
     the defect expectation as been deactivated */ 
  expectDefect(1234, false);
  logError('An error in disabled defect expectation');
  endDefect();
  
  /* the log file parser would log an expected error that 
     did not occur as there is an error expectation but no error logged */
  expectDefect(1234);
  log('This is not an error');
  endDefect();
}

function endDefectUnitTest(){
  endDefect();
  // an end defect message will be added to the test log
}

function areEqualUnitTest() {
  var result = areEqual(null, null);
  check(result);
  
  result = areEqual(22, 22);
  check(result);
  
  result = areEqual(aqDateTime.SetDateElements(2013, 6, 5), aqDateTime.SetDateElements(2013, 6, 5));
  check(result);
  
  result = areEqual(22, '22');
  check(result);
  
  result = areEqual(22, '22.1');
  checkFalse(result);
  
  result = areEqual(22, undefined);
  checkFalse(result);
  
  result = areEqual(22.002, '22.002');
  check(result);
  
  var val1, val2;
  val1 = {
      a: {
        b: 1.2222,
        c: 5.667
      },
    
    b: getDate(1977, 8, 9),
    c: 66,
    d: 'hi'
  }
  
  val2 = {
    b: getDate(1977, 8, 9),
    c: 66,
    d: 'hi',
    a: {
        b: 1.2222,
        c: (6 - 0.333)
      }
  };
  
  result = areEqual(val1, val2);
  check(result);
  
  result = areEqual([val1], [val2]);
  check(result);
  
  val1.c = 66.00001;
  result = areEqual([val1], [val2]);
  checkFalse(result);
  
}

function xOrUnitTest() {
  check(xOr(true, false));
  check(xOr(false, true));
  checkFalse(xOr(false, false));
  checkFalse(xOr(true, true));
}

function seekhEndPoint(){
 /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var page = activePage();
  var txt;
  
  txt = seekh(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);
  
  /*  Will not be found  */
  txt = seekh(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'user-name')});
  check(!txt.Exists);
  
  /*  Will not be found Quick - 1ms */
  txt = seekh(page,
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'user-name')});
  check(!txt.Exists);
}

function seekEndPoint(){
  var page = activePage();
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
     should fail instantly depth too shallow */
  var txt = seek(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0,
    2);
  checkFalse(txt.Exists);
  
  /* should pass is third level down */
  txt = seek(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0,
    3);
  check(txt.Exists);
  
  /* should fail after 5 seconds  */
  var txt = seek(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    5000, 2 );
  checkFalse(txt.Exists);
  
  var txt = seek(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);
  
 
  /* Will not be found should fail 
     after 10 seeconds */
  txt = seek(page, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'user-name')});
  check(!txt.Exists);
}

function seekAllEndPoint(){
  var imageArray = seekAll(
    "Aliases.browser.pageAvalonWhyChooseAvalon.formCountryform.panelPageWrapper.panelMainContainer.panelOuterContainer.panelInnerContainer.panelCtl00Divtopnavouter.panelCtl00Divtopnav",
    {
      alt: 'Why Choose Avalon?',
      VisibleOnScreen: 'True'
    },
    2
  ); 
  checkEqual(1, imageArray.length);
  imageArray[0].click();
}


function logErrorEndPoint(){
  logError("Hi There");
}

function logBoldEndPoint(){
  logBold("Hi There");
  var obj  = {
              ii: 'Here it is',
              age: 22,
              eyes: {
                      count: 2,
                      colour: 'blue'
                    }
              };
  logBold("Hi There", obj);
}

function logEndPoint(){
  log("Hi There");
}

function ensureEndPoint() {
  ensure(true);
  ensure(false, "Should throw!");
}

function waitAliasEndPoint() {
  /* open ie multitab with close multi tab warnings enabled open 2 tabs */
  var al = waitAlias('Aliases.browser.dlgInternetExplorer.btnCloseAllTabs');
  checkFalse(al.Exists);
  
  ShowMessage("Invoke multi tabs close confirmation now");
  
  al = waitAlias('Aliases.browser.dlgInternetExplorer.btnCloseAllTabs', false);
  check(al.Exists);
  
  al = waitAlias('browser.dlgInternetExplorer.btnCloseAllTabs', false);
  check(al.Exists);
  
  ShowMessage("Close tab window now - exception should follow");
  
  al = waitAlias('Aliases.browser.dlgInternetExplorer.btnCloseAllTabs', 1000, false);
  check(al.Exists);
  
  al = waitAlias('browser.dlgInternetExplorer.btnCloseAllTabs');
}

function defUnitTest(){
  /* myVar will be undefined */
  var myVar;
  var deffedVar = def(myVar, 1);
  checkEqual(1, deffedVar);
  
  /* empty string is treated as a value and not defaulted */ 
  myVar = "";
  deffedVar = def(myVar, 1);
  checkEqual("", deffedVar);
  
  /* null is defalted */
  myVar = null;
  deffedVar = def(myVar, 1);
  checkEqual(1, deffedVar);
  
  /* the first non-null and non-undefined argument is returned */
  myVar = null;
  deffedVar = def(myVar, undefined, 1);
  checkEqual(1, deffedVar);
  
  /* if all arguments are null or undefined will fall back to the last argument */
  myVar = undefined;
  deffedVar = def(myVar, undefined, undefined, null);
  checkEqual(null, deffedVar);
}

// demo def
function addTwoStrings(str1, str2, /* optional */ delim){
  delim = def(delim, ' ');
  return str1 + delim + str2;
}

function addTwoStringsEndPoint(){
  var result;
  result = addTwoStrings('John', 'Doe', '_');
  checkEqual('John_Doe', result);
  
  // overloaded: delimiter should default to space
  result = addTwoStrings('John', 'Doe');
  checkEqual('John Doe', result);
  
  // as an empty string is treated as a value it will not be defaulted
  result = addTwoStrings('John', 'Doe', '');
  checkEqual('JohnDoe', result);
}

function isNullEmptyOrUndefinedUnitTest(){
	var myVar;
	check(isNullEmptyOrUndefined(myVar));
	check(isNullEmptyOrUndefined(null));
	check(isNullEmptyOrUndefined(''));
	check(isNullEmptyOrUndefined(""));

	check(!isNullEmptyOrUndefined("s"));
	check(!isNullEmptyOrUndefined(1));
}

function hasValueUnitTest(){
  var obj, result
  
  result = hasValue(obj);
  checkFalse(result);
  
  result = hasValue(null);
  checkFalse(result);
  
  result = hasValue("");
  checkFalse(result);
  
  result = hasValue("John");
  check(result);
  
  result = hasValue("1/1/2000");
  check(result);
  
  result = hasValue("1\1\2000");
  check(result);
  
  result = hasValue(1);
  check(result);
  
  result = hasValue(0);
  check(result);
  
  var obj = Array(1, 2, 3)
  result = hasValue(obj);
  check(result);
  
  obj = aqDateTime.SetDateElements(2013, 1, 1);
  result = hasValue(obj);
  check(result);
}

function hasValueDemo_EndPoint(){
  var welcomeLabel = seekInPage(0, {
                                     contentText: 'Welcome*',
                                     Visible: 'True'
                                    });
                                    
  if (!hasValue(welcomeLabel)){
    logIn();
  }                               
}

function existsUnitTest(){
  check(exists(1));
}

function existsEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var page = activePage();
  
  var txt = seek(page, 
    {ObjectType: 'Page'});
  var exist = exists(txt);
  checkFalse(exist);
}

function calculateAge(person){
  ensure(hasValue(person), 'person is null');
  return ageCalc(person.dob);
}

function calculateAgeEndPoint() {
  calculateAge(null);
}



function throwExEndPoint(){
  throwEx("message", "detail!!");
}


function isNullOrUndefinedUnitTest() {
  var test;
  check(isNullOrUndefined(test));
  check(isNullOrUndefined(null));
  check(!isNullOrUndefined(""));
}

var NOTE_PAD_PATH = "C:\\Windows\\system32\\notepad.exe";

function terminateProcessEndPoint(){
  var counter;
  for (counter = 0; counter < 10; counter++)
  {
    executeFile(NOTE_PAD_PATH, "", false);
  }
  
  var notePadProcessName = "notepad"; 
  terminateProcess(notePadProcessName); 
  check(processExists(notePadProcessName));
 
  /* should run without error */
  terminateProcess("BlahhhDoesNotexist");      
}

function executeFileEndPoint(){
  executeFile(NOTE_PAD_PATH, "", true);
}

function processExistsUnitTest(){
 check(processExists("TestComplete") || processExists("TestExecute"));
 checkFalse(processExists("TestCompletez"));
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies