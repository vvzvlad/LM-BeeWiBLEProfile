(function() {
  var el = $('#beewi')
	, icon = $('<div></div>').addClass('icon').appendTo(el)
    , slider = $('<div id="beewi_slider"></div>').addClass('slider').appendTo(el)
    , colorlist = $('<div></div>').addClass('colorlist').appendTo(el)
	, lum =  $('<div></div>').addClass('lum').appendTo(el)
	, nslider; 
 	
	el.setWidgetSize(3, 1);
   
	var colors = [
		{color:"13840175", button:"d32f2f", background:"D32F2F", slider:"FFCDD2"},
		{color:"240116", button:"03a9f4", background:"03A9F4", slider:"B3E5FC"},
		{color:"16733986", button:"ff5722", background:"F57C00", slider:"FFE0B2"},
		{color:"3162015", button:"303f9f", background:"3F51B5", slider:"C5CAE9"},
		{color:"16771899", button:"ffeb3b", background:"FFEB3B", slider:"FFF9C4"},
		{color:"9784007", button:"954ac7", background:"7B1FA2", slider:"E1BEE7"},
		{color:"3706428", button:"388e3c", background:"388E3C", slider:"C8E6C9"},
	]
   
	var currN = false; 
	var prevColor = false; 
	var prevLum = false; 
	var pLum = false;
	var currStatus = -1;
   
	$.getScript("/apps/data/beewi/js/nouislider.min.js", function(){ 
		init(); 
	});
  
	function init() { 
		for (var i in colors) { 
			var c = $('<a href="javascript:;" data-n="'+i+'"></a>')
				.addClass("color-item")
				.css("background-color", "#"+colors[i].button)
				.appendTo(colorlist);
			
			c.click(function() { 
				var n = $(this).data("n");
				if (currN!==false) $("a", colorlist).eq(currN).removeClass("active"); 
				$(this).addClass("active");
				sendData({color:colors[n].color});
				currN=n;
			})
		}
	   
		var toggle = $('<a href="javascript:;"></a>').addClass("color-item")
		.appendTo(colorlist).addClass("toggle");
		toggle.click(function() { 
			if (currStatus)  sendData({power:0});
			else sendData({power:1}); 
		})
		el.click(function() { 
			if (!currStatus)  sendData({power:1});
			return false;
		})
		
		nslider = document.getElementById("beewi_slider")
		noUiSlider.create(nslider, { 
			start: 40,
			connect: 'lower',
			range: {
			  'min': 0,
			  'max': 100
			}		
		});
		nslider.noUiSlider.on("change", function(v) { 
			sendData({brightness:parseFloat(v[0]).toFixed(0)})
		})

		sendData({});
        setInterval(function(){sendData({})}, 1000);		
	} 
   
   function sendData(data) {
		$.post('/apps/data/beewi/data.lp', 
			data, 
			function(data) { 
				var d; 
				try{
					d = JSON.parse(data) 
				}catch(e){}
				if (d) setValue(d)
			}
		)
   }
 
   function setValue(d) {
		if (d.color) { 
			var color=parseInt(d.color); 
			if (!isNaN(color) && color !== prevColor) {
				
				var n = -1, found=-1;
				for (n in colors) { 
					if (colors[n].color==color) {
						el.css("background-color", "#"+colors[n].background);
						slider.css("background-color", "#"+colors[n].slider);
						prevColor = color;
						found = n;
						break;
					}
				}
				if (n>=0 && n!==currN) { 
					if (currN!==false) $("a", colorlist).eq(currN).removeClass("active"); 
					$("a", colorlist).eq(n).addClass("active"); 
					currN = n;
				}else { 
					el.css("background-color", "#"+color.toString(16));
					$("a.active", colorlist).removeClass("active");
					prevColor = color;
					currN = false;
				}
			}
		}
		
		if ("power" in d) { 
			if (d.power !== currStatus) {
				if (!d.power && !el.hasClass("off")) el.addClass("off");
				else if (d.power && el.hasClass("off")) el.removeClass("off");
				currStatus = d.power;
			}
		}		
		
		if ("brightness" in d) { 
			var l=parseInt(d.brightness); 
			if (!isNaN(l) && l !== prevLum) {
				if (l<0) l=0; 
				else if (l>100) l =100;
				lum.text(l+"%");
				nslider.noUiSlider.set(l);
				prevLum = l;
			}
		}		
   }
   
})();
