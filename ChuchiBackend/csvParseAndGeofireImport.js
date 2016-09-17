var Converter = require("csvtojson").Converter;

var Promise = require('es6-promise').Promise;

var jsonfile = require('jsonfile'); 

var NodeGeocoder = require('node-geocoder');

var firebase = require('firebase');

var GeoFire = require('geofire');


firebase.initializeApp({
    apiKey: "AIzaSyAF0JHyoExAdIXEqd1_wxxyxxl-XVdBfz0",
    databaseURL: "https://chuchi-face6.firebaseio.com"
  });
    

  // Generate a random Firebase location
  var firebaseRef = firebase.database().ref('stores');
    
  
  // Create a new GeoFire instance at the random Firebase location
  var geoFire = new GeoFire(firebaseRef);
    

//parseStoreData = function(){
//    
//    var converter = new Converter({
//        delimiter: ';'
//    });
//    
//    return new Promise(function(resolve, reject){
//        require("fs").createReadStream("./resources/Valora_stores_eng.csv").pipe(converter);
//    
//        //end_parsed will be emitted once parsing finished 
//        converter.on("end_parsed", function (jsonArray) {
//            jsonfile.writeFile('stores.json', jsonArray, function (err) {
//                console.error(err);
//            })
//            //resolve(jsonArray);
//        });
//    
//    });
//    
//    
//    
//}

getStoreData = function(){
    var file = 'stores.json';
    return new Promise(function(resolve, reject){
       jsonfile.readFile(file, function(err, obj) {
            
           resolve(obj);
       }); 
    });
}


 
var options = {
  provider: 'google',
 
  // Optional depending on the providers 
    httpAdapter: 'https', // Default 
    apiKey: 'AIzaSyCEJH-vNMy8L0U9PsZbjKPuf0_m4G8pr48', 
//    appId: 'F7UZsQUNRl2jg0XZJ3ay',
//    appCode: 'lxGdUNAxc8iPXT1-EMWUrA',
    formatter: null         // 'gpx', 'string', ... 
};


mapAddressToGeolocation = function(sid, address) {
    var geocoder = NodeGeocoder(options);
 
//    // Using callback 
//    geocoder.geocode(address, function(err, res) {
//      //console.log(res[0]);
//        if (res[0] != null && res[0] != undefined){
//            console.log(res[0].latitude +", "+ res[0].longitude);
//        }
//    });
 
//     Or using Promise 
    

    return new Promise(function(resolve, reject){
        
        geocoder.geocode(address)
          .then(function(res) {
            if (res[0] != null && res[0] != undefined){
                var geoInfo = [
                    res[0].latitude,
                    res[0].longitude
                ]; 
                var obj = {
                    "id" : sid,
                    "geoInfo": geoInfo
                };
                //console.log(geoInfo);
                resolve(obj);
            }
            else {
                var obj = {
                    "id" : sid,
                    "geoInfo": undefined
                };
                
                resolve(geoInfo);
            }
          })
          .catch(function(err) {
            console.log(err);
          });
        
        
    });
    

}

performLoad = function(){

    var stores = getStoreData().then(function(data){
        console.log(data.length);
        
        for (var i=0; i<100; i++){
            var storeId = data[i].Store;
            var address = data[i].Street+", "+data[i].ZIP+", "+data[i].City;
            console.log('===>1 ' + data[i].Store+" "+address);
            mapAddressToGeolocation(data[i].Store, address).then(function(val){

                if (val.geoInfo != undefined) {
                    console.log('===>4 ' + val.id);
                    console.log('===>6 ' + val.geoInfo);
                    
                    importToFirebase(val.id, val.geoInfo);
                    
                }
                
                
                
                
            });
        }
        
    });
    

}

function importToFirebase(storeId, location){
    
console.log("import location for store " + storeId);
      // Initialize the Firebase SDK

 
      // Set the initial locations of the fish in GeoFire

    geoFire.set("store" + storeId, location).then(function() {
      console.log("store" + storeId + " initially set to [" + location + "]");
    }); 

}

performLoad();