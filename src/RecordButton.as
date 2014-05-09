package {
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author jdudak
	 */
	public class RecordButton extends MovieClip {
		public static const INITIAL_STATE:String = "initial";
		public static const RECORD_STATE:String = "record";
		public static const STOP_STATE:String = "stop";
		public static const PRELOAD_STATE:String = "preload";
		private var state:String;
		private var size:Number;
		private var micPic:Bitmap;
		public function RecordButton(size:Number) {
			this.size = size;
			this.buttonMode = true;
			this.micPic = new Main.MicImage() as Bitmap;
			this.micPic.height = size;
			this.micPic.scaleX = this.micPic.scaleY;
			this.setState(INITIAL_STATE);
			addEventListener(Event.ENTER_FRAME, frameEntered);
		}
		
		public function getState():String {
			return this.state;
		}
		
		public function setState(state:String):void {
			this.state = state;
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 1);
			this.graphics.drawRect(0, 0, size, size);
			if (this.contains(micPic)) {
				this.removeChild(micPic);
			}
			switch (state) {
				case INITIAL_STATE:
					this.addChild(micPic);
					break;
				case RECORD_STATE:
					this.graphics.beginFill(0xFF0000, 1);
					this.graphics.drawCircle(size / 2, size / 2, size / 2 - 3);
					break;
				case STOP_STATE:
					this.graphics.beginFill(0x000000, 1);
					this.graphics.drawRect(size / 4, size / 4, size / 2, size / 2);
					break;
				case PRELOAD_STATE:
					drawPreloader(preloadCounter);
					break;
			}
		}
		
		private var preloadCounter:int = 0;
		private function frameEntered(e:Event):void {
			if (this.state == PRELOAD_STATE) {
				preloadCounter = (preloadCounter+6) % 360;
				this.graphics.clear();
				drawPreloader(preloadCounter);
			}
			
		}
		
		private function drawPreloader(counter:int):void {
			this.graphics.beginFill(0x000000, 1);
			var numCircles:int = 7;
			for (var i:int = 0; i < numCircles; i++ ) {
				var angle:Number = 2 * Math.PI * (i / numCircles) + preloadCounter*2*Math.PI/360;
				this.graphics.drawCircle(size / 2 + (size/2-3)*Math.cos(angle), size / 2 + (size/2-3)*Math.sin(angle), 2);
			}			
		}
		
	}

}