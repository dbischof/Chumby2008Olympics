class Chumby2008Olympics {

	private static var feedUrl:String = "http://syndication.nbcolympics.com/medals/index.xml";
	
	private static var widgetTitleColor:Number = 0xEBB41C;
	private static var widgetTextColor:Number = 0x000000;
	private static var widgetListEvenColor:Number = 0xE0E0E0;
	private static var widgetListOddColor:Number = 0xFFFFFF;
	
	private static var asOfDate:String = null;
	private static var draggingY:Number = null;
	
	public static function main() {
		// Set stage scale mode to keep it from resizing
		//Stage.scaleMode = "noscale";
		
		// draw layout
		drawBackground();
			
		// asset ID strings are auto-generated by FDBuild and can be inserted into
		// the currently open code file by double-clicking a resource in the tree view.

		getUpdate();
		//setInterval(getUpdate, 600000);	// 10 minutes
	}
	
	private static function drawBackground():Void {
		var background_top:MovieClip = _root.attachMovie("library.texture_top.png", "background_top", 2001);
		background_top._x = 0;
        background_top._y = 0;
		
		var background_center:MovieClip = _root.attachMovie("library.texture_center.png", "background_center", 0);
		background_center._x = 0;
        background_center._y = 90;
		
		var background_bottom:MovieClip = _root.attachMovie("library.texture_bottom.png", "background_bottom", 2000);
		background_bottom._x = 0;
        background_bottom._y = 230;
		
		var format:TextFormat = new TextFormat();
		format.font = "_sans";
		format.color = widgetTitleColor;
		format.size = 16;
		format.bold = true;
		
		_root.createTextField("title", 2002, 50, 5, 260, 0);
		_root.title.autoSize = "center";
		_root.title.setNewTextFormat(format);
		_root.title.text = "Beijing 2008 Olympic Games";
		
		_root.createTextField("subtitle", 2003, 50, 30, 260, 0);
		_root.subtitle.autoSize = "center";
		format.size = 14;
		_root.subtitle.setNewTextFormat(format);
		_root.subtitle.text = "August 8-24, 2008";
		
		format.color = widgetTextColor;
		
		_root.createTextField("t_g", 2004, 100, 65, 50, 0);
		_root["t_g"].autoSize = "right";
		_root["t_g"].setNewTextFormat(format);
		_root["t_g"].text = "G";
		
		_root.createTextField("t_s", 2005, 150, 65, 50, 0);
		_root["t_s"].autoSize = "right";
		_root["t_s"].setNewTextFormat(format);
		_root["t_s"].text = "S";
		
		_root.createTextField("t_b", 2006, 200, 65, 50, 0);
		_root["t_b"].autoSize = "right";
		_root["t_b"].setNewTextFormat(format);
		_root["t_b"].text = "B";
		
		_root.createTextField("t_t", 2007, 250, 65, 50, 0);
		_root["t_t"].autoSize = "right";
		_root["t_t"].setNewTextFormat(format);
		_root["t_t"].text = "T";
	}
	
	private static function getUpdate() {
		var xml:XML = new XML();
		xml.ignoreWhite = true;
		/*xml.onLoad = function(success:Boolean):Void {
			if (success){
				//trace (xml);				// debug, remove when done
				if (xml.hasChildNodes())
					Chumby2008Olympics.parseUpdate(xml);
			}
			else
				trace("Connection failure");
		}
		
		xml.load(getURL());*/
		
		xml.parseXML(Feed.xml);
		parseUpdate(xml);
	}
	
	private static function parseUpdate(xml:XML) {
		//trace(xml);
		var parentNode = xml.firstChild;
		
		asOfDate = parentNode.attributes.timestamp + " GMT";
		
		draggingY = null;	// Stop dragging druing update
		if (null != _root.countries)
			_root.countries.removeMovieClip();
		
		var medalSummaryNode = parentNode.childNodes[0];
		var countries:MovieClip = _root.createEmptyMovieClip("countries", 1);
		countries._x = 10;
		countries._y = 90;
		
		countries.onMouseDown = function() {
			var y:Number = _root._ymouse;
			if (y >= 90 && y < 230)
				this.draggingY = y;
		}
		countries.onMouseMove = function() {
			if (null != this.draggingY) {
				var yMovement = _root._ymouse - this.draggingY;
				countries._y = Math.max(Math.min(countries._y + yMovement, 90), 230-countries._height);
				this.draggingY = _root._ymouse;
			}
		}
		countries.onMouseUp = function() {
			this.draggingY = null;
		}
		
		var format:TextFormat = new TextFormat();
		format.font = "_sans";
		format.size = 14;
		
		for (var i:Number = 0; i < medalSummaryNode.childNodes.length; i++) {
			var countryNode = medalSummaryNode.childNodes[i];
			
			countries.beginFill(i % 2 == 1 ? widgetListOddColor : widgetListEvenColor, 100);
			countries.moveTo(0, i*35);
			countries.lineTo(0, i*35 + 35);
			countries.lineTo(300, i*35 + 35);
			countries.lineTo(300, i*35);
			countries.endFill();
			
			var code:String = countryNode.attributes.noc;
			var gold:String = countryNode.attributes.totalgold;
			var silver:String = countryNode.attributes.totalsilver;
			var bronze:String = countryNode.attributes.totalbronze;
			var total:String = countryNode.attributes.totalmedals;
			
			/*var flag:MovieClip = countries.createEmptyMovieClip("flag_" + i, countries.getNextHighestDepth());
			flag._x = 10;
			flag._y = (i * 35) + 6;
			flag.loadMovie("http://widgets.nbcuni.com/olympics/flags/" + code + ".gif");*/
			var flag:MovieClip = countries.attachMovie("library.flags." + code + ".png", "flag_" + i, countries.getNextHighestDepth());
			flag._x = 10;
			flag._y = (i * 35) + 6;
			
			createRowField(countries, format, i, 0, code, "left");
			createRowField(countries, format, i, 1, gold, "right");
			createRowField(countries, format, i, 2, silver, "right");
			createRowField(countries, format, i, 3, bronze, "right");
			format.bold = true;
			createRowField(countries, format, i, 4, total, "right");
			format.bold = false;
			
			//if (i == 3)
			//	break;
		}
	}
	
	private static function getURL() {
		var random:Number = Math.floor(Math.random() * 100);
		return feedUrl + "?r=" + random;
	}
	
	private static function createRowField(parent:MovieClip, format:TextFormat, pos:Number, column:Number, text:String, align:String) {
		var name = "tf_" + pos + "_" + column;
		//var depth:Number = (pos * 10) + (10 + column);
		var depth = parent.getNextHighestDepth();
		var y:Number = (pos * 35) + 9;
		
		if (0 == column)
			parent.createTextField(name, depth, 55, y, 35, 0);
		else if (1 == column)
			parent.createTextField(name, depth, 90, y, 50, 0);
		else if (2 == column)
			parent.createTextField(name, depth, 140, y, 50, 0);
		else if (3 == column)
			parent.createTextField(name, depth, 190, y, 50, 0);
		else if (4 == column)
			parent.createTextField(name, depth, 240, y, 50, 0);
		
		parent[name].autoSize = align;
		parent[name].setNewTextFormat(format);
		parent[name].text = text;
	}
}