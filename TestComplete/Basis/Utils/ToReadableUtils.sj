//USEUNIT StringUtilsGreatGrandParent
//USEUNIT _

/** Module Info **
This unit has been modified from http://www.json.org/js.html|www.json.org to produce a "Readable" object 

An open source module for serialising and deserialising JSON [[http://www.json.org/js.html|www.json.org]]
Note: There is no need to use this module directly use objectToReadable
**/

/*
   initial File
    json2.js
    2012-10-08

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html

*/

/**
See [[http://www.json.org/js.html|www.json.org]] for initial file
**/


// Create a TOREADABLE object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (typeof TOREADABLE !== 'object') {
    TOREADABLE = {};
}

(function () {
    'use strict';

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toReadable !== 'function') {

        Date.prototype.toReadable = function (key) {

            return isFinite(this.valueOf())
                ? this.getUTCFullYear()     + '-' +
                    f(this.getUTCMonth() + 1) + '-' +
                    f(this.getUTCDate())      + 'T' +
                    f(this.getUTCHours())     + ':' +
                    f(this.getUTCMinutes())   + ':' +
                    f(this.getUTCSeconds())   + 'Z'
                : null;
        };

        String.prototype.toReadable      =
            Number.prototype.toReadable  =
            Boolean.prototype.toReadable = function (key) {
                return this.valueOf();
            };
    }

    var gap,
        indent,
        rep;

  var topObjectForReadable = true;
    
  function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];
            
      function makeReadableDisplayString(string){
          if (string.indexOf('\n') > -1 || string.indexOf('\r') > -1){
            var delim = '\n' +  mind + indent;
            function prependIndentation(str){
              return delim + str
            }
            var result = _.map(standardiseLineEndings(string).split('\n'), prependIndentation).join('');
            return result;
          }
          else {
            return string;
          }
        }
        
// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toReadable === 'function') {
            value = value.toReadable(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.
        var thisType = typeof value;
        switch (thisType) {
        
        case 'string':
            return makeReadableDisplayString(value);
            
        case 'date':
          return makeReadableDisplayString(aqConvert.DateTimeToStr(value));
          
        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.
            
            return thisType == 'boolean' ? ' ' + String(value) :' null';

        case 'function':
          return subStrBefore(value.toString(), ')') + '){...}';
          
        case 'undefined':
          return ' undefined';
// If the type is 'object', we might be dealing with an object or an array or
// null.
   
        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return ' null';
            }

// Make an array to hold the partial results of stringifying this object value.
            if (topObjectForReadable){
             topObjectForReadable = false; 
            }
            else {
              gap += indent;
            }
            
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.
                v = partial.length === 0
                    ? '[]'
                    : gap
                    ? '\n'+ gap + '[' + '\n' +  indent  + gap + partial.join('\n' + gap 
                      + indent + '------------------------------------------' + '\n' + indent + gap ) + '\n' + mind + ']'
                    : '[' + partial.join('') + ']';
                
                gap = mind;
                return v;
            }


// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === 'string') {
                      k = rep[i];
                      v = str(k, value);
                      partial.push(makeReadableDisplayString(k) + (gap ? ': ' : ':') + v);
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                      v = str(k, value);
                      partial.push(makeReadableDisplayString(k) + (/*gap ? */ ': ' /* : ':' */) + v);
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.
            v = partial.length === 0
                ? ''
                : gap
                ? '\n' + gap + partial.join('\n' + gap) + mind
                :  partial.join('\n');
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.
    if (typeof TOREADABLE.stringify !== 'function') {
        TOREADABLE.stringify = function (value, replacer, space, toReadable) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.
            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.
            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('TOREADABLE.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }
    
}());

// THIS OPEN SOURCE SOFTWARE DO NOT MODIFY THIS FILE

