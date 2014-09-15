
var width =960;
var height = 960;

var projection=d3.geo.mercator().center([120.979531, 23.978567]).scale(50000);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

var g = svg.append("g");    

var path = d3.geo.path()
    .projection(projection);

var filename='ElectionPartyRegion.json';
var govern={};
jQuery.get(filename, function(data) {
for(var i=0;i< data['features'].length;i++){
    	var location=JSON.stringify(data['features'][i]['properties']['Location']);
    	location=location.substring(1, location.length-1);
    	var Party=JSON.stringify(data['features'][i]['properties']['Party']);
  		Party=Party.substring(1,Party.length-1);
    	govern[location]=Party;
	}
	mymap(govern);
},'JSON');

function worldmap(){
	d3.json("world-110m2.json", function(error, topology) {
    	g.selectAll("path")
    	.data(topojson.object(topology, topology.objects.countries)
        	.geometries)
    	.enter()
      		.append("path")
      		.attr({
      			d:path,
      			fill:"#0f0"
      		});
	});  
}

function mymap(govern){
	d3.json("twVillage1982.topo.json", function(error, topology){
      /*
      update center, scale and translate
      var b = topology["bbox"];
      console.log(b);
      projection.center([(b[0]+b[2])/2, (b[1]+b[3])/2] );
      var s = 0.95 / Math.max((b[2] - b[0]) / width, (b[3] - b[1]) / height),
          t = [(width - s * (b[2] + b[0])) / 2, (height - s * (b[3] + b[1])) / 2];
      console.log(s);
      console.log(t);
      projection
      .scale(s)
      .translate(t);
      */
      g.selectAll("path")
    	.data(topojson.object(topology, topology.objects.layer1)
        	.geometries)
    	.enter()
      		.append("path")
      		.attr({
      			d:path,
            fill:"#0f0"
            /*
      			fill:function(d,i){
              
      				d['properties']['COUNTYNAME']=d['properties']['COUNTYNAME'].replace(new RegExp('台', 'g'),"臺");

      				if(d['properties']['COUNTYNAME']=='臺中縣' || d['properties']['COUNTYNAME']=='臺北縣' ||
      					d['properties']['COUNTYNAME']=='高雄縣' || d['properties']['COUNTYNAME']=='臺南縣'){
      					d['properties']['TOWNNAME']=d['properties']['TOWNNAME'].replace(new RegExp('鎮', 'g'),"區");	
      					d['properties']['TOWNNAME']=d['properties']['TOWNNAME'].replace(new RegExp('鄉', 'g'),"區");
      					d['properties']['TOWNNAME']=d['properties']['TOWNNAME'].replace(new RegExp('市', 'g'),"區");	
      					d['properties']['VILLAGENAM']=d['properties']['VILLAGENAM'].replace(new RegExp('村','g'),"里");
      					if (d['properties']['COUNTYNAME']=='臺中縣') d['properties']['COUNTYNAME']='臺中市';
      					else if(d['properties']['COUNTYNAME']=='臺北縣') d['properties']['COUNTYNAME']='新北市';
      					else if(d['properties']['COUNTYNAME']=='高雄縣') d['properties']['COUNTYNAME']='高雄市';
      					else if(d['properties']['COUNTYNAME']=='臺南縣') d['properties']['COUNTYNAME']='臺南市';
      				}
      		    d['properties']['TOWNNAME']=d['properties']['TOWNNAME'].replace(new RegExp('左區區', 'g'),"左鎮區");  
              d['properties']['TOWNNAME']=d['properties']['TOWNNAME'].replace(new RegExp('新區區', 'g'),"新市區");  
      				var key=d['properties']['COUNTYNAME']+d['properties']['TOWNNAME']+d['properties']['VILLAGENAM'];
      				
              //var key=d['properties']['COUNTYNAME']+d['properties']['TOWNNAME']+d['properties']['VILLAGENAM'];
      				
      				if(govern.hasOwnProperty(key)){
      					if (govern[key]=='中國國民黨'){
      						//console.log(key);
      						return "blue";
      					}
      					else if (govern[key]=='民主進步黨'){
      						//console.log(key);
      						return "green";
      					}
      					else if (govern[key]=='親民黨') return "orange";
      					else if (govern[key]=='無黨籍及未經政黨推薦' || govern[key]=='無') return "grey";
      					else if (govern[key]=='中華統一促進黨') return "yellow";
      					else {
      						//console.log(key);
      					}
      				}
      				else{
    					  console.log(key);
      				  return "red";
      				}	
      			}*/
      		});

	});
}